require "test_helper"

class AccountTest < ActionDispatch::IntegrationTest
  fixtures :notes

  test "user scenario" do
    # Create a new user (including UTF-8 characters that have to be escaped properly)
    get signup_path
    assert_response :success
    post signup_path, params: {user: {username: "Üßerdingens♪♫", email: "int@gration.test", password: "testtest",
                                      password_confirmation: "testtest"}}
    follow_redirect!
    assert_equal login_path, path, "Signing up failed"
    assert flash[:success]

    # Test activaton mails and activate
    token = User.find_by_username("Üßerdingens♪♫").update_token
    email = ActionMailer::Base.deliveries.last
    assert_match activate_path(username: "Üßerdingens♪♫", token: token), email.html_part.body.to_s, "Wrong link in html mail"
    assert_match activate_path(username: "Üßerdingens♪♫", token: token), email.text_part.body.to_s, "Wrong link in text mail"

    get resend_activation_path(username: "Üßerdingens♪♫")
    follow_redirect!
    assert flash[:success]
    email = ActionMailer::Base.deliveries.last
    assert_match activate_path(username: "Üßerdingens♪♫", token: token), email.html_part.body.to_s, "Wrong link in html mail"
    assert_match activate_path(username: "Üßerdingens♪♫", token: token), email.text_part.body.to_s, "Wrong link in text mail"

    post login_path, params: {username: "Üßerdingens♪♫", password: "testtest"}
    assert_equal login_path, path, "Logging in should have failed"
    assert_match resend_activation_path(username: "Üßerdingens♪♫"), flash[:danger].first, "Cannot request activation e-mail"
    get activate_path(username: "Üßerdingens♪♫", token: token)
    follow_redirect!
    assert flash[:success]

    # Log in
    post login_path, params: {username: "Üßerdingens♪♫", password: "testtest"}
    follow_redirect!
    assert_equal notes_path, path, "Logging in failed"
    assert flash[:success]

    # Not allowed to access another user's notes
    get note_path(notes(:testnote).permalink)
    follow_redirect!
    assert_equal notes_path, path, 'Not redirected when accessing another user\'s note'
    assert flash[:danger]
    get edit_note_path(notes(:testnote).permalink)
    follow_redirect!
    assert_equal notes_path, path, 'Not redirected when accessing another user\'s note'
    assert flash[:danger]
    patch note_path(notes(:testnote).permalink), params: {note: {title: "HAAAAX", text: "Blah", public: true}}
    follow_redirect!
    assert_equal notes_path, path, 'Not redirected when accessing another user\'s note'
    assert flash[:danger]
    assert_raises(ActiveRecord::RecordNotFound) do
      delete note_path(notes(:testnote).permalink)
    end
    get note_share_index_path(notes(:testnote).permalink)
    follow_redirect!
    assert_equal notes_path, path, 'Not redirected when trying to share another user\'s note'
    assert flash[:danger]
    post note_share_index_path(notes(:testnote).permalink), params: {username: "Üßerdingens♪♫"}
    follow_redirect!
    assert_equal notes_path, path, 'Not redirected when trying to share another user\'s note'
    assert flash[:danger]

    # Change Password and e-mail
    get edituser_path
    assert_response :success
    patch edituser_path, params: {password_old: "testtest", user: {password: "newnewnew",
                                                                   password_confirmation: "newnewnew", email: "int2@gration.test"}}
    assert_equal edituser_path, path, "Uhm... why have we been redirected?"
    assert flash[:success]
    assert flash[:warning]
    assert_equal "int@gration.test", User.find_by_username("Üßerdingens♪♫").email, "E-mail should not have changed yet"
    token = User.find_by_username("Üßerdingens♪♫").update_token
    email = ActionMailer::Base.deliveries.last
    assert_equal ["int2@gration.test"], email.to, "Not sending to new e-mail address"
    assert_match update_email_path(username: "Üßerdingens♪♫", email: "int2@gration.test", token: token), email.html_part.body.to_s, "Wrong link in html mail"
    assert_match update_email_path(username: "Üßerdingens♪♫", email: "int2@gration.test", token: token), email.text_part.body.to_s, "Wrong link in text mail"
    get update_email_path(username: "Üßerdingens♪♫", email: "int2@gration.test", token: token)
    follow_redirect!
    assert_equal notes_path, path, "Expected redirect to notes overview"
    assert flash[:success]

    # Log out
    get logout_path
    follow_redirect!
    assert_equal login_path, path, "Logout did not redirect to login"
    assert flash[:success]

    # Login and out again with new password
    post login_path, params: {username: "Üßerdingens♪♫", password: "newnewnew"}
    follow_redirect!
    assert_equal notes_path, path
    assert flash[:success]
    get logout_path
    follow_redirect!
    assert_equal login_path, path
    assert flash[:success]

    # Test the password reset
    get forgot_password_path
    assert_response :success
    post reset_password_path, params: {username: "Üßerdingens♪♫", email: "int2@gration.test"}
    follow_redirect!
    assert_equal login_path, path, "Not redirected to login"
    assert flash[:success]

    token = User.find_by_username("Üßerdingens♪♫").update_token
    email = ActionMailer::Base.deliveries.last
    assert_match new_password_path(username: "Üßerdingens♪♫", token: token), email.html_part.body.to_s, "Wrong link in html mail"
    assert_match new_password_path(username: "Üßerdingens♪♫", token: token), email.text_part.body.to_s, "Wrong link in text mail"

    get new_password_path(username: "Üßerdingens♪♫", token: token)
    assert_response :success
    patch update_password_path(username: "Üßerdingens♪♫", token: token), params: {user: {password: "testtest",
                                                                                               password_confirmation: "testtest"}}
    follow_redirect!
    assert_equal login_path, path, "Not redirected to login"
    assert flash[:success]

    post login_path, params: {username: "Üßerdingens♪♫", password: "testtest"}
    follow_redirect!
    assert_equal notes_path, path
    assert flash[:success]
    get logout_path
    follow_redirect!
    assert_equal login_path, path
    assert flash[:success]
  end

  test "oauth scenario" do
    OmniAuth.config.test_mode = true

    # Failure test
    OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials
    silence_omniauth { post "/auth/google_oauth2" }
    silence_omniauth { follow_redirect! }
    follow_redirect!
    follow_redirect!
    assert_equal login_path, path, "Not redirected to login"
    assert flash[:danger]

    # Setup test hashes
    google_hash = OmniAuth::AuthHash.new({provider: "google_oauth2", uid: "123545", info: {name: "Omniauth Test", email: "omni@auth.org"}})
    facebook_hash = OmniAuth::AuthHash.new({provider: "facebook", uid: "123545", info: {name: "Omniauth Test", email: "omni@auth.org"}})
    OmniAuth.config.mock_auth[:google_oauth2] = google_hash
    OmniAuth.config.mock_auth[:facebook] = facebook_hash

    # Create a new user from Google oauth
    post "/auth/google_oauth2"
    follow_redirect!
    follow_redirect!
    assert_equal notes_path, path, "Not redirected to notes index"
    assert_match "created", flash[:success].first

    # Connect their Facebook account
    post "/auth/facebook"
    follow_redirect!
    follow_redirect!
    assert_equal notes_path, path, "Not redirected to notes index"
    assert_match "connected", flash[:success].first

    # Change username
    get edituser_path
    assert_response :success
    patch edituser_path, params: {user: {username: "OAuth"}}
    assert_equal edituser_path, path, "Uhm... why have we been redirected?"
    assert flash[:success]
    assert User.find_by_username("OAuth")
  end
end
