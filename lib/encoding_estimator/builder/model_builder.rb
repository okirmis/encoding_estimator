require 'htmlentities'

module EncodingEstimator
  class ModelBuilder
    attr_reader   :filename

    def initialize( filename )
      @filename = filename
    end

    def execute!
      content = load_content

      stats = {}
      content.each_char { |c| stats[c] = stats.fetch(c, 0) + 1 }

      stats
    end

    def self.postprocess_multiple!( stats_collection, min_char_threshold = 0.00001 )
      stats     = {}
      log_stats = {}

      # Join all stats
      stats_collection.each do |stat|
        stat.each { |char, count| stats[char] = stats.fetch(char, 0) + count }
      end

      max_count = stats.values.max
      stats.each do |char, count|
        next if count < max_count * min_char_threshold

        log_stats[ char ] = ( 10.0 * Math.log10( count ) / Math.log10( max_count ) ).round 2
      end

      log_stats
    end

    private
    def load_content
      raw       = File.read( @filename ).encode('UTF-16be', invalid: :replace, replace: '').encode('UTF-8')
      decoder   = HTMLEntities.new
      plaintext = decoder.decode raw

      plaintext.gsub! /\s/, ''
      plaintext
    end
  end
end
