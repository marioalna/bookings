require 'test_helper'

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    log_in_admin
  end

  test 'should not get index when regular user' do
    log_in_user

    get admin_users_path

    assert_response :redirect
    assert_not @valid
  end

  test 'index' do
    get admin_users_path

    assert_response :success
  end

  test 'should get new' do
    get new_admin_user_path

    assert_response :success
  end

  test 'should create a user' do
    post admin_users_path,
         params: { user: { name: 'New user', username: 'username', email: 'user@test.com', password: 'test' } }

    assert_response :redirect

    user1 = User.last

    assert_equal 'New user', user1.name
    assert_equal 'user@test.com', user1.email
    assert_equal 'username', user1.username
    assert user1.active
  end

  test 'should get edit' do
    get edit_admin_user_path(user)

    assert_response :success
  end

  test 'should update a user' do
    put admin_user_path(user), params: { user: { name: 'Updated user', active: false } }

    assert_response :redirect

    assert_equal 'Updated user', user.reload.name
    assert_not user.reload.active
  end

  test 'should destroy a user' do
    assert_difference 'User.count', -1 do
      delete admin_user_path(user)
    end
  end

  private

    def user
      @user ||= users(:regular)
    end
end
