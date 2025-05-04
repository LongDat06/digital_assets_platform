module JsonApiErrors
  extend ActiveSupport::Concern

  private

  def json_api_error(resource, status)
    errors = resource.errors.map do |field, message|
      {
        source: { pointer: "/data/attributes/#{field}" },
        detail: message
      }
    end

    render json: { errors: errors }, status: status
  end
end
