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
  
  def teardown
    @server.stop
    @server.join
  end
  
  private
  
    def send_mail(message = $example_mail, from_address = "smtp@test.com", to_address = "some1@test.com")
      Net::SMTP.start('127.0.0.1', 2525) do |smtp|
        smtp.send_message(message, from_address, to_address)
      end
    end
  
end