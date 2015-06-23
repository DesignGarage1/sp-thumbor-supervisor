require 'logger'
require 'whacamole/events'

require './settings'


########## Setting up Logger ##########
$stdout.sync = true
$logger = Logger.new(STDOUT)
$logger.formatter = proc do |severity, datetime, progname, message|
  "[#{datetime}] #{severity} | #{message}\n"
end

########## Event Handler ##########
def app_event_handler(app)
  last_memory_usage = ""

  return lambda do |event|
    if event.instance_of? Whacamole::Events::DynoRestart
      $logger.warn "[#{app}] RESTART. Usage: #{last_memory_usage}"
    else
      if event.instance_of? Whacamole::Events::DynoSize
        last_memory_usage = "#{event.size} #{event.units}"
      end

      if Settings::LOG_ALL_EVENTS
        if event.instance_of? Whacamole::Events::DynoSize
          $logger.debug "[#{app}] {#{event.size} #{event.units}}" % [event.size, event.units]
        else
          $logger.debug "[#{app}] #{event.inspect.to_s}"
        end
      end
    end
  end
end

########## Cleanup Settings ##########
def check_mandatory_constant(constant_name)
  if not Settings.const_defined? constant_name
    $logger.fatal "\"#{constant_name}\" is needed! Process exits..."
    Process.exit(1)
  end
end

def provide_default_constant(constant_name, constant_value)
  if not Settings.const_defined? constant_name
    $logger.warn "\"#{constant_name}\" is missing... => #{constant_value}"
    Settings.const_set(constant_name, constant_value)
  end
end

check_mandatory_constant(:HEROKU_API_TOKEN)
check_mandatory_constant(:HEROKU_APPS)
provide_default_constant(:DYNOS, %w{web})
provide_default_constant(:RESTART_THRESHOLD, 500)  # 500 MB
provide_default_constant(:RESTART_WINDOW, 30 * 60)  # 30 minutes
provide_default_constant(:LOG_ALL_EVENTS, false)

########## Main Setup ##########
$logger.info "Heroku API Token  ::: #{Settings::HEROKU_API_TOKEN}"
$logger.info "Heroku Apps       ::: #{Settings::HEROKU_APPS.join(', ')}"
$logger.info "Dynos             ::: #{Settings::DYNOS}"
$logger.info "Restart Threshold ::: #{Settings::RESTART_THRESHOLD} MB"
$logger.info "Restart Window    ::: #{Settings::RESTART_WINDOW} seconds"
$logger.info "Log All Events    ::: #{Settings::LOG_ALL_EVENTS}"

Settings::HEROKU_APPS.each do |app|
  Whacamole.configure(app) do |config|
    config.api_token = Settings::HEROKU_API_TOKEN
    config.event_handler = app_event_handler(app)
    config.dynos = Settings::DYNOS
    config.restart_threshold = Settings::RESTART_THRESHOLD
    config.restart_window = Settings::RESTART_WINDOW
  end
end
