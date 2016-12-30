require 'simplecov'
require 'simplecov/parallel'

# Enable simplecov and handle Parallel.map(...) correctly
SimpleCov::Parallel.activate
SimpleCov.start

require 'minitest/autorun'
require_relative '../lib/encoding_estimator'

DETECTOR_TEST_ENCODINGS = %w(utf-8 iso-8859-1 utf-16le)
DETECTOR_TEST_LANGS     = [:de, :en, :fr]


class TestDetector < Minitest::Test

  # Define the test order: order by the names of test_* methods.
  # Required because the language model must be built before it
  # can be used (obviously...)
  def self.test_order
    :alpha
  end

  # Test that single threaded and multi threaded versions of language model
  # generation algorithms result in the same model.
  def test_builder__st_vs_mt

    # Multithreaded
    perform_internal_builder 2

    # Single-threaded
    perform_internal_builder nil

    assert(
        JSON.parse( File.read( language_file 2 ) )== JSON.parse(File.read( language_file nil ) )
    )
  end

  private

  # Get the language file path
  #
  # @param [Integer] num_cores Get the language file for the number of cores the generator used
  # @return [String] Path to the language file for the given number of cores
  def language_file( num_cores )
    "#{File.expand_path( File.dirname(__FILE__) )}/samples/lang-de-#{num_cores.nil? ? 'st' : num_cores}.json"
  end

  # Perform the internal test of the language model generator with a given number of cores
  #
  # @param [Integer] num_cores Number of cores used generate the language model
  def perform_internal_builder( num_cores )
    builder = EncodingEstimator::ParallelModelBuilder.new(
        "#{File.expand_path( File.dirname(__FILE__) )}/samples/data/de"
    )

    # Build with the given number of cores, but disable progress bar
    builder.execute!( num_cores, false )

    # Save the results (json serialized)
    File.open(language_file(num_cores ), 'w' ) do |f|
      f.write JSON.unparse( builder.results )
    end
  end

  # Perform the encoding/decoding test with the model just learned in the previous
  # test via the language model builder
  #
  # @param [String] encoding Encoding to test
  # @param [Symbol] operation Encoding or decoding operation (:enc oder :dec)
  def perform_internal_with_builder_model( encoding, operation )

    # Load file and detect the encoding
    detection = EncodingEstimator.detect(
        get_file_content( :de, encoding, operation ),
        languages:       [language_file(nil ) ],
        include_default: true,
        encodings:       DETECTOR_TEST_ENCODINGS,
        operations: [
            EncodingEstimator::Conversion::Operation::ENCODE,
            EncodingEstimator::Conversion::Operation::DECODE
        ]
    )

    # Correctly detected?
    assert(
        EncodingEstimator::Conversion.new( encoding, operation ).equals? detection.result
    )
  end

  # Perform an internal encoding detection check: load the sample file and let the detector check which encoding
  # it thinks matches best for decoding the file. Then compare with the actual result.
  #
  # @param [Symbol] language Two-letter-language-code of the language to use for analysis
  # @param [String] encoding Encoding to use
  # @param [Symbol] operation Whether to encode or decode
  # @param [Integer] threads Number of threads to use (nil for single threading)
  def perform_internal( language, encoding, operation, threads = nil )

    configuration = {
        languages: [ language ],
        include_default: false,
        encodings: DETECTOR_TEST_ENCODINGS,
        operations: [EncodingEstimator::Conversion::Operation::ENCODE, EncodingEstimator::Conversion::Operation::DECODE],
        num_cores:  threads
    }

    # Load file and detect the encoding
    detection = EncodingEstimator.detect(
        get_file_content( language, encoding, operation ), configuration
    )

    # Should be the given encoding
    assert(
        EncodingEstimator::Conversion.new( encoding, operation ).equals? detection.result
    )

    # Check that score is really the highest of all scores
    assert(
        detection.score == detection.results.map { |r| r[:score] }.max
    )

    assert(
        EncodingEstimator.ensure_utf8(
            get_file_content( language, encoding, operation ),
            configuration
        ) == get_file_content( language, 'utf-8', EncodingEstimator::Conversion::Operation::KEEP )
    )
  end

  # Perform an internal encoding detection check, but use a language where
  # no model is provided for. It should default to utf-8
  #
  # @param [String] encoding Encoding to use
  # @param [Symbol] operation Whether to encode or decode
  # @param [Integer] threads Number of threads to use (nil for single threading)
  def perform_unknown( encoding, operation, threads )

    # Load file and detect the encoding
    detection = EncodingEstimator.detect(
        get_file_content( :unknown, encoding, operation ),
        languages:       [ File.dirname( __FILE__ ) + '/samples/broken-lang.json' ],
        include_default: true,
        encodings:       DETECTOR_TEST_ENCODINGS,
        num_cores:       threads,
        operations: [
            EncodingEstimator::Conversion::Operation::ENCODE,
            EncodingEstimator::Conversion::Operation::DECODE
        ],
        penalty: 0.0
    )

    # Default encoding?
    assert(
        EncodingEstimator::Conversion.new.equals? detection.result
    )
  end

  # Test conversions in 'utf-8 keep mode'
  #
  # @param [Symbol] language Language file to test (samples/keep/$language/utf-8.txt)
  def perform_keep( language )
    operation = EncodingEstimator::Conversion::Operation::KEEP
    content   = get_file_content language, 'utf-8', operation
    assert EncodingEstimator::Conversion.new( 'utf-8', operation ).perform( content ), content
  end

  # Load sample file content from samples/$operation/$language/$encoding.txt
  #
  # @param [Symbol] language Two-letter-code symbol
  # @param [String] encoding Encoding name
  # @param [Symbol] operation Sub-folder: dec or enc
  # @return [String] Data loaded from the sample file
  def get_file_content( language, encoding, operation )
    File.read( "#{File.expand_path( File.dirname(__FILE__) )}/samples/#{operation}/#{language.to_s}/#{encoding}.txt" )
  end
end


# Build the actual test methods: test combinations of language, encoding, operation, and number of threads
# e.g. test_2_dec_en_utf_8
[nil, 1, 2].each do |num_cores|
  # Dynamically setup all tests by creating methods for all languages / encodings
  DETECTOR_TEST_LANGS.each do |language|
    DETECTOR_TEST_ENCODINGS.each do |encoding|
      [EncodingEstimator::Conversion::Operation::ENCODE, EncodingEstimator::Conversion::Operation::DECODE].each do |op|
        TestDetector.send(:define_method, "test_#{num_cores}_#{op}_#{language}_#{encoding.gsub '-', '_'}") do
          perform_internal( language, encoding, op, num_cores )
        end
      end
    end
  end
end

# Build test cases for unknown language (e.g. a language that failes to load)
[nil, 1, 2].each do |num_cores|
  # Dynamically test unknown languages
  DETECTOR_TEST_ENCODINGS.each do |encoding|
    [EncodingEstimator::Conversion::Operation::ENCODE, EncodingEstimator::Conversion::Operation::DECODE].each do |op|
      TestDetector.send(:define_method, "test_#{num_cores}_#{op}_unknown_#{encoding.gsub '-', '_'}") do
        perform_unknown( encoding, op, num_cores )
      end
    end
  end
end

# Create "keep" test cases: test the cases where utf-8 is detected
DETECTOR_TEST_LANGS.each do |language|
  TestDetector.send(:define_method, "test_keep_#{language}") do
    perform_keep language
  end
end

# Create test cases for dynamically created language using the model builder
[EncodingEstimator::Conversion::Operation::ENCODE, EncodingEstimator::Conversion::Operation::DECODE].each do |op|
  DETECTOR_TEST_ENCODINGS.each do |encoding|
    TestDetector.send(:define_method, "test_builder_#{op}_#{encoding.gsub '-', '_'}") do
      perform_internal_with_builder_model encoding, op
    end
  end
end