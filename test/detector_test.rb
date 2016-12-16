require_relative '../lib/encest/detector'

d = EncodingEstimator::Detector.new EncodingEstimator::Conversion.generate(['utf-8', 'iso-8859-1'] ), [:de, :en]
puts d.detect( File.read( ARGV[ 0 ] ) ).key