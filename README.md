# iCloud to Google Calendar sync

This syncs one-way from iCloud calendars to Google Calendar. It combines
events from multiple iCloud calendars to a single Google Calendar, anonymizing
the events in the process.

You can use this to assist a tool like [Calendly](https://calendly.com) which
pulls information from Google Calendar.

1. [Share your iCloud calendar publicly](https://support.apple.com/kb/ph2690?locale=en_US)
2. Copy the example `dot_icloud_sync_settings.rb` file to `~/.icloud_sync_settings.rb`
3. Modify the file as needed
4. Add the sync script to your crontab

## Example crontab

`*/5 * * * * cd ~/code/icloud_to_gcal && /usr/local/var/rbenv/shims/bundle exec ruby sync.rb`
