require "test_helper"

class CalendarControllerTest < ActionDispatch::IntegrationTest
  setup do
    log_in_admin
  end

  test "index" do
    get calendar_index_path

    assert_response :success
  end
end
