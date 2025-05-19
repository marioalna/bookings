module Notifications
  class FlashComponent < ViewComponent::Base
    attr_reader :flash

    def initialize(flash)
      @flash = flash
    end

    def render?
      flash.any?
    end

    def banner_type(type)
      case type.to_s
      when "alert", "error"
        "bg-red-800 text-red-100"
      else
        "bg-indigo-800 text-indigo-100"
      end
    end
  end
end
