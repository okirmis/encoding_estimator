require_relative '../parallel_support'
require_relative 'model_builder'

module EncodingEstimator

  # Class used to build language models from multiple files
  class ParallelModelBuilder

    attr_reader :files
    attr_reader :results

    # Create a new builder object from all files of a given directory.
    #
    # @param [String] directory          Path to the directory to load files from
    # @param [Float]  min_char_threshold Minimum threshold specifying which characters to include in the final model
    #                                    (see ModelBuilder.join_and_postprocess for more information)
    def initialize( directory, min_char_threshold = 0.00001 )
      @files     = Dir.new( directory ).entries.map { |p| "#{directory}/#{p}" }.select { |p| File.file?( p ) }
      @results   = nil
      @threshold = min_char_threshold
    end

    # Load and process all files from the directory. If the parallel gem is installed, this is done in
    # multiple processes and therefore truly concurrent. If the ruby-progressbar gem is installed and
    # the show_progress parameter is set to true, a progressbar will be shown.
    #
    # @param [Integer] max_processes Maximum number of processes to spawn for processing the files
    # @param [Boolean] show_progress if set to true and the ruby-progressbar gem is installed, show a progressbar
    # @return [Hash] Character count statistics combined from all files of the directory, scaled logarithmically
    def execute!( max_processes = 8, show_progress = true )
      if EncodingEstimator::ParallelSupport.supported?
        opts = {
            in_processes: max_processes,
            progress: ( show_progress && EncodingEstimator::ParallelSupport.progress? ) ? 'Analyzing' : nil
        }

        result_list = Parallel.map( files, opts ) { |f| EncodingEstimator::ModelBuilder.new( f ).execute }
      else
        result_list = files.map { |f| EncodingEstimator::ModelBuilder.new( f ).execute }
      end

      @results  = EncodingEstimator::ModelBuilder.join_and_postprocess(result_list, @threshold )
    end
  end
end