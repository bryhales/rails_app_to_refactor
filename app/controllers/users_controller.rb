# frozen_string_literal: true

class UsersController < ApplicationController
  def create
    password = user_params[:password].to_s.strip
    password_confirmation = user_params[:password_confirmation].to_s.strip

    errors = {}
    errors[:password] = PasswordValidationService.new(password).call
    errors[:password_confirmation] = PasswordValidationService.new(password_confirmation).call

    if errors.compact.present?
      render_json(422, user: errors)
    else
      if password != password_confirmation
        render_json(422, user: { password_confirmation: ["doesn't match password"] })
      else
        if user.save
          render_json(201, user: user.as_json(only: [:id, :name, :token]))
        else
          render_json(422, user: user.errors.as_json)
        end
      end
    end
  end

  def show
    perform_if_authenticated
  end

  def destroy
    perform_if_authenticated do
      current_user.destroy
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    def password_digest
      @password_digest ||= Digest::SHA256.hexdigest(password)
    end

    def user
      User.new(
        name: user_params[:name],
        email: user_params[:email],
        token: SecureRandom.uuid,
        password_digest: password_digest
      )
    end

    def perform_if_authenticated(&block)
      authenticate_user do
        block.call if block

        render_json(200, user: { email: current_user.email })
      end
    end
end
