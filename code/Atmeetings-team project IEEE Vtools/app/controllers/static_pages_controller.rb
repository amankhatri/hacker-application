class StaticPagesController <  ApplicationController
  skip_before_filter :authorize

  # GET /static_pages
  def about
  end
end
