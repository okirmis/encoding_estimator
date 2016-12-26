require 'minitest/autorun'
require_relative '../lib/encoding_estimator'

DETECTOR_TEST_ENCODINGS = %w(utf-8 iso-8859-1 utf-16le)


class TestDetector < Minitest::Test
  private

  # Perform an internal encoding detection check: load the sample file and let the detector check which encoding
  # it thinks matches best for decoding the file. Then compare with the actual result.
  #
  # @param [Symbol] language Two-letter-language-code of the language to use for analysis
  # @param [String] encoding Encoding to use
  # @param [Symbol] operation Whether to encode or decode
  def perform_internal( language, encoding, operation )

    # Load file and detect the encoding
    detection = EncodingEstimator.detect(
        get_file_content( language, encoding, operation ),
        languages: [ language ], include_default: false, encodings: DETECTOR_TEST_ENCODINGS,
        operations: [EncodingEstimator::Conversion::Operation::ENCODE, EncodingEstimator::Conversion::Operation::DECODE]
    )

    # Should be the given encoding
    assert(
        EncodingEstimator::Conversion.new( encoding, operation ).equals? detection.result
    )
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


# Dynamically setup all tests by creating methods for all languages / encodings
[:de, :en, :fr].each do |language|
  DETECTOR_TEST_ENCODINGS.each do |encoding|
    [EncodingEstimator::Conversion::Operation::ENCODE, EncodingEstimator::Conversion::Operation::DECODE].each do |op|
      TestDetector.send(:define_method, "test_#{op}_#{language}_#{encoding.gsub '-', '_'}") do
        perform_internal( language, encoding, op )
      end
    end
  end

end