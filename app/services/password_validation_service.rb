
class PasswordValidationService
  def initialize(password)
    @password = password
  end

  def call
    if @password.blank?
      ["can't be blank"]
    end
  end
end