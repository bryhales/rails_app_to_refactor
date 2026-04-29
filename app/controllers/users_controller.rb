# frozen_string_literal: true

class UsersController < ApplicationController
  def create
    user_params = params.require(:user).permit(:name, :email, :password, :password_confirmation)

    password = user_params[:password].to_s.strip
    password_confirmation = user_params[:password_confirmation].to_s.strip

    result, errors = UserCreation.create(
      name: user_params[:name],
      email: user_params[:email],
      password: user_params[:password],
      password_confirmation: user_params[:password_confirmation]
    )

    if errors.present?
      render_json(422, user: errors[:user])
    else
      render_json(201, user: result[:user].as_json(only: [:id, :name, :token]))
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

    def perform_if_authenticated(&block)
      authenticate_user do
        block.call if block

        render_json(200, user: { email: current_user.email })
      end
    end
end
