class AuthenticationService
  def self.authenticate(email, password)
    user = User.find_by(email: email)
    
    if user&.authenticate(password)
      token = JsonWebToken.encode(user_id: user.id)
      return { token: token, user: user }
    else
      raise ExceptionHandler::AuthenticationError, 'Invalid credentials'
    end
  end

  def self.authenticate_request(headers)
    if headers['Authorization'].present?
      token = headers['Authorization'].split(' ').last
      decoded_token = JsonWebToken.decode(token)
      User.find(decoded_token[:user_id])
    else
      raise ExceptionHandler::MissingToken, 'Missing token'
    end
  rescue ActiveRecord::RecordNotFound
    raise ExceptionHandler::InvalidToken, 'Invalid token'
  end
end
