
module Users
  class MissingEmailError < StandardError
    def initialize(msg="Email is required")
      super
    end
  end
end