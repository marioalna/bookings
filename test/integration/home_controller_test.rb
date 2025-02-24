require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  setup do
    log_in_admin
  end

  test "should get index" do
    get root_url

    assert_response :success
  end
end
