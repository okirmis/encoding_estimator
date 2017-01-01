# Tutorials

Learn how to use this gem in real world scenarios.

## Loading files of unknown encoding (non-interactive)

Let's say you have the following application which just reads a CSV file and prints the first line:

```ruby
require 'csv'

content = File.read( ARGV[ 0 ], encoding: 'utf-8' )
CSV.parse( content ) do |row|
  puts row[ 0 ]
end
```

*Note: yes, you could use `CSV.read` but this is easier to follow for developers not familiar with the `CSV` class. And please, don't use that snippet in production as there is no error handling at all.*


So you want to ensure that the file you read is correctly encoded, because sometimes you may get these files in... let's say "interesting"... encodings, e.g. Windows-1252 in some Excel exports.

Assume that you know that your little tool gets files containing German text encoded either as Windows-1252 or UTF-8. To handle both encodings correctly, we change the tool:

```ruby
require 'csv'
require 'encoding_estimator'

cfg     = { languages: [:de], encodings: [ 'windows-1252' ] }
content = EncodingEstimator.ensure_utf8( File.read( ARGV[ 0 ], encoding: 'utf-8' ), cfg )

CSV.parse( content ) do |row|
  puts row[ 0 ]
end
```
Looking at the 4th line, you might think: wait, there's only Windows-1252 listed in the configuration. What about UTF-8? UTF-8 is included by default, you can disable it via `include_default: false` in the configuration.

The `EncodingEstimator.ensure_utf8` method gives you the input string encoded as whatever the gem detects as the best matching encoding.

## Loading files of unknown encoding (interactive)

We continue using the code snippet above. But this time, we don't use `EncodingEstimator.ensure_utf8` to convert the string automatically, but we want to let the user decide, if the detection was correct. Therefore, the `EncodingEstimator.detect` method is very useful. It does not convert the input, but gives you a detection result. It looks like that:

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
  content = detection.perform content if STDIN.readline.strip == 'y'
end

CSV.parse( content ) do |row|
  puts row[ 0 ]
end
```