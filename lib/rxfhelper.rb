#!/usr/bin/env ruby

# file: rxfhelper.rb

require 'open-uri'

# Read XML File Helper
#
class RXFHelper

  def self.read(x)   
    
    if x.strip[/^</] then
      [x, :xml]
    elsif x[/https?:\/\//] then
      [open(x, 'UserAgent' => 'RXFHelper'){|x| x.read}, :url]
    elsif x[/^file:\/\//] or File.exists?(x) then
      [File.open(x.sub(%r{^file://}, ''), 'r').read, :file]
    else
      [nil, :relative_url]
    end
  end

  def self.absolute_url(page_url, item_location)

    case item_location

      when /^\//
        File.join page_url[/https?:\/\/[^\/]+/], item_location

      when /^http/
        item_location

      else
        File.join page_url[/.*\//], item_location
    end
  end  
end
