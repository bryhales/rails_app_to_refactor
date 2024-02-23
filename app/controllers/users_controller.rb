# frozen_string_literal: true

class UsersController < ApplicationController
  def create
    user_params = params.require(:user).permit(:name, :email, :password, :password_confirmation)

    response = Users::CreationService.new(user_params).call
    
    if response.dig(:user, :errors).empty?
      render_json(201, user: response[:user])
    else
      render_json(422, user: response[:user][:errors])
    end
    
  rescue 
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
    #TODO: check if this need to be moved to concern
    def perform_if_authenticated(&block)
      authenticate_user do
        block.call if block

        render_json(200, user: { email: current_user.email })
      end
    end
end
