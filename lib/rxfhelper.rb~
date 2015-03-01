#!/usr/bin/env ruby

# file: rxfhelper.rb

require 'open-uri'

class URL

  def self.join(*a)
    a.map {|x| x.sub(/(?:^\/|\/$)/,'') }.join '/'
  end
end


# Read XML File Helper
#
class RXFHelper

  def self.read(x, opt={})   

    if x.strip[/^</] then
      
      [x, :xml]
      
    elsif x.lines.length == 1 then
      
      if x.strip[/^https?:\/\//] then

        [open(x, 'UserAgent' => 'RXFHelper',\
          http_basic_authentication: [opt[:username], opt[:password]]).read, :url]

      elsif x[/^file:\/\//] or File.exists?(x) then
        [File.read(File.expand_path(x.sub(%r{^file://}, ''))), :file]
      else
        [x, :unknown]
      end
      
    else

      [x, :unknown]
    end
  end

  def self.absolute_url(page_url, item_location)

    case item_location

      when /^\//
        URL.join page_url[/https?:\/\/[^\/]+/], item_location

      when /^http/
        item_location

      else
        File.join page_url[/.*\//], item_location
    end
  end  
end
