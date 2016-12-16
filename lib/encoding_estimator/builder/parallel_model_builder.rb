require_relative '../parallel_support'
require_relative 'model_builder'

module EncodingEstimator
  class ParallelModelBuilder

    attr_reader :files
    attr_reader :results

    def initialize( directory )
      @files   = Dir.new( directory ).entries.map { |p| "#{directory}/#{p}" }.select { |p| File.file?( p ) }
      @results = nil
    end

    def execute!
      if EncodingEstimator::ParallelSupport.supported?
        opts = { in_processes: 8, progress: EncodingEstimator::ParallelSupport.progress? ? 'Analyzing' : nil }

        result_list = Parallel.map( files, opts ) { |f| ParallelModelBuilder.analyze f }
      else
        result_list = files.map { |f| ParallelModelBuilder.analyze f }
      end

      @results  = EncodingEstimator::ModelBuilder.postprocess_multiple!( result_list )
    end

    def self.analyze( file )
      EncodingEstimator::ModelBuilder.new( file ).execute!
    end

  end
end