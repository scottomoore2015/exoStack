class UsersController < ApplicationController

  skip_before_filter :fill_aws_creds
  before_action :authorize_owner, only: [:create_new_member, :add_member, :edit_aws_creds,:list_members]
  layout 'logout', except: [:show,:add_member, :list_members]
  respond_to :js, :html

  def add_aws_creds
    @user = current_user
  end

  def show
    @user = current_user
    respond_with @user
  end

  def change_password
    @user = current_user
  end

  def update_password
    @user = current_user
    if @user.valid_password?(params[:user][:password])
      if params[:user][:new_password] == params[:user][:password_confirmation]
        if @user.update_attributes(:password => params[:user][:new_password])
          flash[:notice] = "Password Sucessfully Changed"
          sign_in(@user, :bypass => true)
          redirect_to profile_path
        else
          flash[:error] = "Error occured while updating password. Try again"
          redirect_to change_password_path
        end
      else
        flash[:error] = "New Password and Password Confirmation does not match"
        redirect_to change_password_path
      end
    else
      flash[:error] = "Password is not valid"
      redirect_to change_password_path
    end
  end

  def edit_aws_creds
    @user = current_user
  end

  def update_aws_creds
    @user = current_user
    ec2 = AWS::EC2.new(access_key_id: aws_params["access_key"], secret_access_key: aws_params["secret_token"], region: @user.default_region)
    begin
      unless ec2.client.describe_key_pairs.key_set.nil?
        @user.update_attributes(aws_params)
        @user.account_alias = User.set_account_alias @user if @user.account_alias.nil?
        @user.save
        flash[:notice] = "AWS credentials updated successfully!!"
        redirect_to root_path
      else
        flash[:error] = "Please enter valid AWS creds!!"
        render :add_aws_creds
      end
    rescue
      flash[:error] = "Please enter valid AWS creds!!"
      render :add_aws_creds
    end
  end


  def change_default_region
    @user = current_user
    @user.update_column(:default_region, params[:region])
    render text: "user default region sucessfully changed"
  end

  def add_member
    @admin = current_user
  end
  
  def create_new_member
     @user = User.new(sign_up_params)
     password = @user.generate_password
     @user.temporary_password = password
     @user.password = password
     @user.access_key= current_user.access_key
     @user.secret_token = current_user.secret_token
     @user.account_alias = current_user.account_alias
     if current_user.admin_id.nil?
       @user.admin_id = current_user.id
     else
       @user.admin_id = current_user.admin_id
     end
     if @user.save
       flash[:notice] = "Succesfully added New Member"
     else
       if @user.errors.messages == {:email=>["has already been taken"]} 
          flash[:notice] = "Email has already been taken"
       else
         flash[:notice] = "New member cannot be saved" 
       end 
    end  
    redirect_to profile_path 
 end
 
 def list_members
   @members =  User.where(:admin_id => params["id"])
 end

 def delete_member
   @member = User.find(params[:id])
   if @member.destroy
     flash[:notice] = "Member deleted successfully"
   else
     flash[:alert] = "There was some problem in deleting Member"
   end
   redirect_to list_members_user_path(current_user.id)
 end

  def delete_multiple_member
    unless params[:member_ids].nil?
     @users = User.find(params[:member_ids])
       begin
       @users.each do |user|
         User.delete_iam_user(user , User.find(user.admin_id) ) unless(user.iam_username.nil? || user.confirmed_at.nil? || user.sign_in_count==0)
         user.destroy
       end
        flash[:notice] = 'All selected members deleted successfully'
        redirect_to list_members_user_path(current_user.id)
       rescue
         flash[:alert] = "There was some problem in deleting Member"
         redirect_to list_members_user_path(current_user.id)
       end
    else
      flash[:notice] = 'Please select atleast one member'
      redirect_to list_members_user_path(current_user.id)
    end
  end
  
  private

  def aws_params
    params.require(:user).permit(:access_key, :secret_token)
  end
  
  def sign_up_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation,:role,:admin_id,:iam_username,:iam_password,:default_region,:group_name)
  end
  
end
