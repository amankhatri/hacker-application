class CreateAwards < ActiveRecord::Migration
  def change
    create_table :awards do |t|
      t.string :award_winners
      t.string :award_name
      t.text :description
      t.date :recieved_on

      t.timestamps
    end
  end
end
