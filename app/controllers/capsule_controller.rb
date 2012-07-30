class CapsuleController < ApplicationController
  @@wygyts_connected = 0

  def setup
    setup = PusherChannels.instance.setup
    render text:"#{setup} - #{DateTime.now}"
  end

  def on_wygyt_opened
    @@wygyts_connected += 1

    wid = params[:wid]
    data = params[:data]
    tokens = JSON.parse(data)
    wid2 = tokens["wid"]
    render json:{status:'error'} unless wid == wid2

    puts "OOooooooooooooooooooooooooooOOOPEN WyGYT #{wid}"

    url = tokens["url"]
    socket_id = tokens["pusher_socket_id"]

    visitor = VISITOR_SOCKETS[socket_id] # this visitor should have been stored when the wygyt authenticated
    visitor.wid = wid
    visitor.source_url = url
    VISITOR_WIDS[wid] = visitor # make visitor available by wid lookup
    # This is where to look up the visitor, and restore their session if previous socket connection was lost 
    # also close any previous wid channels if this is a reconnect

    session_data = {} # +++ TODO send a new session - or retrieve an existing one.

    PusherChannels.instance.trigger_presence_channel_event(wid, "start-session", session_data)
    PusherChannels.instance.trigger_presence_channel_event(wid, "update-me", visitor.for_display)
    render nothing: true
  end

  def on_wygyt_closed
    # +++ TODO !!!
    wid = params[:wid]
    puts "CLOOOoooooooooooooooooooooOOSE WyGYT #{wid}"
    #logout wid
    render nothing: true
  end

  def on_wygyt_event
    wid = params[:wid]
    data = params[:data]
    visitor = VISITOR_WIDS[wid]
    puts "Got some event:"
    puts "wid: #{wid}"
    puts "visitor: #{visitor}"
    puts "data: #{data}"

    render json: {status: 'error', msg:'no visitor found'} and return if visitor.nil?

    tokens = nil
    # t = Thread.new do  <<------
      begin
        # lookup the TargetController
        tokens = JSON.parse(data)
        # context = tokens["context"] || NoOBJECT
        # appName = context["appName"] || "rylyz"
        # appController = "App#{appName.underscore.camelize}Controller"

        # screenName = context["screenName"] || nil
        # screenController = "Screen#{screenName.underscore.camelize}Controller" unless screenName.nil?

        #lookup the method to call
      rescue Exception => e
        puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
        puts "WID Channel Exception for #{target_controller}.#{action}"
        puts "Could not read data in to json"
        puts "data: #{data}"
        puts "Exception: #{e}"
        puts e.backtrace
        puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
        ev = {
          exception: e.to_s
        }
        # puts "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< Sending[#{wid}] server-side-exception"
        self.trigger_presence_channel_event(wid, 'server-side-exception', ev)
        # PusherChannels::socket_logger.info "<<<<<<<<<<<<<<<<<<<<<<<<<<<< Sent server-side-exception [#{wid} (on wid)]"
      ensure
        tokens = tokens || {}
      end
      begin #safeguard the handler block

        controllers = RylyzAppController::lookup_controller(tokens)
        action = tokens["action"] || "action_is_unknown"

        #for hi events, the event type will specify the handler
        if ("hi" == action); action = tokens["type"] || "type_is_unknown" end

        # PusherChannels::socket_logger.info " wid[#{wid}] event: #{action}"

        action = "on_#{action.underscore}"  # e.g "on_load_data" or "on_start_new_game"
        puts "action: #{action}"
        target_controller = nil

        ctrlr = controllers[:display_controller] #see if display controller has a handler
        target_controller = ctrlr if (not ctrlr.nil?) and ctrlr.methods.include?(action.to_sym)

        ctrlr = controllers[:screen_controller]  #else see if scereen controllerhas a handler
        target_controller ||= ctrlr if (not ctrlr.nil?) and ctrlr.methods.include?(action.to_sym)

        ctrlr = controllers[:app_controller]  #else see if app controller has a handler
        target_controller ||= ctrlr if (not ctrlr.nil?) and ctrlr.methods.include?(action.to_sym)

        ctrlr = RylyzAppController   #finally see if rylyz controller has a handler
        target_controller ||= ctrlr if (not ctrlr.nil?) and ctrlr.methods.include?(action.to_sym)

        target_controller.send(action, visitor, tokens) unless target_controller.nil?
        if target_controller.nil?
          msg = "#{action}: handler not found in the display, screen or the app controller! Design ERROR!"
          puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
          puts msg
          puts "tokens: #{tokens}"
          puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
          ev = { exception: msg }
          # puts "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< Sending[#{wid}] server-side-exception"
          self.trigger_presence_channel_event(wid, 'server-side-exception', ev)
          # PusherChannels::socket_logger.info "<<<<<<<<<<<<<<<<<<<<<<<<<<<< Sent server-side-exception [#{wid} (on wid)]"
          render json: { status: 'error', msg:'Controler not found' } and return
        end
        render json: { status: 'ok' } and return
      rescue RuntimeError => e
        puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
        puts "WID Channel Runtime Exception invoking #{target_controller}.#{action}"
        puts "tokens: #{tokens}"
        puts "Exception: #{e}"
        puts e.backtrace
        puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
        #+++TODO make this a convenience function: to trigger exceptions back
        ev = { exception: e.to_s }
        # puts "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< Sending[#{wid}] server-side-exception"
        self.trigger_presence_channel_event(wid, 'server-side-exception', ev)
        # PusherChannels::socket_logger.info "<<<<<<<<<<<<<<<<<<<<<<<<<<<< Sent server-side-exception [#{wid} (on wid)]"
        render json: { status: 'error', msg:'runtime exception' } and return
      rescue Exception => e
        puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
        puts "WID Channel Exception invoking #{target_controller}.#{action}"
        puts "tokens: #{tokens}"
        puts "Exception: #{e}"
        puts e.backtrace
        puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
        ev = { exception: e.to_s }
        # puts "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< Sending[#{wid}] server-side-exception"
        self.trigger_presence_channel_event(wid, 'server-side-exception', ev)
        # PusherChannels::socket_logger.info "<<<<<<<<<<<<<<<<<<<<<<<<<<<< Sent server-side-exception [#{wid} (on wid)]"
        render json: { status: 'error', msg:'exception' } and return
      else
        # Do this if no exception was raised
      ensure
        # Do this whether or not an exception was raised
      end
    # end    <---- Thread.new
    #t.priority = 3
      render json: { status: 'unknown' }
  end

end