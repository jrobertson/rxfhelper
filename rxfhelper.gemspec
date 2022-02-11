Gem::Specification.new do |s|
  s.name = 'rxfhelper'
  s.version = '1.3.1'
  s.summary = 'Helpful library for primarily reading the contents of a ' + 
      'file either from an HTTP address, local file, or DRb file system.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/rxfhelper.rb']
  s.add_runtime_dependency('rsc', '~> 0.4', '>=0.4.5')
  # commented out the following lines to resolve circular dependency
  # issue with installing drb_fileclient
  #s.add_runtime_dependency('drb_fileclient', '~> 0.6', '>=0.6.3')
  #s.add_runtime_dependency('dir-to-xml', '~> 1.1', '>=1.1.2')
  s.add_runtime_dependency('mymedia_ftp', '~> 0.3', '>=0.3.3')
  s.add_runtime_dependency('remote_dwsregistry', '~> 0.4', '>=0.4.1')
  s.add_runtime_dependency('drb_reg_client', '~> 0.2', '>=0.2.0')
  s.add_runtime_dependency('rest-client', '~> 2.1', '>=2.1.0')
  s.signing_key = '../privatekeys/rxfhelper.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'digital.robertson@gmail.com'
  s.homepage = 'https://github.com/jrobertson/rxfhelper'
  s.required_ruby_version = '>= 3.0.2'
end
