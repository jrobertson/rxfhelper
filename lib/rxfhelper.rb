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

  def self.read(x)   
    
    if x.strip[/^</] then
      [x, :xml]
    elsif x[/https?:\/\//] then
      [open(x, 'UserAgent' => 'RXFHelper'){|x| x.read}, :url]
    elsif x[/^file:\/\//] or File.exists?(x) then
      [File.expand_path(File.read(x.sub(%r{^file://}, ''))), :file]
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