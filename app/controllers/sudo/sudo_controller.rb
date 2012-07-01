class Sudo::SudoController < ApplicationController
  layout "sudo"
  http_basic_authenticate_with :name => "rylyz.games", :password => "play.well" 

end