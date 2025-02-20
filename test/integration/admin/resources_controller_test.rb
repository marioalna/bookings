require "test_helper"

class Admin::ResourcesControllerTest < ActionDispatch::IntegrationTest
  setup do
    log_in_admin
  end

  test "should not get index when regular user" do
    log_in_user

    get admin_resources_path

    assert_response :redirect
    assert_not @valid
  end

  test "index" do
    get admin_resources_path

    assert_response :success
  end

  test "should get new" do
    get new_admin_resource_path

    assert_response :success
  end

  test "should create a resource" do
    post admin_resources_path,
         params: { resource: { name: "New resource", max_capacity: 14 } }

    assert_response :redirect

    resource1 = Resource.last

    assert_equal "New resource", resource1.name
    assert_equal 14, resource1.max_capacity
  end

  test "should get edit" do
    get edit_admin_resource_path(resource)

    assert_response :success
  end

  test "should update a resource" do
    put admin_resource_path(resource), params: { resource: { name: "Updated resource", max_capacity: 8 } }

    assert_response :redirect

    assert_equal "Updated resource", resource.reload.name
    assert_equal 8, resource.reload.max_capacity
  end

  test "should destroy a resource" do
    assert_difference "Resource.count", -1 do
      delete admin_resource_path(resource)
    end
  end

  private

    def resource
      @resource ||= resources(:resource)
    end
end
