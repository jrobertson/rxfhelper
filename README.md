# Introducing the rxfhelper gem

RXFHelper.read accepts a string containing a URL, a file location, or just a plain string and returns the contents of the location otherwise it just returns the string.

e.g.

    require 'rxfhelper'

    #location = 'http://jamesrobertson.eu/index.html'
    location = '/home/james/index.html'
    #location = '<html><head><title>index</title></head><body><p>test</p></body></html>'
    RXFHelper.read(location)

rxfhelper gem location url reader 
