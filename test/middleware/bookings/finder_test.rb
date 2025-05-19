require "test_helper"

class Bookings::FinderTest < ActiveSupport::TestCase
  test "no params" do
    dates_range = Date.current.beginning_of_month..Date.current.end_of_month
    params = {}

    result = Bookings::Finder.new(account, params, dates_range).call

    assert_equal 5, result.count
  end

  test "filter by resource" do
    dates_range = Date.current.beginning_of_month..Date.current.end_of_month
    params = { resource_id: resource.id }

    result = Bookings::Finder.new(account, params, dates_range).call

    assert_equal 1, result.count
  end

  test "filter by user" do
    dates_range = Date.current.beginning_of_month..Date.current.end_of_month
    params = { user_id: admin.id }

    result = Bookings::Finder.new(account, params, dates_range).call

    assert_equal 3, result.count
  end

  private

    def account
      @account ||= accounts(:account)
    end

    def resource
      @resource ||= resources(:resource)
    end

    def admin
      @admin ||= users(:admin)
    end
end
