#!/usr/bin/env ruby

# file: rxfhelper.rb

require 'rsc'
require 'gpd-request'
require 'drb_fileclient'


module RXFHelperModule
  
  class FileX

    def self.chdir(s)  RXFHelper.chdir(s)   end

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
    
    def self.exist?(filename)
      exists? filename
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

    def self.cp(s, s2)    RXFHelper.cp(s, s2)      end
    def self.ls(s)        RXFHelper.ls(s)          end
    def self.mkdir(s)     RXFHelper.mkdir(s)       end
    def self.mkdir_p(s)   RXFHelper.mkdir_p(s)     end
    def self.mv(s, s2)    RXFHelper.mv(s, s2)      end            
    def self.pwd()        RXFHelper.pwd()          end    
    def self.read(x)      RXFHelper.read(x).first  end
    def self.rm(s)        RXFHelper.rm(s)          end
    def self.write(x, s)  RXFHelper.write(x, s)    end
    def self.zip(s, a)    RXFHelper.zip(s, a)    end

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
  
  @fs = :local
  
  def self.cp(s1, s2)
    DfsFile.cp(s1, s2)
  end
  
  def self.chdir(x)
    
    if x[/^file:\/\//] or File.exists?(File.dirname(x)) then
      @fs = :local
      FileUtils.chdir x
    elsif x[/^dfs:\/\//]
      @fs = :dfs
      DfsFile.chdir x
    end
    
  end
  
  def self.get(x)   

    raise RXFHelperException, 'nil found, expected a string' if x.nil?    
          
    if x[/^rse:\/\//] then
      RSC.new.get x
    else
      [x, :unknown]
    end

  end
  
  def self.ls(x='*')
    
    if x[/^file:\/\//] or File.exists?(File.dirname(x)) then
      Dir[x]
    elsif x[/^dfs:\/\//]
      DfsFile.ls x
    end    
    
  end
  
  def self.mkdir(x)
    
    if x[/^file:\/\//] or File.exists?(File.dirname(x)) then
      FileUtils.mkdir x
    elsif x[/^dfs:\/\//]
      DfsFile.mkdir x
    end
    
  end
  
  def self.mkdir_p(x)
    
    if x[/^dfs:\/\//] or @fs == :dfs then
      DfsFile.mkdir_p x
    else
      FileUtils.mkdir_p x      
    end
    
  end
  
  def self.mv(s1, s2)
    DfsFile.mv(s1, s2)
  end  
  
  def self.pwd()
    
    DfsFile.pwd
    
  end  
  
  def self.read(x, h={})   
    
    opt = {debug: false, auto: true}.merge(h)

    puts 'x: ' + x.inspect if opt[:debug]
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
        
        puts 'RXFHelper.read before File.read' if opt[:debug]
        contents = File.read(File.expand_path(x.sub(%r{^file://}, '')))
        
        puts 'contents: ' + contents.inspect if opt[:debug]
        
        obj = if (contents.lines.first =~ /<?dynarex /) \
            and opt[:auto] then
        
          dx = Dynarex.new(debug: opt[:debug])
          dx.import contents
          
        else
          
          contents
          
        end
        
        [obj, :file]
        
      elsif x =~ /\s/
        [x, :text]
      elsif DfsFile.exists?(x)
        [DfsFile.read(x), :dfs]
      else
        [x, :unknown]
      end
      
    else

      [x, :unknown]
    end
  end
  
  def self.rm(filename)
    DfsFile.rm filename
  end
  
  def self.write(location, s=nil)
    
    case location
    when /^dfs:\/\//
      
      DfsFile.write location, s
      
    when /^rse:\/\//
      
      RSC.new.post(location, s)
      
    else
      
      if DfsFile.exists?(File.dirname(location)) then
        DfsFile.write location, s
      else
        File.write(location, s)
      end
      
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

  def self.zip(filename, a)
    DfsFile.zip(filename, a)
  end    
end
