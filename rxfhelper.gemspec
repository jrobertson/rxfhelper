Gem::Specification.new do |s|
  s.name = 'rxfhelper'
  s.version = '0.7.1'
  s.summary = 'Helpful library for primarily reading the contents of a ' + 
      'file either from an HTTP address, local file, or DRb file system.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/rxfhelper.rb']
  s.add_runtime_dependency('rsc', '~> 0.3', '>=0.3.2')
  s.add_runtime_dependency('gpd-request', '~> 0.3', '>=0.3.0')
  s.add_runtime_dependency('drb_fileclient', '~> 0.2', '>=0.2.0')
  s.signing_key = '../privatekeys/rxfhelper.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/rxfhelper'
  s.required_ruby_version = '>= 2.1.2'
end
