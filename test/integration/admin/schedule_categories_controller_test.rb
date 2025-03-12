require "test_helper"

class Admin::ScheduleCategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    log_in_admin
  end

  test "should not get index when regular user" do
    log_in_user

    get admin_schedule_categories_path

    assert_response :redirect
    assert_not @valid
  end

  test "index" do
    get admin_schedule_categories_path

    assert_response :success
  end

  test "should get new" do
    get new_admin_schedule_category_path

    assert_response :success
  end

  test "should create a schedule category" do
    post admin_schedule_categories_path,
         params: { schedule_category: { name: "New schedule category", colour: "red", icon: "sun" } }

    assert_response :redirect

    schedule_category1 = ScheduleCategory.last

    assert_equal "New schedule category", schedule_category1.name
    assert_equal "red", schedule_category1.colour
    assert_equal "sun", schedule_category1.icon
  end

  test "should get edit" do
    get edit_admin_schedule_category_path(schedule_category)

    assert_response :success
  end

  test "should update a schedule category" do
    put admin_schedule_category_path(schedule_category),
        params: { schedule_category: { name: "Updated schedule category", colour: "green", icon: "moon" } }

    assert_response :redirect

    assert_equal "Updated schedule category", schedule_category.reload.name
    assert_equal "green", schedule_category.reload.colour
    assert_equal "moon", schedule_category.reload.icon
  end

  test "should destroy a schedule category" do
    assert_difference "ScheduleCategory.count", -1 do
      delete admin_schedule_category_path(schedule_category)
    end
  end

  private

    def schedule_category
      @schedule_category ||= schedule_categories(:schedule_category)
    end
end
