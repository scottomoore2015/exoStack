class Event < ActiveRecord::Base
  belongs_to :schedule



  REPEAT_TYPE = {"Daily" => 0, "Weekly" => 1, "Monthly" => 2}
  ACTIONS = {"Start Instance" => 0, "Stop Instance" => 1, "Reboot Instance" => 2}
  DAY_OF_WEEK = {"Monday" => 1, "Tuesday" => 2, "Wednesday" => 3, "Thursday" => 4, "Friday" => 5, "Saturday" => 2,"Sunday" => 0}

  after_update :edit_event_crontab,:edit_schedule_event

  def frequency=(freq)
    self[:frequency] = REPEAT_TYPE[freq]
  end

  def action=(act)
    self[:action] = ACTIONS[act]
  end

  def frequency
    REPEAT_TYPE.key(self[:frequency])
  end

  def action
    ACTIONS.key(self[:action])
  end

  def day_of_week=(day)
    self[:day_of_week] = DAY_OF_WEEK[day]
  end

  def day_of_week
    DAY_OF_WEEK.key(self[:day_of_week])
  end


  def edit_event_crontab

      cron_array = case self.frequency
                     when "Daily"
                       [self.event_time.min, self.event_time.hour- self.schedule.user.time_zone.to_i, "* * *"]
                     when "Weekly"
                       [self.event_time.min, self.event_time.hour-self.schedule.user.time_zone.to_i, "* *", self[:day_of_week]]
                     when "Monthly"
                       [self.event_time.min, self.event_time.hour-self.schedule.user.time_zone.to_i, self.day_of_month, "* *"]
                   end
      self.update_column :cron, cron_array.join(" ")
    end


  def edit_schedule_event
      Resque.set_schedule("schedule_#{self.schedule.id}_event_#{self.id}", {
          :cron => self.cron,
          :class => "ScheduleEvent",
          :args => [self.schedule.user.id, self.schedule.id, self.id],
          :message => 'Edit Schedule set for event',
          :persist => true
      })
  end
end
