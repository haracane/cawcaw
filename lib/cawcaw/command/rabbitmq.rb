module Cawcaw
  module Command
    module Rabbitmq
      def self.run(argv, input_stream=$stdin, output_stream=$stdout)
        command = argv.shift
        case command
        when "queue-count"
          return Cawcaw::Command::Rabbitmq::QueueCount.run(argv, input_stream, output_stream)
        else
          STDERR.puts "invalid hadoop command: '#{command}'"
        end
      end
    end
  end
end

require "cawcaw/command/rabbitmq/queue_count"
