require 'test_helper'

class ShareControllerTest < ActionController::TestCase
  test 'sharing works' do
    do_login
    get :index, note_id: notes(:sharednote).permalink
    assert_response :success
    assert_difference('Share.count') do
      post :create, note_id: notes(:sharednote).permalink, username: users(:sharetest).username
      email = ActionMailer::Base.deliveries.last
      assert_equal [users(:sharetest).email], email.to, 'Not sending to users e-mail address'
      assert_match note_path(id: notes(:sharednote).permalink), email.html_part.body.to_s, 'Wrong link in html mail'
      assert_match note_path(id: notes(:sharednote).permalink), email.text_part.body.to_s, 'Wrong link in text mail'
    end
    do_logout
  end

  test 'sharing access restricted' do
    do_login
    get :index, note_id: notes(:userless).permalink
    assert_redirected_to notes_path
    assert flash[:danger]
    post :create, note_id: notes(:userless).permalink, username: users(:testuser).username
    assert_redirected_to notes_path
    assert flash[:danger]
    delete :create, note_id: notes(:userless).permalink, id: 123 # ID should not matter for redirect
    assert_redirected_to notes_path
    assert flash[:danger]
    do_logout
  end
end
