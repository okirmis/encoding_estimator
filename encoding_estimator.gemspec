# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'encoding_estimator/version'

Gem::Specification.new do |spec|
  spec.name          = 'encoding_estimator'
  spec.version       = EncodingEstimator::VERSION
  spec.authors       = ['Oskar Kirmis']
  spec.email         = ['kirmis@st.ovgu.de']

  spec.summary       = %q{Detect encoding of an input string using character count statistics.}
  spec.description   = %q{Detect encoding of an input string using character count statistics.}
  spec.homepage      = 'https://git.iftrue.de'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'

  spec.add_dependency 'htmlentities', '>= 4.3.0'
  spec.add_dependency 'json'
end
