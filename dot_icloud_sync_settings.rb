# Copy this file to ~/.icloud_sync_settings.rb and modify it
CLIENT_ID = "google oauth client id"
CLIENT_SECRET = "google oauth client secret"
CALENDAR_ID = "google calendar id"
REFRESH_TOKEN_FILE = File.expand_path("~/.icloud_sync_refresh_token") # you can change this if you want...
DAYS = 21 # how many days to look into the future for iCloud events
ICLOUD_URLS = %w(
  https://p03-calendars.icloud.com/published/2/LONG_ID_FOR_FIRST_PUBLISHED_CALENDAR
  https://p03-calendars.icloud.com/published/2/LONG_ID_FOR_SECOND_PUBLISHED_CALENDAR
  https://etc
)
