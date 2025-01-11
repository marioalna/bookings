class HomeController < ApplicationController
  allow_unauthenticated_access only: %i[ index ]
  layout "public"

  def index
  end
end
