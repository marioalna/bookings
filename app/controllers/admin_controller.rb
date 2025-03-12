class AdminController < ApplicationController
  before_action :is_admin

  private

    def is_admin
      return if Current.user.role == User::ADMIN

      redirect_to calendar_index_path
      @valid = false
    end
end
