require 'gserver'

class MiniSmtpServer < GServer

  def initialize(port = 2525, host = "127.0.0.1", max_connections = 4, *args)
    super(port, host, max_connections, *args)
  end
  
  def serve(io)
    Thread.current[:data_mode] = false
    Thread.current[:message] = {:data => ""}
    Thread.current[:connection_active] = true
    io.print "220 hello\r\n"
    loop do
      if IO.select([io], nil, nil, 0.1)
	      data = io.readpartial(4096)
	      log("<<< " + data) if(@audit)
	      output = process_line(data)
        log(">>> " + output) if(@audit && !output.empty?)
	      io.print(output) unless output.empty?
      end
      break if(!Thread.current[:connection_active] || io.closed?)
    end
    io.print "221 bye\r\n"
    io.close
    Thread.current[:message][:data].gsub!(/\r\n\Z/, '').gsub!(/\.\Z/, '')
    new_message_event(Thread.current[:message])
  end

  def process_line(line)
    # Handle specific messages from the client
    case line
    when (/^(HELO|EHLO)/)
      return "250 go on...\r\n"
    when (/^QUIT/)
      Thread.current[:connection_active] = false
      return ""
    when (/^MAIL FROM\:/)
      Thread.current[:message][:from] = line.gsub(/^MAIL FROM\:/, '').strip
      return "250 OK\r\n"
    when (/^RCPT TO\:/)
      Thread.current[:message][:to] = line.gsub(/^RCPT TO\:/, '').strip
      return "250 OK\r\n"
    when (/^DATA/)
      Thread.current[:data_mode] = true
      return "354 Enter message, ending with \".\" on a line by itself\r\n"
    end
    
    # If we are in data mode and the entire message consists
    # solely of a period on a line by itself then we
    # are being told to exit data mode
    if((Thread.current[:data_mode]) && (line.chomp =~ /^\.$/))
      Thread.current[:message][:data] += line
      Thread.current[:data_mode] = false
      return "250 OK\r\n"
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
  end
end
