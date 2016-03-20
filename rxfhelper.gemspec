Gem::Specification.new do |s|
  s.name = 'rxfhelper'
  s.version = '0.3.0'
  s.summary = 'rxfhelper'
  s.authors = ['James Robertson']
  s.files = Dir['lib/rxfhelper.rb']
  s.add_runtime_dependency('gpd-request', '~> 0.2', '>=0.2.6')
  s.signing_key = '../privatekeys/rxfhelper.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@r0bertson.co.uk'
  s.homepage = 'https://github.com/jrobertson/rxfhelper'
  s.required_ruby_version = '>= 2.1.2'
end
