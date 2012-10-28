class LabelText < ActiveRecord::Base

  validates_presence_of :table, :attribute, :font_size, :type_face, :font_color,
                        :row_no

  validates_numericality_of :font_size, :row_no
  
  belongs_to :pdf_sheet

end
