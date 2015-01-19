class Users::RegistrationsController < Devise::RegistrationsController
  layout 'logout'

  def update
      super  
      current_user.create_activity :update, owner: current_user
  end


  def sign_up_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation,:role, :admin_id,:default_region)
  end

  def account_update_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :current_password,:time_zone,:default_region)
  end

  private :sign_up_params
  private :account_update_params

  private

  def after_inactive_sign_up_path_for(resource)
    new_user_session_path
  end
end