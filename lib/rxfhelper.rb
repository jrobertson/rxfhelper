#!/usr/bin/env ruby

# file: rxfhelper.rb

require 'gpd-request'

class URL

  def self.join(*a)
    a.map {|x| x.sub(/(?:^\/|\/$)/,'') }.join '/'
  end
end


# Read XML File Helper
#
class RXFHelper

  def self.read(x, opt={})   

    if x.strip[/^<(\?xml|[^\?])/] then
      
      [x, :xml]
      
    elsif x.lines.length == 1 then
      
      if x.strip[/^https?:\/\//] then
        
        r = GPDRequest.new(opt[:username], opt[:password]).get(x)
        raise("RXFHelper: 404 %s not found" % x)  if r.code == '404'
        [r.body, :url]

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