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
puts "1 #{@messages.count}"
    events = []
    @messages.each do |message|
puts "x"
      ctx = context_for_display (message[:displayName])
puts ctx
      ev = {queue:@queue, type: @event_type, context:ctx, data: message[:data]}
      events << ev
    end
puts "2 #{events.count}"

    PusherChannels.instance.trigger_private_channel_event(@channel_id, 'fire-event', events) unless events.empty?
puts "3 #{@channel_id}"
  end

end

