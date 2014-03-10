require 'test_helper'

class AccountTest < ActionDispatch::IntegrationTest
  fixtures :notes

  test 'user scenario' do
    # Create a new user
    get signup_path
    assert_response :success
    post_via_redirect signup_path, user: { username: 'Integration', email: 'int@gration.test', password: 'testtest',
      password_confirmation: 'testtest' }
    assert_equal login_path, path, 'Signing up failed'
    assert flash[:success]

    # Log in
    post_via_redirect login_path, username: 'Integration', password: 'testtest'
    assert_equal notes_path, path, 'Logging in failed'
    assert flash[:success]

    # Not allowed to access another user's notes
    get_via_redirect note_path(notes(:testnote).permalink)
    assert_equal notes_path, path, 'Not redirected when accessing another user\'s note'
    assert flash[:danger]
    assert_raises(ActiveRecord::RecordNotFound) do
      get edit_note_path(notes(:testnote).permalink)
    end
    assert_raises(ActiveRecord::RecordNotFound) do
      patch note_path(notes(:testnote).permalink), note: { title: 'HAAAAX', text: 'Blah', public: true }
    end
    assert_raises(ActiveRecord::RecordNotFound) do
      delete note_path(notes(:testnote).permalink)
    end

    # Change Password
    get edituser_path
    assert_response :success
    patch_via_redirect edituser_path, password_old: 'testtest', user: { password: 'newnewnew',
      password_confirmation: 'newnewnew'}
    assert_equal notes_path, path, 'Changing the password failed'
    assert flash[:success]

    # Log out
    get_via_redirect logout_path
    assert_equal login_path, path, 'Logout did not redirect to login'
    assert flash[:success]

    # Login and out again with new password
    post_via_redirect login_path, username: 'Integration', password: 'newnewnew'
    assert_equal notes_path, path
    assert flash[:success]
    get_via_redirect logout_path
    assert_equal login_path, path
    assert flash[:success]
  end
end
