class JsonWebToken
  SECRET_KEY = Rails.application.credentials.secret_key_base || Rails.application.secrets.secret_key_base
  ALGORITHM = 'HS256'

  class << self
    def encode(payload, exp = 24.hours.from_now)
      payload[:exp] = exp.to_i
      JWT.encode(payload, SECRET_KEY, ALGORITHM)
    end

    def decode(token)
      decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: ALGORITHM })[0]
      HashWithIndifferentAccess.new(decoded)
    rescue JWT::ExpiredSignature
      raise ExceptionHandler::ExpiredSignature, 'Token has expired'
    rescue JWT::DecodeError
      raise ExceptionHandler::InvalidToken, 'Invalid token'
    end
  end
end
