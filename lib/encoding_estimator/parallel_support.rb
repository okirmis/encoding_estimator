module EncodingEstimator
  class ParallelSupport
    def self.supported?
      @@supported ||= check_support
    end

    def self.progress?
      @@progress ||= check_progress
    end

    private
    def self.check_support
      check_gem 'parallel'
    end

    def self.check_progress
      check_gem 'ruby-progressbar'
    end

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
