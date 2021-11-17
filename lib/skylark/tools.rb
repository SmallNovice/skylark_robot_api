module Skylark
  module Tools
    module_function

    def self.retryable(options = {})
      opts = { tries: 3, on: Exception }.merge(options)
      retry_exception, retries = opts[:on], opts[:tries]

      begin
        return yield
      rescue retry_exception => e
        if (retries -= 1) > 0
          Rails.logger.info "#{e.inspect}. Retry index #{retries}"
          retry
        else
          raise
        end
      end
    end
  end
end
