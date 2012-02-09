#!/usr/bin/env ruby

# file: rxfhelper.rb

require 'open-uri'

# Read XML File Helper
#
class RXFHelper

  def self.read(x)   
    if x.strip[/^</] then
      x
    elsif x[/https?:\/\//] then
      open(x, 'UserAgent' => 'RXFHelper').read  
    else
      File.open(x, 'r').read
    end
  end

end
