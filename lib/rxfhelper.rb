#!/usr/bin/env ruby

# file: rxfhelper.rb

require 'rsc'
require 'gpd-request'
require 'drb_fileclient'


module RXFHelperModule
  
  class FileX
    
    def self.exists?(filename)
      
      type = self.filetype(filename)
      
      filex = case type
      when :file
        File
      when :dfs
        DfsFile
      else
        nil
      end

      return nil unless filex
      
      filex.exists? filename
      
    end
    
    def self.filetype(x)
      
      return :string if x.lines.length > 1
      
      case x
      when /^rse:\/\//
        :rse
      when /^https?:\/\//
        :http
      when /^dfs:\/\//
        :dfs        
      when /^file:\/\//
        :file
      else
        
        if File.exists?(x) then
          :file
        else
          :text
        end
        
      end
    end
    
    def self.read(x)      RXFHelper.read(x).first  end
    def self.write(x, s)  RXFHelper.write(x, s)    end      
    
  end
end

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
        
        [DfsFile.read(x), :dfs]        
                
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
      
      DfsFile.write filename, s
      
    when /^rse:\/\//
      RSC.new.post(uri, s)
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
  
  def self.post(uri, x=nil)   

    raise RXFHelperException, 'nil found, expected a string' if uri.nil?    
          
    if uri[/^rse:\/\//] then
      RSC.new.post uri, x
    else
      [uri, :unknown]
    end

  end  
end
