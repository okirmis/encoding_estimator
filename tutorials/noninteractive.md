# Loading files of unknown encoding (non-interactive)

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