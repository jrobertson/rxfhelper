#!/usr/bin/env ruby

# file: rxfhelper.rb

require 'open-uri'

# Read XML File Helper
#
class RXFHelper

  attr_reader :to_s

  def initialize(x)
    @to_s = read x
  end

  private

  def read(x)   
    if x.strip[/^</] then
      x
    elsif x[/https?:\/\//] then
      open(x, 'UserAgent' => 'RXFHelper').read  
    else
      File.open(x, 'r').read
    end
  end

  alias to_xml to_s
end
