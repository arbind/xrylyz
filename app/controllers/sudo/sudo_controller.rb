class Sudo::SudoController < ApplicationController
  include ActionView::Helpers::TextHelper
  before_filter :redirect_wygyt_to_www
  http_basic_authenticate_with :name => "rylyz.games", :password => "play.well"

  layout "sudo"

end