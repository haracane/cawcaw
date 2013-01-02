require "spec_helper"

describe "bin/cawcaw rabbitmq queue-count" do
  before :all do
    system("bunnish delete cawcaw-test-queue")
    system("echo \"foo\nbar\nbaz\" | bunnish publish cawcaw-test-queue")
  end
  it "should output rabbitmq queue-count config" do
    result = `#{Cawcaw::RUBY_CMD} #{Cawcaw::BIN_DIR}/cawcaw rabbitmq queue-count cawcaw-test-queue config`
    hash = {}
    result.split(/\r?\n/).each do |line|
      record = line.split(/ /, 2)
      hash[record[0]] = record[1]
    end
    result = hash
    # result.each_pair do |key, val| STDERR.puts "result[#{key.inspect}].should == #{val.inspect}" end
    result["graph_title"].should == "Queue count"
    result["graph_args"].should == "--base 1000"
    result["graph_vlabel"].should == "messages"
    result["graph_category"].should == "rabbitmq"
    result["graph_info"].should == "Queue count"
    result["cawcaw_test_queue.label"].should == "cawcaw-test-queue"
    result["cawcaw_test_queue.info"].should == "cawcaw-test-queue queue count"
    result["cawcaw_test_queue.draw"].should == "AREA"
    result["cawcaw_test_queue.warning"].should == "5000000"
    result["cawcaw_test_queue.critical"].should == "5000000"
  end

  it "should output rabbitmq queue-count value" do
    result = `#{Cawcaw::RUBY_CMD} #{Cawcaw::BIN_DIR}/cawcaw rabbitmq queue-count cawcaw-test-queue`
    hash = {}
    result.split(/\r?\n/).each do |line|
      record = line.split(/ /, 2)
      hash[record[0]] = record[1]
    end
    result = hash
    # result.each_pair do |key, val| STDERR.puts "result[#{key.inspect}].should == #{val.inspect}" end
    result["cawcaw_test_queue.value"].should == "3"
  end
end
