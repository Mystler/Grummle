require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'requires all fields' do
    user = User.new
    assert !user.save, 'Saved user without any data'
  end

  test 'create valid user and log in' do
    user = User.new(username: 'Bob', email: 'bob@bob.com', password: 'pwpwpwpw', password_confirmation: 'pwpwpwpw')
    assert user.save, 'Could not save user'
    assert_not_nil User.find_by_username('Bob').try(:authenticate, 'pwpwpwpw'), 'User login failed'
  end

  test 'username length' do
    user = User.new(username: 'Bo', email: 'bo@bob.com', password: 'pwpwpwpw', password_confirmation: 'pwpwpwpw')
    assert !user.save, 'Saved user with less than 3 characters in the username'
  end

  test 'e-mail format' do
    user = User.new(username: 'Bob1', email: 'bob1@bob', password: 'pwpwpwpw', password_confirmation: 'pwpwpwpw')
    assert !user.save, 'Saved user with invalid e-mail address'
    user = User.new(username: 'Bob2', email: 'bob.com', password: 'pwpwpwpw', password_confirmation: 'pwpwpwpw')
    assert !user.save, 'Saved user with invalid e-mail address'
  end

  test 'password length' do
    user = User.new(username: 'Bob3', email: 'bob3@bob.com', password: 'pw', password_confirmation: 'pw')
    assert !user.save, 'Saved user with less than 8 characters in the username'
  end

  test 'username format' do
    user = User.new(username: 'Bob With Spaces', email: 'bobspace@bob.com', password: 'pwpwpwpw', password_confirmation: 'pwpwpwpw')
    assert !user.save, 'Saved user with spaces in the username'
  end

  test 'login works correctly' do
    assert_not User.find_by_username(users(:testuser).username).try(:authenticate, 'pw'), 'Invalid user logged in'
    assert_not User.find_by_username('doesnotexist').try(:authenticate, 'pw'), 'Invalid user logged in'
    assert_not_nil User.find_by_username(users(:testuser).username).try(:authenticate, 'passawordo'), 'Login failed'
  end
end
