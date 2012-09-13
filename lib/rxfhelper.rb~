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
      [open(x, 'UserAgent' => 'RXFHelper').read, :url]
    else
      [File.open(x, 'r').read, :file]
    end
  end

end
