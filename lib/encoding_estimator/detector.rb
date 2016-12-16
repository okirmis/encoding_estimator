require_relative 'distribution'
require_relative 'conversion'
require_relative 'detection'

require_relative 'parallel_support'

module EncodingEstimator
  class RangeScale

  end

  class Detector
    attr_reader :conversions
    attr_reader :languages

    def initialize( conversions, languages )
      @conversions  = conversions
      @languages    = languages

      @distributions = languages.map { |lang| Distribution.new( lang ) }
    end

    def detect( str, num_processes = nil )
      sums = {}

      if num_processes.nil? or !EncodingEstimator::ParallelSupport.supported?
        @distributions.each do |dist|
          @conversions.each { |conv| sums[conv.key] = sums.fetch( conv.key, 0.0 ) + dist.evaluate( conv.perform(str) ) }
        end
      else
        matrix = @distributions.map {
            |dist| @conversions.map { |c| { distribution: dist, conversion: c } }
        }.flatten

        results = Parallel.map( matrix, in_processes: num_processes ) do |combination|
          {
              key:   combination[ :conversion ].key,
              score: combination[ :distribution ].evaluate( combination[ :conversion ].perform(str) )
          }
        end

        results.each { |result| sums[result[:key]] = sums.fetch(result[:key], 0.0) + result[:score] }
      end


      min   = sums.values.min
      range = sums.values.max - min

      if sums.values.min == sums.values.max
        min   = sums.values.min - 1.0
        range = 1.0
      end

      sums.keys.each { |k| sums[k] = (sums[k] - min) / range }

      EncodingEstimator::Detection.new( sums, @conversions )
    end
  end
end