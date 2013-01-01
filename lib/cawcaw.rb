require "logger"
require "uri"
require "bunnish"

module Cawcaw
end

require "cawcaw/command/hadoop"
require "cawcaw/command/rabbitmq"
require "cawcaw/core/common"

module Cawcaw
  def self.parse_opts(argv)
    return Cawcaw::Core::Common.parse_opts(argv)
  end
  
  def self.logger
    if @logger.nil?
      @logger = (rails_logger || default_logger)
      @logger.formatter = proc { |severity, datetime, progname, msg|
        datetime.strftime("[%Y-%m-%d %H:%M:%S](#{severity})#{msg}\n")
      }
    end
    return @logger
  end

  def self.rails_logger
    (defined?(Rails) && Rails.respond_to?(:logger) && Rails.logger) ||
    (defined?(RAILS_DEFAULT_LOGGER) && RAILS_DEFAULT_LOGGER.respond_to?(:debug) && RAILS_DEFAULT_LOGGER)
  end

  def self.default_logger
    l = Logger.new(STDERR)
    l.level = Logger::INFO
    l
  end

  def self.logger=(logger)
    @logger = logger
  end
end