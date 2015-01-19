class EventsController < ApplicationController

   def edit
      @event = Event.find(params[:id])
       render :layout => false
   end

   def update
     @event = Event.find(params[:id])
     if @event.update(event_params)
       if @event.frequency == "Daily"
         @event.day_of_week = nil
         @event.day_of_month = nil
       elsif @event.frequency == "Weekly"
         @event.day_of_month = nil
       else
         @event.day_of_week = nil
       end
        @event.save
        redirect_to schedule_path(@event.schedule_id)
     end
    end

   def destroy
     @event = Event.find(params[:id])
     @result = Resque.get_schedule("schedule_#{@event.schedule.id}_event_#{@event.id}")
     if @result.present?
       Resque.remove_schedule("schedule_#{@event.schedule.id}_event_#{@event.id}")
     end
      if @event.destroy
        flash[:notice] = 'Event Successfully deleted.'
      else
        flash[:notice] = 'There was some problem deleting the Event.'
      end
      redirect_to schedule_path
   end

   private

   def event_params
     params.require(:event).permit(:action, :frequency, :event_time, :day_of_week, :day_of_month)
   end

end