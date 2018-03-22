#!/usr/bin/env ruby

# file: rxfhelper.rb

require 'rsc'
require 'gpd-request'
require 'drb_fileclient'

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
  
  def self.get(x)   

    raise RXFHelperException, 'nil found, expected a string' if x.nil?    
          
    if x[/^rse:\/\//] then
      RSC.new.get x
    else
      [x, :unknown]
    end

  end    

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
        
      elsif  x[/^dfs:\/\//] then
        
        host = x[/(?<=^dfs:\/\/)[^\/:]+/]
        port = x[/(?<=^dfs:\/\/)[^:]+:(\d+)/,1]  || '61010'
        filename = x[/(?<=^dfs:\/\/)[^\/]+\/(.*)/,1]

        # read the file using the drb_fileclient
        file = DRbFileClient.new host: host, port: port
        
        [file.read(filename), :dfs]        
                
      elsif x[/^rse:\/\//] then
         [RSC.new.get(x), :rse]
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
  
  def self.write(uri, s=nil)
    
    case uri
    when /^dfs:\/\//
      
      host = uri[/(?<=^dfs:\/\/)[^\/:]+/]
      port = uri[/(?<=^dfs:\/\/)[^:]+:(\d+)/,1]  || '61010'
      filename = uri[/(?<=^dfs:\/\/)[^\/]+\/(.*)/,1]

      # write the file using the drb_fileclient
      file = DRbFileClient.new host: host, port: port
      file.write filename, s
      
    when /^rse:\/\//
      RSC.new.post(uri)
    else
      File.write(uri, s)
    end
  end
  
  def self.writeable?(source)

    return false if source.lines.length > 1
    
    if not source =~ /:\/\// then
      
      return true if File.exists? source
      
    else
      
      return true if source =~ /^dfs:/
      
    end
    
    return false
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
  
  def self.post(x)   

    raise RXFHelperException, 'nil found, expected a string' if x.nil?    
          
    if x[/^rse:\/\//] then
      RSC.new.post x
    else
      [x, :unknown]
    end

  end  
end
