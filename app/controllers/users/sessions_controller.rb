class Users::SessionsController < Devise::SessionsController
  layout 'logout'
  after_filter :first_time_login , :only => [:create]



  private

  def first_time_login
   if current_user.sign_in_count == 1 && !current_user.admin_id.nil?
     #begin
     User.create_iam_user(current_user)
     #rescue
       #current_user.sign_in_count = 0
      # current_user.save
      # flash[:error] = "Error Logging in or may be while registering to amazon"
      # sign_out(current_user)
     #end
   end
  end

end