class ApplicationController < ActionController::Base
  include Authentication
  before_action :set_language
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern

  def set_language
    I18n.locale = params[:locale] || I18n.default_locale
  end
end
