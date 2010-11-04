require 'gserver'

class MiniSmtpServer < GServer

  def initialize(port = 2525, host = "127.0.0.1", max_responses = 0, *args)
    @max_responses = max_responses
    @responses = 0
    super(port, host, *args)
  end
  
  def serve(io)
    Thread.current[:data_mode] = false
    Thread.current[:message] = {:data => ""}
    Thread.current[:state] = :active
    io.print "220 hello\r\n"
    loop do
      if IO.select([io], nil, nil, 0.1)
	      data = io.readpartial(4096)
	      io.print(process_line(data))
      end
      break if((Thread.current[:state] == :inactive) || io.closed?)
    end
    io.print "221 bye\r\n"
    io.close
    new_message_event(Thread.current[:message])
    @responses += 1
    stop if(@responses == @max_responses)
  end

  def process_line(line)
    # Handle specific messages from the client
    case line
    when (/^(HELO|EHLO)/)
      return "220 go on...\r\n"
    when (/^QUIT/)
      Thread.current[:state] = :inactive
      return ""
    when (/^MAIL FROM\:/)
      Thread.current[:message][:from] = line.gsub(/^MAIL FROM\:/, '').strip
      return "220 OK\r\n"
    when (/^RCPT TO\:/)
      Thread.current[:message][:to] = line.gsub(/^RCPT TO\:/, '').strip
      return "220 OK\r\n"
    when (/^DATA/)
      Thread.current[:data_mode] = true
      return "354 Enter message, ending with \".\" on a line by itself\r\n"
    end
    
    # If we are in data mode and the entire message consists
    # solely of a period on a line by itself then we
    # are being told to exit data mode
    if((Thread.current[:data_mode]) && (line.chomp =~ /^.$/))
      Thread.current[:data_mode] = false
      return "220 OK\r\n"
    end
    
    # If we are in date mode then we need to add
    # the new data to the message
    if(Thread.current[:data_mode])
      Thread.current[:message][:data] += line
      return ""
    else
      # If we somehow get to this point then
      # we have encountered an error
      return "500 ERROR\r\n"
    end
  end
  
  def new_message_event(message_hash)
    puts message_hash[:data]
  end
end