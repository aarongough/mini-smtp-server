require 'gserver'

class MiniSmtpServer < GServer

  def initialize(port = 2525, host = "127.0.0.1", max_connections = 4, *args)
    super(port, host, max_connections, *args)
  end
  
  def serve(io)
    @data_mode = false
    @message = {:data => ""}
    @connection_active = true
    io.print "220 hello\r\n"
    loop do
      if IO.select([io], nil, nil, 0.1)
	      data = io.readpartial(4096)
	      log("<<< " + data) if(@audit)
	      output = process_line(data)
        log(">>> " + output) unless(output.empty? || !@audit)
	      io.print(output) unless output.empty?
      end
      break if(!@connection_active || io.closed?)
    end
    io.print "221 bye\r\n"
    io.close
    @message[:data].gsub!(/\r\n\Z/, '').gsub!(/\.\Z/, '')
    new_message_event(@message)
  end

  def process_line(line)
    # Handle specific messages from the client
    case line
    when (/^(HELO|EHLO)/)
      return "220 go on...\r\n"
    when (/^QUIT/)
      @connection_active = false
      return ""
    when (/^MAIL FROM\:/)
      @message[:from] = line.gsub(/^MAIL FROM\:/, '').strip
      return "220 OK\r\n"
    when (/^RCPT TO\:/)
      @message[:to] = line.gsub(/^RCPT TO\:/, '').strip
      return "220 OK\r\n"
    when (/^DATA/)
      @data_mode = true
      return "354 Enter message, ending with \".\" on a line by itself\r\n"
    end
    
    # If we are in data mode and the entire message consists
    # solely of a period on a line by itself then we
    # are being told to exit data mode
    if((@data_mode) && (line.chomp =~ /^\.$/))
      @message[:data] += line
      @data_mode = false
      return "220 OK\r\n"
    end
    
    # If we are in date mode then we need to add
    # the new data to the message
    if(@data_mode)
      @message[:data] += line
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