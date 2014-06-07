# -- General ------------------------------------------------------------------

ROOT = File.expand_path('../../', __FILE__)
$LOAD_PATH.unshift File.join(ROOT, 'lib')

ENV['RACK_ENV'] ||= 'production'
ENV['DATABASE_URL'] ||= "postgres://localhost/trunk_cocoapods_org_#{ENV['RACK_ENV']}"

if ENV['RACK_ENV'] == 'development'
  require 'sinatra/reloader'
end

require 'i18n'
I18n.enforce_available_locales = false
require 'active_support/core_ext/numeric/time'
require 'active_support/core_ext/date/calculations'

require 'active_support/core_ext/time/zones'
require 'active_support/core_ext/time/calculations'
Time.zone = 'UTC'

# Explicitly load the C-ext version.
require 'json/ext'

# -- Logging ------------------------------------------------------------------

require 'logger'
require 'fileutils'

if ENV['METRICS_APP_LOG_TO_STDOUT']
  STDOUT.sync = true
  STDERR.sync = true
  METRICS_APP_LOGGER = Logger.new(STDOUT)
  METRICS_APP_LOGGER.level = Logger::INFO
else
  FileUtils.mkdir_p(File.join(ROOT, 'log'))
  METRICS_APP_LOG_FILE = File.new(File.join(ROOT, "log/#{ENV['RACK_ENV']}.log"), 'a+')
  METRICS_APP_LOG_FILE.sync = true
  METRICS_APP_LOGGER = Logger.new(METRICS_APP_LOG_FILE)
  METRICS_APP_LOGGER.level = Logger::DEBUG
end

# -- Database -----------------------------------------------------------------

require 'sequel'
require 'pg'

db_loggers = []
db_loggers << METRICS_APP_LOGGER # TODO: For now also enable DB logger in production. unless ENV['RACK_ENV'] == 'production'
DB = Sequel.connect(ENV['DATABASE_URL'], :loggers => db_loggers)
DB.timezone = :utc
Sequel.extension :core_extensions, :migration

class << DB
  # Save point is needed in testing, because tests already run in a
  # transaction, which means the transaction would be re-used and we can't test
  # whether or the transaction has been rolled back.
  #
  # This is overridden in tests to do add a save point.
  alias_method :test_safe_transaction, :transaction
end

# -- Console ------------------------------------------------------------------

if defined?(IRB)
  puts "[!] Loading `#{ENV['RACK_ENV']}' environment."
  Dir.chdir(ROOT) do
    Dir.glob('app/models/*.rb').each do |model|
      require model[0..-4]
    end
  end
end
