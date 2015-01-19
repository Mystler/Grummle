require 'test_helper'

class AccountTest < ActionDispatch::IntegrationTest
  fixtures :notes

  test 'user scenario' do
    # Create a new user (including UTF-8 characters that have to be escaped properly)
    get signup_path
    assert_response :success
    post_via_redirect signup_path, user: { username: 'Üßerdingens♪♫', email: 'int@gration.test', password: 'testtest',
      password_confirmation: 'testtest' }
    assert_equal login_path, path, 'Signing up failed'
    assert flash[:success]

    # Test activaton mails and activate
    token = User.find_by_username('Üßerdingens♪♫').auth_token
    email = ActionMailer::Base.deliveries.last
    assert_match activate_path(username: 'Üßerdingens♪♫', token: token), email.html_part.body.to_s, 'Wrong link in html mail'
    assert_match activate_path(username: 'Üßerdingens♪♫', token: token), email.text_part.body.to_s, 'Wrong link in text mail'

    get_via_redirect resend_activation_path(username: 'Üßerdingens♪♫')
    assert flash[:success]
    email = ActionMailer::Base.deliveries.last
    assert_match activate_path(username: 'Üßerdingens♪♫', token: token), email.html_part.body.to_s, 'Wrong link in html mail'
    assert_match activate_path(username: 'Üßerdingens♪♫', token: token), email.text_part.body.to_s, 'Wrong link in text mail'

    post_via_redirect login_path, username: 'Üßerdingens♪♫', password: 'testtest'
    assert_equal login_path, path, 'Logging in should have failed'
    assert_match resend_activation_path(username: 'Üßerdingens♪♫'), flash[:danger].first, 'Cannot request activation e-mail'
    get_via_redirect activate_path(username: 'Üßerdingens♪♫', token: token)
    assert flash[:success]

    # Log in
    post_via_redirect login_path, username: 'Üßerdingens♪♫', password: 'testtest'
    assert_equal notes_path, path, 'Logging in failed'
    assert flash[:success]

    # Not allowed to access another user's notes
    get_via_redirect note_path(notes(:testnote).permalink)
    assert_equal notes_path, path, 'Not redirected when accessing another user\'s note'
    assert flash[:danger]
    get_via_redirect edit_note_path(notes(:testnote).permalink)
    assert_equal notes_path, path, 'Not redirected when accessing another user\'s note'
    assert flash[:danger]
    patch_via_redirect note_path(notes(:testnote).permalink), note: { title: 'HAAAAX', text: 'Blah', public: true }
    assert_equal notes_path, path, 'Not redirected when accessing another user\'s note'
    assert flash[:danger]
    assert_raises(ActiveRecord::RecordNotFound) do
      delete note_path(notes(:testnote).permalink)
    end
    get_via_redirect note_share_index_path(notes(:testnote).permalink)
    assert_equal notes_path, path, 'Not redirected when trying to share another user\'s note'
    assert flash[:danger]
    post_via_redirect note_share_index_path(notes(:testnote).permalink), username: 'Üßerdingens♪♫'
    assert_equal notes_path, path, 'Not redirected when trying to share another user\'s note'
    assert flash[:danger]

    # Change Password and e-mail
    get edituser_path
    assert_response :success
    patch_via_redirect edituser_path, password_old: 'testtest', user: { password: 'newnewnew',
      password_confirmation: 'newnewnew', email: 'int2@gration.test' }
    assert_equal edituser_path, path, 'Uhm... why have we been redirected?'
    assert flash[:success]
    assert flash[:warning]
    assert_equal 'int@gration.test', User.find_by_username('Üßerdingens♪♫').email, 'E-mail should not have changed yet'
    token = User.find_by_username('Üßerdingens♪♫').auth_token
    email = ActionMailer::Base.deliveries.last
    assert_equal ['int2@gration.test'], email.to, 'Not sending to new e-mail address'
    assert_match update_email_path(username: 'Üßerdingens♪♫', email: 'int2@gration.test', token: token), email.html_part.body.to_s, 'Wrong link in html mail'
    assert_match update_email_path(username: 'Üßerdingens♪♫', email: 'int2@gration.test', token: token), email.text_part.body.to_s, 'Wrong link in text mail'
    get_via_redirect update_email_path(username: 'Üßerdingens♪♫', email: 'int2@gration.test', token: token)
    assert_equal notes_path, path, 'Expected redirect to notes overview'
    assert flash[:success]

    # Log out
    get_via_redirect logout_path
    assert_equal login_path, path, 'Logout did not redirect to login'
    assert flash[:success]

    # Login and out again with new password
    post_via_redirect login_path, username: 'Üßerdingens♪♫', password: 'newnewnew'
    assert_equal notes_path, path
    assert flash[:success]
    get_via_redirect logout_path
    assert_equal login_path, path
    assert flash[:success]

    # Test the password reset
    get forgot_password_path
    assert_response :success
    post_via_redirect reset_password_path, username: 'Üßerdingens♪♫', email: 'int2@gration.test'
    assert_equal login_path, path, 'Not redirected to login'
    assert flash[:success]

    token = User.find_by_username('Üßerdingens♪♫').auth_token
    email = ActionMailer::Base.deliveries.last
    assert_match new_password_path(username: 'Üßerdingens♪♫', token: token), email.html_part.body.to_s, 'Wrong link in html mail'
    assert_match new_password_path(username: 'Üßerdingens♪♫', token: token), email.text_part.body.to_s, 'Wrong link in text mail'

    get new_password_path(username: 'Üßerdingens♪♫', token: token)
    assert_response :success
    patch_via_redirect update_password_path(username: 'Üßerdingens♪♫', token: token), user: { password: 'testtest',
      password_confirmation: 'testtest' }
    assert_equal login_path, path, 'Not redirected to login'
    assert flash[:success]

    post_via_redirect login_path, username: 'Üßerdingens♪♫', password: 'testtest'
    assert_equal notes_path, path
    assert flash[:success]
    get_via_redirect logout_path
    assert_equal login_path, path
    assert flash[:success]
  end

  test 'oauth scenario' do
    OmniAuth.config.test_mode = true

    # Failure test
    OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials
    silence_omniauth { get_via_redirect '/auth/google_oauth2' }
    assert_equal login_path, path, 'Not redirected to login'
    assert flash[:danger]

    # Setup test hashes
    google_hash = OmniAuth::AuthHash.new({provider: 'google_oauth2', uid: '123545', info: {name: 'Omniauth Test', email: 'omni@auth.org'}})
    facebook_hash = OmniAuth::AuthHash.new({provider: 'facebook', uid: '123545', info: {name: 'Omniauth Test', email: 'omni@auth.org'}})
    OmniAuth.config.mock_auth[:google_oauth2] = google_hash
    OmniAuth.config.mock_auth[:facebook] = facebook_hash

    # Create a new user from Google oauth
    get_via_redirect '/auth/google_oauth2'
    assert_equal notes_path, path, 'Not redirected to notes index'
    assert_match 'created', flash[:success].first

    # Connect their Facebook account
    get_via_redirect '/auth/facebook'
    assert_equal notes_path, path, 'Not redirected to notes index'
    assert_match 'connected', flash[:success].first

    # Change username
    get edituser_path
    assert_response :success
    patch_via_redirect edituser_path, user: { username: 'OAuth' }
    assert_equal edituser_path, path, 'Uhm... why have we been redirected?'
    assert flash[:success]
    assert User.find_by_username('OAuth')
  end
end
