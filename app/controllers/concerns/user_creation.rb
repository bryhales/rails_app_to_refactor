class UserCreation
  include ActiveSupport::Concern

  def self.create(name: nil, email: nil, password: nil, password_confirmation: nil)
    validate_arguments(name:, ...)
    generate_password()
    create_user()
  end

  def self.old
    result = {}
    errors = { user: {} }

    errors[:password] = ["can't be blank"] if password.blank?
    errors[:password_confirmation] = ["can't be blank"] if password_confirmation.blank?

    if password != password_confirmation
      errors[:user].merge!({ password_confirmation: ["doesn't match password"] })
    else
      password_digest = Digest::SHA256.hexdigest(password)

      user = User.new(
        name: user_params[:name],
        email: user_params[:email],
        token: SecureRandom.uuid,
        password_digest: password_digest
      )

      if user.save
        result[:user] = user
      else
        errors[:user] << user.errors.as_json
      end
    end

    return result, errors
  end

  def self.create_user
  end
end
