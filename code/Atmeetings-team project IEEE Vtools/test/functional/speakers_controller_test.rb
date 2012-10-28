
require 'test_helper'
require 'awesome_print'

class SpeakersControllerTest < ActionController::TestCase
  setup do
    session[:meeting_id] = '1'
    session[:user_id] = '1'
    @speakers = Speaker.find(4)
    @update = {
        display_name: "David Jones",
        topic: "stuff1",
        organization: "stuff2",
        biography: "stuff3",
        city: "stuff4",
        first_name: "stuff5",
        middle_name: "stuff6",
        last_name: "stuff7",
        suffix: "stuff8",
        prefix: "stuff9",
        speaker_url: "http://www.stuff.com",
        topic_description: "stuff10",
        email: "stuff@stuff.com",
    }
  end

  test "should get index" do
    get :index
    assert_equal "Davy Crockett", @speakers.display_name
    assert_response :success
    assert_not_nil assigns(:speakers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create speaker" do
    assert_difference('Speaker.count') do
      post :create, speakers:@update
    end
    assert_redirected_to speaker_path(assigns(:speakers))
  end

  test "should show speaker" do
    get :show, id: @speakers
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @speakers
    assert_response :success
  end

  test "should update speakers" do
    put :update, id: @speakers, speakers: @update
    assert_redirected_to speaker_path(assigns(:speakers))
  end

  test "should destroy speaker" do
    assert_difference('Speaker.count', -1) do
      delete :destroy, id: @speakers
    end

    assert_redirected_to speakers_path
  end

  test "validate speaker url format" do
    speaker = Speaker.new(
        id: 25,
        display_name: "Buddy Portabello",
        speaker_url: "htt://www.stuff.com")
    assert !speaker.save
    assert_equal " is not a valid url. (missing http:// or similar prefix?)", speaker.errors[:speaker_url].join('; ')
  end

  test "validate display name" do
    speaker = Speaker.new(
        id: 25,
        first_name: "Buddy",
        last_name: "Portabello",
    )
    assert !speaker.save
    assert_equal " is required when first and/or last name given", speaker.errors[:display_name].join('; ')
  end

  test "validate email format" do
    speaker = Speaker.new(
        id: 25,
        display_name: "Buddy Portabello",
        email: "stuff",
    )
    assert !speaker.save
    assert_equal " must be valid.", speaker.errors[:email].join('; ')
  end

  test "validate picture format" do
    speaker = Speaker.new(
        id: 25,
        display_name: "Buddy Portabello",
        mime_type: "bmp"
    )
    assert !speaker.save
    assert_equal "File must be a jpg, jpeg, gif, or png image.", speaker.errors[:mime_type].join('; ')
  end

  #This test does not work as intended
  #test "should send updated form data" do
  #  put :update, id: @speakers, speakers: @updates
  #  assert_equal "David Jones", assigns(:speakers).display_name
  #  assert_redirected_to speaker_path(assigns(:speakers))
  #
  #end

end

