class CreateCurrentMeetings < ActiveRecord::Migration
  def change
    create_table :current_meetings do |t|

      t.timestamps
    end
  end
end
