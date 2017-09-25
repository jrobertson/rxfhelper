#!/usr/bin/env ruby

# file: rxfhelper.rb

require 'gpd-request'

class URL

  def self.join(*a)
    a.map {|x| x.sub(/(?:^\/|\/$)/,'') }.join '/'
  end
end


class RXFHelperException < Exception
end

# Read XML File Helper
#
class RXFHelper

  def self.read(x, opt={})   

    raise RXFHelperException, 'nil found, expected a string' if x.nil?
    
    if x.class.to_s =~ /Rexle$/ then
      
      [x.xml, :rexle]
      
    elsif x.strip[/^<(\?xml|[^\?])/] then
      
      [x, :xml]
      
    elsif x.lines.length == 1 then
      
      if x[/\bhttps?:\/\//] then
        
        r = GPDRequest.new(opt[:username], opt[:password]).get(x)
        
        case r.code
        when '404'          
          raise(RXFHelperException, "404 %s not found" % x)
        when '401'          
          raise(RXFHelperException, "401 %s unauthorized access" % x)        
        end
        
        [r.body, :url]

      elsif x[/^file:\/\//] or File.exists?(x) then
        [File.read(File.expand_path(x.sub(%r{^file://}, ''))), :file]
      elsif x =~ /\s/
        [x, :text]
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
