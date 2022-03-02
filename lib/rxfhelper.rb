#!/usr/bin/env ruby

# file: rxfhelper.rb

require 'rsc'
require 'drb_reg_client'
require 'remote_dwsregistry'
require 'rxfileio'



# Setup: Add a local DNS entry called *reg.lookup* if you are planning on
#        using the Registry feaure to look up objects automatically.

module RXFHelperModule
  include RXFileIOModule

  def FileX.exists?(s)  RXFHelper.exists?(s)   end
  def FileX.filetype(x) RXFHelper.filetype(s)  end

end

=begin
  # 20th February 2022 # JR
  # the following code has been commented out because it appears to be redundant
class URL

  def self.join(*a)
    a.map {|x| x.sub(/(?:^\/|\/$)/,'') }.join '/'
  end
end
=end

class RXFHelperException < Exception
end

# Read XML File Helper
#
class RXFHelper < RXFileIO
  using ColouredText


  def self.call(s)

    if s =~ /=/ then

      uri, val = s.split(/=/)
      self.set uri, val

    else

      self.get s

    end

  end

  def self.exists?(filename)

    type = self.filetype(filename)

    filex = case type
    when :file
      File
    when :dfs
      DfsFile
    when :sqlite
      host = filename[/(?<=^sqlite:\/\/)[^\/]+/]
      DRbObject.new nil, "druby://#{host}:57000"
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
    when /^sqlite:\/\//
      :sqlite
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


  def self.get(x)

    raise RXFHelperException, 'nil found, expected a string' if x.nil?

    if x[/^rse:\/\//] then

      RSC.new.get x

    elsif x[/^reg:\/\//] then

      r = DRbRegClient.new.get(x)
      r.is_a?(Rexle::Element::Value) ? r.to_s : r

    else
      [x, :unknown]
    end

  end

  # used by self.read
  #
  def self.objectize(contents)

    doctype = contents.lines.first[/(?<=^<\?)\w+/]
    reg = RemoteDwsRegistry.new domain: 'reg.lookup', port: '9292'
    r = reg.get_key 'hkey_gems/doctype/' + doctype

    return contents unless r

    require r.text('require')

    obj = Object.const_get(r.text('class')).new
    obj.import contents
    obj
  end


  def self.read(x, h={})

    opt = {debug: false, auto: false}.merge(h)

    debug = opt[:debug]

    puts 'x: ' + x.inspect if opt[:debug]
    raise RXFHelperException, 'nil found, expected a string' if x.nil?

    if x.class.to_s =~ /Rexle$/ then

      [x.xml, :rexle]

    elsif x.strip[/^<(\?xml|[^\?])/] then

      [x, :xml]

    elsif x.lines.length == 1 then

      puts 'x.lines == 1'.info if debug

      if x[/^https?:\/\//] then

        puts 'before GPDRequest'.info if debug

        r = if opt[:username] and opt[:password] then
          GPDRequest.new(opt[:username], opt[:password]).get(x)
        else
          response = RestClient.get(x)
        end

        case r.code
        when '404'
          raise(RXFHelperException, "404 %s not found" % x)
        when '401'
          raise(RXFHelperException, "401 %s unauthorized access" % x)
        end

        obj = opt[:auto] ? objectize(r.body) :   r.body

        [obj, :url]

      elsif  x[/^dfs:\/\//] then

        r = DfsFile.read(x).force_encoding('UTF-8')
        [opt[:auto] ? objectize(r) : r, :dfs]

      elsif  x[/^ftp:\/\//] then

        [MyMediaFTP.read(x), :ftp]

      elsif x[/^rse:\/\//] then

         [RSC.new.get(x), :rse]

      elsif x[/^reg:\/\//] then

        r = DRbRegClient.new.get(x)
        [r.is_a?(Rexle::Element::Value) ? r.to_s : r, :reg]

      elsif x[/^file:\/\//] or File.exists?(x) then

        puts 'RXFHelper.read before File.read' if opt[:debug]
        contents = File.read(File.expand_path(x.sub(%r{^file://}, '')))

        puts 'contents2: ' + contents.inspect if opt[:debug]

        puts 'opt: ' + opt.inspect if opt[:debug]

        obj = opt[:auto] ? objectize(contents) :   contents

        [obj, :file]

      elsif x =~ /\s/
        [x, :text]
      elsif DfsFile.exists?(x)
        [DfsFile.read(x).force_encoding('UTF-8'), :dfs]
      else
        [x, :unknown]
      end

    else

      [x, :unknown]
    end
  end

  def self.write(location, s=nil)

    case location
    when /^dfs:\/\//

      DfsFile.write location, s

    when  /^ftp:\/\// then

      MyMediaFTP.write location, s

    when /^rse:\/\//

      RSC.new.post(location, s)

    when /^reg:\/\//

      DRbRegClient.new.set(location, s)

    else

      if DfsFile.exists?(File.dirname(location)) then
        DfsFile.write location, s
      else
        File.write(location, s)
      end

    end

  end

=begin
  # 20th February 2022 # JR
  # the following code has been commented out because it appears to be redundant

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
=end

  def self.post(uri, x=nil)

    raise RXFHelperException, 'nil found, expected a string' if uri.nil?

    if uri[/^rse:\/\//] then
      RSC.new.post uri, x

    elsif uri[/^reg:\/\//]

      DRbRegClient.new.set(uri, x)
    else
      [uri, :unknown]
    end

  end

  def self.set(uri, x=nil)

    raise RXFHelperException, 'nil found, expected a string' if uri.nil?
    puts 'uri: ' + uri.inspect

    if uri[/^rse:\/\//] then
      RSC.new.post uri, x

    elsif uri[/^reg:\/\//]

      DRbRegClient.new.set(uri, x)
    else
      [uri, :unknown]
    end

  end

end
