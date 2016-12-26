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
  spec.description   = %q{This gem allows you to detect the encoding of strings/files based on their content. This can be useful if you need to load data from sources with unknown encodings. The gem uses character distribution statistics to check which encoding is the one that gives you the best results.}
  spec.homepage      = 'https://git.iftrue.de/okirmis/encoding_estimator'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 1.9.3'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'

  spec.add_dependency 'htmlentities', '~> 4.3'
  spec.add_dependency 'json', '~> 2.0'
  spec.add_dependency 'slop', '~> 4.4'
end
