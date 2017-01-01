# Loading files of unknown encoding (interactive)

We continue using the code snippet from [the non-interactive loading](./noninteractive.md). But this time, we don't use `EncodingEstimator.ensure_utf8` to convert the string automatically, but we want to let the user decide, if the detection was correct. Therefore, the `EncodingEstimator.detect` method is very useful. It does not convert the input, but gives you a detection result. It looks like that:

```ruby
cfg       = { languages: [:de], encodings: [ 'windows-1252' ] }
detection = EncodingEstimator.detect( input, cfg )

puts detection.result.encoding # e.g. 'utf-8' or 'windows-1252'
```

The `detect` method returns an `EncodingEstimator::Detection` instance. It contains information on how likely which encoding is. Using `EncodingEstimator::Detection.result` you will get the most probable conversion represented as an `EncodingEstimator::Conversion` object. So let's check the encoding we just detected:

```ruby
require 'csv'
require 'encoding_estimator'

cfg       = { languages: [:de], encodings: [ 'windows-1252' ] }
content   = File.read( ARGV[ 0 ], encoding: 'utf-8' )
detection = EncodingEstimator.detect( content, cfg )

# Not the default encoding?
unless detection.result.equals? EncodingEstimator::Conversion.default
  puts "Detected encoding #{detection.result.encoding} on #{ARGV[0]}."
  puts "Is this correct? (y/n)"

  # If the user accepts, decode as the detected encoding
  content = detection.result.perform content if STDIN.readline.strip == 'y'
end

CSV.parse( content ) do |row|
  puts row[ 0 ]
end
```