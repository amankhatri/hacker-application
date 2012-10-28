
# CSV Output
# model_class should be the model's class and have .search() defined as well as .search_results_columns
# controller_class should be the controller class and have

class SearchOutput

  # Handles maintenance of parameters and session for search for all models that implement it
  # options include:
  # :show_unpublished (:none (only show published meetings), :include (show both
  # published and unpublished meetings), and :only (show only unplublished meetings)
  # , defaults to :none

  def self.search(params, session, model_class, options={})

    if (!options[:show_unpublished])
      options[:show_unpublished] = :none
    end

    search_results = nil
    dates_ok = true # Will be false if any dates are not properly formatted
    search_params_session_key = "last_" + model_class.to_s + "_search_params"

    # Here we want to look at the session to see if there is a set of search parameters that were last submitted
    if (params[:clear_search])
      # We've been explicitly instructed to clear out any saved search
      session[search_params_session_key] = nil
    end
    if ((!params[:sub]) && (session[search_params_session_key] != nil))
      # No search is being submitted with this request, and there is a last search in the session
      #  Grab all the params that have been saved and adopt them for this request - this should
      #  effectively display the last search as it was displayed at last view
      last_params = session[search_params_session_key]
      last_params.each_key { |hk| params[hk] = last_params[hk] }
    end

    if (params[:sub])
      # A search has been submitted, so save it in the session as the last one
      session[search_params_session_key] = params

      # Let's help them out a bit in the case of a bad date submission
      dates_ok = ((dates_ok) && (params[:meeting_after].match(/^\d{2} \w{3} \d{4} \d{2}:\d{2}$/))) unless params[:meeting_after].blank?
      dates_ok = ((dates_ok) && (params[:meeting_before].match(/^\d{2} \w{3} \d{4} \d{2}:\d{2}$/))) unless params[:meeting_before].blank?
      dates_ok = ((dates_ok) && (params[:submitted_after].match(/^\d{2} \w{3} \d{4} \d{2}:\d{2}$/))) unless params[:submitted_after].blank?
      dates_ok = ((dates_ok) && (params[:submitted_before].match(/^\d{2} \w{3} \d{4} \d{2}:\d{2}$/))) unless params[:submitted_before].blank?

      # Execute the search (any bad dates will be removed from search criteria)
      search_results = model_class.search(params, options)
      
    end

    # Get the search results columns from the model class
    search_results_columns = model_class.search_results_columns

    return search_results_columns, search_results, dates_ok

  end


  # Returns a string representation of the search specified in 'params', using
  # the 'field_separator' specified
  def self.output_to_csv(model_class, params, options={})

    require 'csv'

    options[:field_separator] ||= ','

    output = StringIO.new
    @results = model_class.search(params, {:paginate=>false}) # Get the results, no pagination
    columns = model_class.search_results_columns

    titles = []
    columns.each { |col| titles << col["Title"] unless !col["ShowOnCSV"] }

    help = Object.new.extend(SearchOutputHelper)

    CSV::Writer.generate(output, options[:field_separator]) do |title|
      title << titles
      @results.each do |mr|
        col_values = []
        columns.each { |col|
          if (col["ShowOnCSV"])
            col_values << help.search_results_row(mr, col, {:html=>false,
                                                            :include_time=>true,
                                                            # We pass along the request here,
                                                            # it's needed in output lambda for URL.. :-/
                                                            :request=>options[:request]})
          end
        }
        title << col_values
      end
    end

    output.rewind
    return output.read
  end


end