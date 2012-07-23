class PingController < ApplicationController
  def ping() render text: DateTime.now.utc.to_s end
end
