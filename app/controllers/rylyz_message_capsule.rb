class RylyzMessageCapsule

  # def initialize (queue, event_type, context, channel_id)
  #   @queue = queue
  #   @event_type = event_type
  #   @context = context
  #   @channel_id = channel_id
  #   @messages = []
  # end

  def initialize
    @events = []
    @context = {}
    @app_channel_id = nil
    @game_channel_id = nil
    @player_channel_id = nil
    @app_name = nil
    @screen_name = nil
  end

  # below accessors are not your typical attribute accessors!
  # equals =(arh) will set the property and return the property value
  # method call (arg) will set the property and reurn self to allow chaining

  # channel IDs
  def app_channel_id=(c) @app_channel_id = c end
  def app_channel_id(c)
    @app_channel_id = c
    self
  end

  def game_channel_id=(c) @game_channel_id = c end
  def game_channel_id(c)
    @game_channel_id = c
    self
  end

  def player_channel_id=(c) @player_channel_id = c end
  def player_channel_id(c)
    @player_channel_id = c
    self
  end

  # context Settings
  def app_name=(n) @app_name = n end
  def app_name(n)
    @app_name = n
    self
  end

  def screen_name=(n) @screen_name = n end
  def screen_name(n)
    @screen_name = n
    self
  end


  def context=(ctx) @context = ctx end
  def context(ctx)
    @context = ctx
    self
  end

  # add events to queue
  def show_data(display_name, data)
    ctx = event_context({displayName: display_name})
    @events << materialize_event('app-server', 'load-data', ctx, data)
    self
  end

  def show_screen(next_screen, settings=nil)
    ctx = event_context
    data = {nextScreen: next_screen}
    data[:settings] = settings unless settings.nil?
    @events << materialize_event('screen', 'navigation', ctx, data)
    self
  end
  def show_me(visitor)
    ctx = event_context
    @events << materialize_event('app-server', 'update-me', ctx, visitor.for_display)
    self
  end
  def start_timer(timer_name)
    ctx = event_context
    data = {name: timer_name}
    @events << materialize_event('timer', 'start-timer', ctx, data)
    self
  end
  def stop_timer(timer_name)
    ctx = event_context
    data = {name: timer_name}
    @events << materialize_event('timer', 'stop-timer', ctx, data)
    self
  end
  def start_animation(animation_name)
    ctx = event_context
    data = {name: animation_name}
    @events << materialize_event('animation', 'start-animation', ctx, data)
    self
  end
  def stop_animation(animation_name)
    ctx = event_context
    data = {name: animation_name}
    @events << materialize_event('animation', 'stop-animation', ctx, data)
    self
  end
  def start_sound(sound_name)
    ctx = event_context
    data = {name: sound_name}
    @events << materialize_event('sound', 'start-sound', ctx, data)
    self
  end
  def stop_sound(sound_name)
    ctx = event_context
    data = {name: sound_name}
    @events << materialize_event('sound', 'stop-sound', ctx, data)
    self
  end
  def call_javascript(function_name, options={})
    raise "app_name has to be set" if @app_name.nil?
    ctx = event_context
    namespace = "#{@app_name}app"
    data = {namespace: namespace, function: function_name, options: options}
    @events << materialize_event('javascript', 'call-function', ctx, data)
    self
  end
  def unregister_timer(timer_name)
    ctx = event_context
    data = {name: timer_name}
    @events << materialize_event('timer', 'unregister-timer', ctx, data)
    self
  end

  def add_css_class(selector, css_class)
    ctx = event_context
    sel = "#ryApp #{selector}" # ensure that the selection happens withing rylyz app only
    data = {selector: sel, cssClass: css_class}
    @events << materialize_event('css', 'add-css-class', ctx, data)
    self
  end
  def remove_css_class(selector, css_class)
    ctx = event_context
    sel = "#ryApp #{selector}" # ensure that the selection happens withing rylyz app only
    data = {selector: sel, cssClass: css_class}
    @events << materialize_event('css', 'remove-css-class', ctx, data)
    self
  end
  def set_css_attribute(selector, css_attribute, css_value)
    ctx = event_context
    sel = "#ryApp #{selector}" # ensure that the selection happens withing rylyz app only
    data = {selector: sel, cssAttribute: css_attribute, cssValue: css_value}
    @events << materialize_event('css', 'set-css-attribute', ctx, data)
    self
  end
  def fade_in(selector)
    ctx = event_context
    sel = "#ryApp #{selector}" # ensure that the selection happens withing rylyz app only
    data = {selector: sel}
    @events << materialize_event('css', 'fade-in', ctx, data)
    self
  end

  def fade_out(selector)
    ctx = event_context
    sel = "#ryApp #{selector}" # ensure that the selection happens withing rylyz app only
    data = {selector: sel}
    @events << materialize_event('css', 'fade-out', ctx, data)
    self
  end

  def enable_button(button_id)
    ctx = event_context
    data = {name: button_id}
    @events << materialize_event('render', 'enable-button', ctx, data)
    self
  end
  def disable_button(button_id)
    ctx = event_context
    data = {name: button_id}
    @events << materialize_event('render', 'disable-button', ctx, data)
    self
  end  
  def exception(msg, info={})
    ctx = event_context
    data = {message: msg}
    # +++ todo log msg and info as error
    @events << materialize_event('exception', 'service-exception', ctx, data)
    self
  end

  # FIRE Event
  def fire2app(channel_id = @app_channel_id)
    PusherChannels.instance.trigger_private_channel_event(channel_id, 'fire-event', @events) unless @events.empty?
  end
  def fire2game(channel_id = @game_channel_id)
    PusherChannels.instance.trigger_private_channel_event(channel_id, 'fire-event', @events) unless @events.empty?
  end
  def fire2player(wid = @player_channel_id)
    @events.each {|e| puts e }
    PusherChannels.instance.trigger_private_channel_event(wid, 'fire-event', @events) unless @events.empty?
  end

  private 

  def event_context(local_context = {})
    ctx = {}
    ctx['appName'] = @app_name if @app_name
    ctx['screenName'] = @screen_name if @screen_name
    ctx.merge!(@context).merge!(local_context)
  end

  def materialize_event(queue, event_type, context={}, data={})
    {
      queue: queue,
      type: event_type,
      context: context,
      data: data
    }
  end

end