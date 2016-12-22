module EncodingEstimator

  # Helper class to check for parallel processing support
  class ParallelSupport

    # Method to query whether the parallel gem is available
    #
    # @return [Boolean] true, if the parallel gem is available, false if not
    def self.supported?
      @@supported ||= check_support
    end

    # Method to query whether the ruby-progressbar gem is available
    # (used for progressbar in Parallel.map)
    #
    # @return [Boolean] true, if the progressbar gem is available, false if not
    def self.progress?
      @@progress ||= check_progress
    end

    private
    # Determine whether the parallel gem can be loaded.
    #
    # @return [Boolean] true if loading the parallel gem was successful
    def self.check_support
      check_gem 'parallel'
    end

    # Determine whether the ruby-progressbar gem can be loaded.
    #
    # @return [Boolean] true if loading the ruby-progressbar gem was successful
    def self.check_progress
      check_gem 'ruby-progressbar'
    end

    # Check if the gem with a given name can be loaded.
    #
    # @param [String] name Name of the gem to load
    # @return [Boolean] true, if loading the gem was successful, false if otherwise
    def self.check_gem( name )
      begin
        require name
      rescue LoadError
        return false
      end
      true
    end
  end
end
