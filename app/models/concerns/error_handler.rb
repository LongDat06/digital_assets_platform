module ErrorHandler
  extend ActiveSupport::Concern

  included do
    def errors_to_hash
      errors.messages.transform_values { |v| v.join(', ') }
    end
  end
end
