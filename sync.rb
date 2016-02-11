require "open-uri"
require "icalendar"
require "icalendar/recurrence"
require "google_calendar"

load File.expand_path("~/.icloud_sync_settings.rb")

## Google calendar login
gcal = Google::Calendar.new(:client_id     => CLIENT_ID,
                            :client_secret => CLIENT_SECRET,
                            :calendar      => CALENDAR_ID,
                            :redirect_url  => "urn:ietf:wg:oauth:2.0:oob" # this is what Google uses for 'applications'
)

unless File.file?(REFRESH_TOKEN_FILE)
  puts "Visit the following web page in your browser and approve access."
  puts gcal.authorize_url
  puts "\nCopy the code that Google returned and paste it here:"

  refresh_token = gcal.login_with_auth_code( $stdin.gets.chomp )
  File.open(REFRESH_TOKEN_FILE, 'w') {|w| w << refresh_token }
end

refresh_token = File.read REFRESH_TOKEN_FILE
begin
  gcal.login_with_refresh_token(refresh_token)
rescue Google::HTTPAuthorizationFailed
  $stderr.puts "Authorization failed. Remove #{REFRESH_TOKEN_FILE} and try again"
  exit 1
end

class MyOccurrence
  attr_reader :event, :start_time, :end_time

  def self.gcal(gcal)
    new Time.parse(gcal.start_time), Time.parse(gcal.end_time), gcal
  end

  def self.ical(occurrence, event)
    new occurrence.start_time, occurrence.end_time, event
  end

  def initialize(start_time, end_time, event)
    @start_time = start_time
    @end_time = end_time
    @event = event
  end

  def eql?(other)
    start_time == other.start_time &&
      end_time == other.end_time
  end

  def hash
    [start_time, end_time].hash
  end
end

range_start_date = Date.today
range_end_date = Date.today.next_day(DAYS)

## iCloud calendar parsing
occurrences = []
ICLOUD_URLS.each do |icloud_url|
  response = open icloud_url
  data = response.read
  ical = Icalendar.parse(data).first

  ical.events.each {|e| e.instance_variable_set(:@parent, nil) }

  occurrences += ical.events.map {|e|
    e.occurrences_between(range_start_date.to_time.utc, range_end_date.to_time.utc).map {|o|
      MyOccurrence.ical(o, e)
    }
  }.flatten
end

gcal_events = gcal.find_events_in_range(range_start_date.prev_month.to_time.utc, range_end_date.next_month.to_time.utc, max_results: 2500)
  .map {|e| MyOccurrence.gcal(e) }

# Add any missing events
(occurrences - gcal_events).each do |o|
  gcal.create_event do |e|
    e.title = "busy"
    e.start_time = o.start_time
    e.end_time = o.end_time
  end
end

# Delete any events which have been removed from iCloud
(gcal_events - occurrences).each do |o|
  o.event.delete
end
