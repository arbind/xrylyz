class Sudo::SudoController < ApplicationController
  include ActionView::Helpers::TextHelper
  before_filter :check_for_dot_com_domain
  http_basic_authenticate_with :name => "rylyz.games", :password => "play.well"

  layout "sudo"

end