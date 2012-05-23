require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class TestSmtpServer < MiniSmtpServer
  def new_message_event(message_hash)
    $messages << message_hash
  end
end

$example_mail = <<EOD
From: Your Name <your@mail.address>
To: Destination Address <someone@example.com>
Subject: test message
Date: Sat, 23 Jun 2001 16:26:43 +0900
Message-Id: <unique.message.id.string@example.com>

This is a test message.
EOD

class MiniSmtpServerTest < Test::Unit::TestCase
  
  def setup
    $messages = []
    @server = TestSmtpServer.new
    @server.start
  end
  
  test "should receive new message" do
    assert_difference("$messages.length") do
      send_mail
    end
  end
  
  test "should receive 10 new messages" do
    assert_difference("$messages.length", 10) do
      10.times do
        send_mail
      end
    end
  end

  test "should receive 2 new messages on a single connection" do
    assert_difference("$messages.length", 2) do
      send_multiple_mails($example_mail, "smtp@test.com", "some1@test.com", 2)
    end
  end
  
  test "should store email from address in hash" do
    assert_difference("$messages.length") do
      send_mail
    end
    assert_equal "<smtp@test.com>", $messages.first[:from]
  end
  
  test "should store email to address in hash" do
    assert_difference("$messages.length") do
      send_mail
    end
    assert_equal "<some1@test.com>", $messages.first[:to]
  end
  
  test "should store email body in message hash" do
    assert_difference("$messages.length") do
      send_mail
    end
    assert_equal $example_mail.gsub("\n", "\r\n"), $messages.first[:data]
  end
  
  def teardown
    @server.shutdown
    while(@server.connections > 0)
    end
    @server.stop
    @server.join
  end
  
  private
  
    def send_mail(message = $example_mail, from_address = "smtp@test.com", to_address = "some1@test.com")
      Net::SMTP.start('127.0.0.1', 2525) do |smtp|
        smtp.send_message(message, from_address, to_address)
        smtp.finish
        sleep 0.01
      end
    end

    def send_multiple_mails(message = $example_mail, from_address = "smtp@test.com", to_address = "some1@test.com", count = 1)
      Net::SMTP.start('127.0.0.1', 2525) do |smtp|
        msg_num = 0
        while (msg_num < count) do
          smtp.send_message(message, from_address, to_address)
          msg_num += 1
        end
        smtp.finish
        sleep 0.01
      end
    end
  
end