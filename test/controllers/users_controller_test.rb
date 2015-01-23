require 'test_helper'

# For account functionality testing, see account_test.rb integration tests.
# Here are some tests to ensure invalid edit operations are handled as such.
class UsersControllerTest < ActionController::TestCase
  test 'current password required' do
    do_login
    patch :update, password_old: '', user: { password: 'newnewnew',
      password_confirmation: 'newnewnew', email: 'new@test.com' }
    assert :success
    assert_nil flash[:success]
    assert_nil flash[:warning]
    assert flash[:danger]
    patch :update, password_old: '', user: { email: 'new@test.com' }
    assert :success
    assert_nil flash[:success]
    assert_nil flash[:warning]
    assert flash[:danger]
    patch :update, password_old: 'wrongpw', user: { password: 'newnewnew',
      password_confirmation: 'newnewnew', email: 'new@test.com' }
    assert :success
    assert_nil flash[:success]
    assert_nil flash[:warning]
    assert flash[:danger]
    do_logout
  end

  test 'password confirmation required' do
    do_login
    patch :update, password_old: 'passawordo', user: { password: 'newnewnew',
      password_confirmation: '' }
    assert :success
    assert_nil flash[:success]
    assert_nil flash[:warning]
    assert_nil flash[:danger]
    assert_select 'div.alert-danger' # Validation errors are not flashes
    do_logout
  end
end
