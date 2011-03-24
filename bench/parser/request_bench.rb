base = File.expand_path(File.dirname(__FILE__) + '/../../lib')
require base + '/http_tools'
require 'benchmark'

request = "GET / HTTP/1.1\r\nHost: example.com\r\nUser-Agent: Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_5_8; en-gb) AppleWebKit/533.16 (KHTML, like Gecko) Version/5.0 Safari/533.16\r\nAccept: application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5\r\nAccept-Language: en-gb\r\nAccept-Encoding: gzip, deflate\r\nConnection: keep-alive\r\n\r\n"

Benchmark.bm(41) do |x|
  x.report("HTTPTools::Parser") do
    10_000.times do
       HTTPTools::Parser.new << request
    end
  end
  
  x.report("HTTPTools::Parser (reset)") do
    parser = HTTPTools::Parser.new
    10_000.times do
       parser << request
       parser.reset
    end
  end
  
  x.report("HTTPTools::Parser (reset, with callbacks)") do
    parser = HTTPTools::Parser.new
    parser.on(:headers) {}
    10_000.times do
       parser << request
       parser.reset
    end
  end
  
  begin
    require 'rubygems'
    require 'http/parser'
    x.report("Http::Parser") do
      10_000.times do
        parser = Http::Parser.new
        parser.on_headers_complete = Proc.new {}
        parser.on_message_complete = Proc.new {}
        parser << request
      end
    end
  rescue LoadError
  end
  
  begin
    require 'rubygems'
    require 'http11'
    x.report("Mongrel::HttpParser") do
      10_000.times do
        Mongrel::HttpParser.new.execute({}, request.dup, 0)
      end
    end
  rescue LoadError
  end
end