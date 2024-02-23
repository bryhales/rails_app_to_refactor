
module Users
  class CreationService
    attr_reader :name, :email, :password, :password_confirmation, :errors
    
    def initialize(name:, email:, password:, password_confirmation:)
      @name =  name
      @email = email
      @password = password
      @password_confirmation = password_confirmation
      @errors = []
    end

    def call
      validate!
      create_user! unless errors.any?
    end

    private

    def validate!
      errors.push('Email required') unless email.present?
      errors.push('Name required') unless name.present?
      errors.push('Password or confirmation are required') unless password.present? && password_confirmation.present?
      errors.push('Password and confirmation do not match') unless password == password_confirmation
    end

    def create_user!
      password_digest = Digest::SHA256.hexdigest(password)

      user = User.new(
        name:,
        email:,
        token: SecureRandom.uuid,
        password_digest: password_digest
      )

      if user.save
        { response: { user: user.as_json(only: [:id, :name, :token, :errors]) }}
      else
        { response: { user: user.as_json(only: [:errors])} }
      end
    end
  end
end