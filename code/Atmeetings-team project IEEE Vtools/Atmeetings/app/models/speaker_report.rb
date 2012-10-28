class SpeakerReport < ActiveRecord::Base
  belongs_to :meeting
  belongs_to :meeting_report
  belongs_to :state
  belongs_to :country

  def self.per_page
    20
  end
  
public
  # creating a new speaker report with pre-filled attributes
  def self.create_new(speaker)
    sr=SpeakerReport.new
    #difining a list of field to be filled in the report
    list = [:first_name,:last_name,:middle_name,:display_name,:prefix,:suffix,:city,:state_id,:country_id,:email,:organization,:topic,:dlp_speaker]
    list.each do |a|
      #filling the known attributes
      sr[a] = speaker[a]
    end 
    sr    
  end
  
  def has_info?()
  
    fields_to_check = [ :display_name, :topic ];
  
    result =  false
  
    fields_to_check.each do |f|
      result = true if ( self[f] and not self[f].blank? )
    end
    result
  end
end
