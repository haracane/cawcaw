module Cawcaw
  module Command
    module Rabbitmq::QueueCount
      def self.run(argv, input_stream=$stdin, output_stream=$stdout)
        
        params = Cawcaw.parse_opts(argv)
        params.update(Bunnish.parse_opts(argv))
        
        params[:graph_title] ||= "Queue count"
        params[:graph_args] ||= "--base 1000"
        params[:graph_vlabel] ||= "messages"
        params[:graph_category] ||= "rabbitmq"
        params[:graph_info] ||= "Queue count"
        
        params[:label_warning] ||= 5000000
        params[:label_critical] ||= 5000000
        
        host = params[:host]
        port = params[:port]
        user = params[:user]
        password = params[:password]
        durable = params[:durable]
        
        if params[:stdin_flag]
          queue_names = []
          while line = input_stream.gets
            line.chomp!
            queue_names.push line
          end
        else
          queue_names = argv.shift
          queue_names = queue_names.split(/,/) unless queue_names.nil?
          queue_names ||= []
          queue_names.delete("")
        end
        command = argv.shift
        
        if queue_names == []
          Cawcaw.logger.error("queue-name is not set")
          return 1
        end
        
        case command
        when "autoconf"
          output_stream.puts "yes"
        when "config"
          output_stream.puts <<-EOF
graph_title #{params[:graph_title]}
graph_args #{params[:graph_args]}
graph_vlabel #{params[:graph_vlabel]}
graph_category #{params[:graph_category]}
graph_info #{params[:graph_info]}
          EOF
          
          label_draw = "AREA"
          
          queue_names.each do |queue_name|
            label = queue_name.gsub(/[^a-zA-Z0-9]/, "_").downcase
            output_stream.puts <<-EOF
#{label}.label #{queue_name}
#{label}.info #{queue_name} queue count
#{label}.draw #{label_draw}
#{label}.warning #{params[:label_warning]}
#{label}.critical #{params[:label_critical]}
          EOF
            label_draw = "STACK"
          end
        else
          bunny = Bunny.new(:logging => false, :spec => '09', :host=>host, :port=>port, :user=>user, :pass=>password)
          
          # start a communication session with the amqp server
          bunny.start
          
          queue_message_counts = bunny.queue_message_counts(queue_names, :durable=>durable)
          
          queue_message_counts.each_pair do |queue_name, message_count|
            label = queue_name.gsub(/[^a-zA-Z0-9]/, "_").downcase
            output_stream.puts "#{label}.value #{message_count}"
          end
          # Close client
          bunny.stop
          
        end
        
        return 0
      end
    end
  end
end
