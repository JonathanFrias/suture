module Suture::Value
  class Result
    def self.errored(error)
      new(:error, error)
    end

    def self.returned(return_value)
      new(:return_value, return_value)
    end

    attr_reader :value
    def initialize(result_type, value)
      @value = value
      @errored = result_type == :error
    end

    def errored?
      @errored
    end

    def ==(other)
      other.kind_of?(self.class) && other.state == state
    end

    def hash
      state.hash
    end

    protected

    def state
      [@value, @errored]
    end
  end
end
