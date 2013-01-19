if RUBY_VERSION <= '1.8.7'
else
  require "simplecov"
  require "simplecov-rcov"
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
  SimpleCov.start
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require "rspec"
require "cawcaw"
require "tempfile"

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  
end

module Cawcaw
  CAWCAW_HOME = File.expand_path(File.dirname(__FILE__) + "/..")
  REDIRECT = {}
end

Cawcaw.logger = Logger.new(STDERR)
ActiveRecord::Base.logger = Cawcaw.logger
if File.exist?('/tmp/cawcaw.debug') then
  Cawcaw.logger.level = Logger::DEBUG
  Cawcaw::REDIRECT[:stdout] = nil
  Cawcaw::REDIRECT[:stderr] = nil
else
  Cawcaw.logger.level = Logger::ERROR
  Cawcaw::REDIRECT[:stdout] = "> /dev/null"
  Cawcaw::REDIRECT[:stderr] = "2> /dev/null"
end

class CawcawName < ActiveRecord::Base
end

