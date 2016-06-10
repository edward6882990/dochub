class UserValidator < ActiveModel::Validator
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

  def validate(user)
    if user.new?
      validate_password(user)
    end
    validate_email(user)
  end

  def validate_password(user)
    if (user.password.nil? || user.password.empty?)
      user.errors[:password] << "cannot be empty."
    else
      if (user.password != user.password_confirmation)
        user.errors[:password] << "did not match the confirmation."
      end

      if (user.password.length < 8 || user.password.length > 255)
        user.errors[:password] << "must have length between 8 and 255."
      end
    end
  end

  def validate_email(user)
    unless valid_email?(user.email)
      user.errors[:email] << "is invalid."
    end
  end

protected

  def valid_email?(email)
    email.match(VALID_EMAIL_REGEX)
  end

end
