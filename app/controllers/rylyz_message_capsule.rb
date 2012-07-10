class RylyzMessageCapsule

  def initialize (queue, event_type, context, channel_id)
    @queue = queue
    @event_type = event_type
    @context = context
    @channel_id = channel_id
    @messages = []
  end

  def context_for_display (display_name)
    if display_name
      ctx = @context.merge({displayName: display_name}) 
    else
      ctx = @context.merge({})
    end
  end

  def build_events 
    yield @messages
  end

  def notify
    events = []
    puts "notfiying for #{@event_type} with #{@messages.count}"
    @messages.each do |message|
      ctx = context_for_display (message[:displayName])
      ev = {queue:@queue, type: @event_type, context:ctx, data: message[:data]}
      events << ev
    end

    PusherChannels.instance.trigger_private_channel_event(@channel_id, 'fire-event', events) unless events.empty?
  end

end

