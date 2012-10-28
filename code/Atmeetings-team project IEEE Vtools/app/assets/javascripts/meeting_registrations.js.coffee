# The code from this section is taken from example given by Professor David Green
# This code makes use of the Rails gem select2
# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#

personFormatResult = (person) ->
  markup = "<table class='person-result'><tr>"
  markup += "<td>#{person.email}</td>" if person.email != undefined
  #markup += "<td>#{person.first_name}</td>" if person.first_name != undefined
  markup += "</td></tr></table>"

personFormatSelection = (person) ->
  markup = person.first_name+" "+ person.last_name+", " 
  markup +=  " "+ " " + person.email + " " if person.email != ""
  
# With the help of http://js2cs.nodejitsu.com/ (blank lines optional)

$(document).ready ->
  $("#checkin").select2
    placeholder:
      name: "Search for attendee by email"
      email: ""
  
    minimumInputLength: 1

    ajax:
      processData: true

      data: (term, page) ->
        email: term
        section_id: 1
       

      url: "/meeting_registrations/match"

      dataType: "json"

      results: (data, page) ->
        results: data

    formatResult: personFormatResult
    formatSelection: personFormatSelection
