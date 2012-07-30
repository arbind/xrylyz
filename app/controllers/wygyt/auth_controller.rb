class Wygyt::AuthController < ApplicationController
  include ApplicationHelper
  protect_from_forgery :except => :pusher_auth

  def pusher_access
    # puts "+++++++++++++++++++++++++++++++++++++++++++++++"
    # puts params
    # puts "+++++++++++++++++++++++++++++++++++++++++++++++"
    if pusher_should_deny_access?
      render :json => "bad_robot".to_json and return
    else
      user_data = nil
      enable_CORS_access
      socket_id = params[:socket_id]
      scoped_channel_name = params[:channel_name]

      regx = scoped_channel_name.match /^private-rylyz-(.+)/
      regx ||= scoped_channel_name.match /^public-rylyz-(.+)/
      regx ||= (presence_regx = scoped_channel_name.match /^presence-rylyz-(.+)/)
     
      render :json => "bad_robot".to_json and return if regx.nil?
      channel_name = regx[1] # get the channel_name from the scoped_channel_name
      render :json => "bad_robot".to_json and return if channel_name.nil?

      if presence_regx
        wid = channel_name # basically the unique wid is this channel_name for ech wygyt
        user_data =  { :user_id => wid } # can optionally add other stuff in here
        puts "!!!!Authorizing Presence Channel for #{wid}"
      end

      pusher_response = Pusher[scoped_channel_name].authenticate(socket_id, user_data)

      puts "!!!!! AUTHORIZING: pusher_response: #{pusher_response}"
      puts params

      # if all is well, create a visitor session
      v = RyVisitor.new
      v.socket_id = socket_id
      puts "!!!!!!!!! There is already a visitor for this socket[#{socket_id}]" if VISITOR_SOCKETS[socket_id]
      VISITOR_SOCKETS[socket_id]=v  #make this visitor available by socket_id
      render :json => pusher_response
    end
  end

  private

  # def pusher_presence_channel_response(pusher_response)
  #   json_user_data = JSON.generate({
  #     :user_id => 10, 
  #     :user_info => {:name => 'Mrs. Pusher'}
  #   })

  #   { channel_data:json_user_data }.merge(pusher_response)

  # end

  def pusher_should_deny_access?
    #lookup request referrer to see if website domain is registered for rylyz
    false
  end

  def enable_CORS_access
    return if pusher_should_deny_access?
    headers['Access-Control-Allow-Credentials'] = 'true'
    headers['Access-Control-Allow-Methods']     = 'GET, POST, OPTIONS'
    headers['Access-Control-Allow-Headers']     = 'Content-Type, *'
    headers['Access-Control-Allow-Origin']      = '*'
  end

end
