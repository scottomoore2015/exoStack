class ActivitiesController < ApplicationController
 respond_to :js, :html

  def index
   member_user_ids = current_user.member_user.ids
   current_user_id = current_user.id
   user_ids = member_user_ids.unshift(current_user_id)
   @activities = PublicActivity::Activity.where(owner_type: 'User',owner_id: user_ids).order("created_at desc")
   respond_with @activities
  end
end
