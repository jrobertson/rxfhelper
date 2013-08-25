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

end
