class Award < ActiveRecord::Base
  attr_accessible :award_name, :award_winners, :description, :recieved_on


validates_presence_of   :award_name, 
                        :award_winners, 
                        :description, 
                        :recieved_on
   end
