class Sudo::SudoController < ApplicationController
  include ActionView::Helpers::TextHelper
  http_basic_authenticate_with :name => "rylyz.games", :password => "play.well" 

  layout "sudo"

end