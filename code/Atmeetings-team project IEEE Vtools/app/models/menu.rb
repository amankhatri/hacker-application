class Menu < ActiveRecord::Base
    belongs_to :meeting
    validates_presence_of :name
end
