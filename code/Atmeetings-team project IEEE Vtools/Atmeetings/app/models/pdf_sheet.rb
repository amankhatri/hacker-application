class PdfSheet < ActiveRecord::Base
  has_many :label_texts, :dependent => :delete_all

  # Validations for the values of model pdf_sheet.rb

  validates_presence_of :title, :description, :page_width, :page_length,
    :top_margin, :left_margin, :column_gutter, :row_gutter,
    :columns, :badge_width, :badge_height, :rows_per_page

  validates_uniqueness_of :title
                      
  validates_numericality_of :page_width, :page_length, :columns,:badge_width,
    :badge_height, :rows_per_page, :greater_than=>0
  validates_numericality_of :top_margin, :left_margin, :column_gutter,
    :row_gutter, :greater_than_or_equal_to=>0

  validates_length_of   :title, :maximum => 32, :message=>" cannot be longer than 32 characters"
  validates_length_of   :description, :maximum => 8192, :message=>" cannot be longer than 8192 characters"


  #def validate
  # error.add(:page_width, "must be a greater than zero") if self.page_width and self.page_width < 0 and self.page_width == 0
  # error.add(:page_length, "must be a greater than zero") if self.page_length and self.page_length < 0 and self.page_length == 0
  # error.add(:columns, "must be a greater than zero") if self.columns and self.columns < 0 and self.columns == 0
  # error.add(:badge_width, "must be a greater than zero") if self.page_width and self.page_width < 0 and self.page_width == 0
  #end

  def add_line(label_text)
    label_texts << label_text
  end

  def get_lines
    lt = LabelText.find(:all, :conditions => ["pdf_sheet_id = ?" , self.id.to_s], :speakers => "row_no")
    if lt.nil?
      return 0
    else
      return lt
    end
  end

  def update_lines(lines_to_ud)
    lines_to_ud.each do |line|
      l = LabelText.find(:all, :conditions => ["id=? and pdf_sheet_id=?",line.id, self.id])
      l.update_attributes(line)
    end
  end

  def move_line_up(row_no_to_move)
    
    line_to_move = LabelText.find(:first, :conditions => ["pdf_sheet_id=? and row_no=?", self.id, row_no_to_move])
    if line_to_move.row_no > 1
      la_row_no = line_to_move.row_no - 1
      line_above = LabelText.find(:first, :conditions => ["pdf_sheet_id=? and row_no=?", self.id, la_row_no])

      if not(line_above.nil?)
        line_above.row_no = 0
        line_above.save

        line_to_move.row_no = la_row_no

        if line_to_move.save
          line_above.row_no = la_row_no + 1
          if line_above.save
            return true
          else
            return false
          end
        else
          line_above.row_no = la_row_no
          line_above.save
          return false
        end
      else
        
        line_to_move.row_no = la_row_no
        
        if line_to_move.save
          return true
        else
          return false
        end
        
      end
    end


  end

  def move_line_down(row_no_to_move)

    line_to_move = LabelText.find(:first, :conditions => ["pdf_sheet_id=? and row_no=?", self.id, row_no_to_move])
    if line_to_move.row_no < self.get_lines.count
      lb_row_no = line_to_move.row_no + 1
      line_below = LabelText.find(:first, :conditions => ["pdf_sheet_id=? and row_no=?", self.id, lb_row_no])

      line_below.row_no = 0
      line_below.save

      line_to_move.row_no = lb_row_no

      if line_to_move.save
        line_below.row_no = lb_row_no - 1
        if line_below.save
          return true
        else
          return false
        end
      else
        line_below.row_no = lb_row_no
        line_below.save
        return false
      end

    end


  end

  def delete_line(row_to_del)
    line_to_del = LabelText.find(:first, :conditions => ["pdf_sheet_id=? and row_no=?", self.id, row_to_del])

    start_line = line_to_del.row_no + 1
    cur_lines = self.get_lines.count

    line_to_del.destroy

    start_line.upto(cur_lines) do |l_row|
      self.move_line_up(l_row)
    end

    if self.get_lines.count == cur_lines - 1
      return true
    else
      return false
    end
  end


end
