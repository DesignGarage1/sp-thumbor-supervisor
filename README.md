# sp-thumbor-supervisor
Supervisor tool for Simpleprints' Thumbor servers (hosted on Heroku)


### How does it work?

This is based on `whacamole` library (https://github.com/arches/whacamole/).

It automatically restarts Heroku apps when meet a certain memory usage before Heroku forces killing those apps, leaves them in the crashed state after several times (and only manually restarting can fix them).

This tool provides logging and simple interface to the `whacamole` library.


### How can I run it?

##### Prerequisites

Enable `log-runtime-metrics` on each of your Heroku apps with:
```bash
$ heroku labs:enable log-runtime-metrics --app YOUR_APP_NAME
```

##### And then

Several ways:
- *Run directly:* `bundle exec whacamole -c ./sp-thumbor-supervisor.rb`. So it can be used with `supervisord`, `mmonit`,...
- *Run on Heroku:* scale the `whacamole` dyno.


### Where is `settings.rb`?

You can tell it by its name, that file contains settings for this tool. However, some informations are confidential so I can't include it here. But, you can make one for yourself using this template:

```ruby
module Settings

  # Your Heroku API token, get by <heroku auth:token>
  HEROKU_API_TOKEN = '0xx0x00x-00x0-0x00-00x0-0x00xx0x000x'  # Mandatory

  # Your Heroku apps' names list
  HEROKU_APPS = ['my-heroku-1', 'my-heroku-2']  # Mandatory

  # Which Dynos you want to watch?
  DYNOS = %w{web}  # Optional, default => %w{web}

  # Your memory limit for each app?
  RESTART_THRESHOLD = 500  # Optional, default => 500 (MB)

  # Will not restart if the last one happens X seconds ago
  RESTART_WINDOW = 30 * 60  # Optional, default => 30 (minutes)

  # Will log all events? Or just the restarting ones?
  LOG_ALL_EVENTS = false  # Optional, default => false
end

```
