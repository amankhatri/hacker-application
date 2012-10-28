class AddPresentAndInterestedToMeetingRegistrations < ActiveRecord::Migration
  def change
    add_column :meeting_registrations, :present, :boolean
    add_column :meeting_registrations, :interested, :boolean
  end
end
