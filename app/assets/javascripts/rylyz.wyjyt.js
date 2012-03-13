(function() {
var  rylyzPlayerHost = "http://rylyz-player.herokuapp.com";
var  wyjytCSS = rylyzPlayerHost + '/assets/wyjyt.css';

  
var jQuery; // Localized jQuery variable
var $; // Localized jQuery variable

window.Rylyz = window.Rylyz || {};
var socketService = "Pusher"; // use this messaging service

var jQueryVersion = '1.7.1';
var jQueryScriptURL = 'https://ajax.googleapis.com/ajax/libs/jquery/' +jQueryVersion+ '/jquery.min.js';
var pusherVersion = '1.11';
var pusherScriptURL = 'http://js.pusher.com/' +pusherVersion+ '/pusher.min.js';

Rylyz.Wyjyt = {
  //channelName: 'private-rylyz',
  wyjytChannelName: 'wyjyt',
  wyjytChannel: null,
  clientChannel: null,
  wyjytSource: {},

  setup: function() {
    jQuery(document).ready(function($) {
      var css_link = $("<link>", { rel: "stylesheet", type: "text/css", href: wyjytCSS });
      css_link.appendTo('head');

      //setup socket service and register socket event handlers
      var socketSvcLoader = 'setup'+socketService; //i.e. setupPusher()
      var triggerSocketServiceLoading = Rylyz.Wyjyt[socketSvcLoader];

      Rylyz.Wyjyt.loadRylyzCore(triggerSocketServiceLoading);
    });
  },
  loadRylyzCore: function(callbackOnComplete) {
    //+++ load all from one js file
    var scriptNames = [ "modernizr-2.0.6.js", "underscore-min.1.3.1.js" , "backbone-min.0.9.1.js",
      "rylyz.util.js", "rylyz.util.string.js",
      "rylyz.context.js", "rylyz.display.referencetable.js",
      "rylyz.display.object.js", "rylyz.display.collection.js", "rylyz.display.screen.js", "rylyz.display.app.js",
      "rylyz.js", "rylyz.event.js", "rylyz.service.js"
      ];
    console.info("o-- Cycle: about to load javascripts");
    Rylyz.Wyjyt.loadScriptsSerially(rylyzPlayerHost+ "/assets", scriptNames, function() {
      // now we can call frameworke functions like Rylyz.UID();
      Rylyz.Wyjyt.wyjytSource.uid = Rylyz.Wyjyt.wyjytSource.uid || Rylyz.UID();
      Rylyz.Wyjyt.wyjytSource.url = document.URL;
      callbackOnComplete(); 
    });
  },
  setupPusher: function(){
    console.info("o-- Cycle: about to setup pusher");
    jQuery.getScript(pusherScriptURL, function() { Rylyz.Pusher.setup(); });
  },
  onWyjytChannelConnected: function() {
      console.info("---------o subscribed to wyjyt channel!!!")
  },
  onWyjytChannelFailed: function(status) {
    console.error("----------! Error [" +status+" ]: Could not establish wyjyt channel!")
    if(status == 408 || status == 503){
      // retry?
    }
  },
  onUIDChannelConnected: function() {
      console.info("---------o subscribed to uid channel: " + Rylyz.uidChannelName())
  },
  onUIDChannelFailed: function(status) {
    console.error("---------! Error [" +status+" ]: Could not establish uid channel: "+ Rylyz.uidChannelName())
    if(status == 408 || status == 503){
      // retry?
    }
  },
  onAppInstall: function(datas) {},
  onAppInstallFail: function(datas) {},
  onSuspendApp: function(appName) {},
  onResumeApp: function(appName) {},
  onCloseApp: function(appName) {},

  start: function(data) {
    Rylyz.Pusher.triggerUIDEvent("open_app", {app:"chat"})
    // Rylyz.Wyjyt.loadChat();
    // console.info("o-- Cycle: got data back to Start Wyjyt: " + data);
  },

  openApp: function(appName) {
    console.info("o-- Cycle: about to open app: " + appName);
  },
  //+++ add other socket loaders here
  loadChat: function() {
    var button  = jQuery('<button class="red">Trigger</button>');
    var textbox = jQuery('<input type="text" name="" value="your text">');
    var display = jQuery('<ul id="rylyz-display"></ul>');
    display.appendTo('#rylyz-widget');
    textbox.appendTo('#rylyz-widget');
    button.appendTo('#rylyz-widget');

    button.bind('click', function() {
      console.log('click');
      var data = {
        "text": textbox.attr('value')
      }
      //alert("about to trigger chat data");
      //var triggered = channel.trigger('client-rylyz-text-event', JSON.stringify(data))
      triggered = Rylyz.Pusher.triggerPrivateChannelEvent(Rylyz.uidChannelName(), 'text-event', data);
      var line = jQuery('<li class="local"></li>').html(data.text)
      display.prepend(line);
    });

    var channel = Rylyz.Pusher.privateChannel(Rylyz.uidChannelName());
    channel.bind('client-rylyz-text-event', function(data) {
      console.log(data);
      var line = jQuery('<li></li>').html(data.text)
      display.prepend(line);
    });
  },

  //loads an array of scripts one at a time from a baseURL (not loaded in parallel)
  loadScriptsSerially: function(endpoint, scriptNames, callbackOnComplete) {
    if (undefined == scriptNames) return;
    if (0 == scriptNames.length) { // all scripts are loaded, call the callback
      if (callbackOnComplete) callbackOnComplete();
      return; 
    }
    jQuery.getScript(endpoint+"/"+scriptNames.shift(),
      function(){
        jQuery = jQuery;
        $ = jQuery;
        Rylyz.Wyjyt.loadScriptsSerially(endpoint, scriptNames, callbackOnComplete);
      }
    );


    // if (0 == scriptNames.length) { // all scripts are loaded, call the callback
    //   if (callbackOnComplete) callbackOnComplete();
    //   return; 
    // }
    // var scriptName = scriptNames.shift();
    // console.info("Loading Javascript: " + scriptName);
    // $ = jQuery;
    // jQuery.getScript(endpoint+"/"+scriptName, function() {
    //   Rylyz.Wyjyt.loadScriptsSerially(endpoint, scriptNames, callbackOnComplete);
    // });  
  },
}
Rylyz.uidChannelName = function() { return Rylyz.Wyjyt.wyjytSource.uid; }

window.Rylyz.Pusher = {
  singleton: null,
  socketID: null,
  channels: {},
  config: {
    authEndpoint: rylyzPlayerHost + '/wyjyt/pusher_auth',
    apiKeyPusher: 'a9206fc7a3b77a7986c5',
  },
  setup: function() {
    WEB_SOCKET_DEBUG = true; // Flash fallback logging - don't include this in production
    Pusher.log = function(message) { if (window.console && window.console.log) window.console.log(message); };    

    // establish a private UID channel
    // once uid channel connects, establish a private wyjyt channel
    // once wyjyt channel connects, let the server know about the UID channel so it can listen
    // the serve will send an ack on new uid channel
    // once ack is received, disconnect from the wyjyt channel

    //create a private client channel then let the widget know about it from the wyjyt channel
    //+++ refactor so it is independent of Pusher or any socketService!
    console.info("o-- Cycle: about to start wyjyt");
    var onConnect, onFail;

    Rylyz.Wyjyt.clientChannel = this.privateChannel(Rylyz.uidChannelName(), this.onUIDChannelConnected, this.onUIDChannelFailed);
    this.onPrivateChannelEvent(Rylyz.uidChannelName(), "started-listening", function(data) {
      Rylyz.Pusher.closePrivateChannel(Rylyz.Wyjyt.wyjytChannelName);
      Rylyz.Wyjyt.start();
    });
    this.onPrivateChannelEvent(Rylyz.uidChannelName(), "open-app", function(data) {
      console.log ("AAAAPPPPENNNNNDINGGG");
      var display = data["display"];
      jQuery("#rylyz-widget").append(display);
      Rylyz.loadAppDisplays();
      Rylyz.showApp('chat', "#rylyz-widget");
    })
  },

  onWyjytChannelConnected: function() {
    Rylyz.Pusher.triggerPrivateChannelEvent(Rylyz.Wyjyt.wyjytChannelName,"open-uid-channel")
    Rylyz.Wyjyt.onWyjytChannelConnected();
    console.info("---------o subscribed to wyjyt channel!!!")
  },
  onWyjytChannelFailed: function(status) {
    console.error("----------! Error [" +status+" ]: Could not establish wyjyt channel!")
    if(status == 408 || status == 503){
      // retry?
    }
    Rylyz.Wyjyt.onUIDChannelFailed(status)
  },
  onUIDChannelConnected: function() {
    Rylyz.Wyjyt.wyjytChannel = Rylyz.Pusher.privateChannel(Rylyz.Wyjyt.wyjytChannelName, Rylyz.Pusher.onWyjytChannelConnected, Rylyz.Pusher.onWyjytChannelFailed);
    Rylyz.Wyjyt.onUIDChannelConnected();
      console.info("---------o subscribed to uid channel: " + Rylyz.uidChannelName())
  },
  onUIDChannelFailed: function(status) {
    console.error("---------! Error [" +status+" ]: Could not establish uid channel: "+ Rylyz.uidChannelName())
    if(status == 408 || status == 503){
      // retry?
    }
    Rylyz.Wyjyt.onUIDChannelFailed(status)
  },
  authenticateConnection: function() {
    if (this.singleton) return this.singleton;
    Pusher.channel_auth_endpoint = Rylyz.Pusher.config.authEndpoint;
    this.singleton = new Pusher(Rylyz.Pusher.config.apiKeyPusher);
    this.singleton.connection.bind('connected', function() {
      var p = Rylyz.Pusher.singleton;
      Rylyz.Pusher.socketID = p.socket_id || p.connection.socket_id;
      Rylyz.Wyjyt.wyjytSource.pusher_socket_id = Rylyz.Pusher.socketID;
    });
    return this.singleton;
  },

  onPublicChannelEvent: function(channelName, eventName, handler) {
    return Rylyz.Pusher.onChannelEvent("public", channelName, eventName, handler);
  },
  onPrivateChannelEvent: function(channelName, eventName, handler) {
    return Rylyz.Pusher.onChannelEvent("private", channelName, eventName, handler);
  },
  onPresenceChannelEvent: function(channelName, eventName, handler) {
    return Rylyz.Pusher.onChannelEvent("presence", channelName, eventName, handler);
  },
  onChannelEvent: function(scope, channelName, eventName, handler) {
    //var scopedEventName = "rylyz-" + eventName;
    //if ("public"!=scope) scopedEventName = "client-" + scopedEventName;
    //$ = jQuery; //rebind jQuery!
    var channel = Rylyz.Pusher.channel(scope, channelName);
    h = function(data) {
        console.info("handling pusher event");
      try {
        handler(data);
      }
      catch (e) {
        console.error("Error handling pusher event: " + eventName + " channel: " + channel.name)
        console.error("Error: " + e)
      }
    }
    return channel.bind(eventName, h);
  },
  triggerUIDEvent: function(action, tokens) {
    data = { action: action }
    jQuery.extend(data, tokens)
    return Rylyz.Pusher.triggerPrivateChannelEvent(Rylyz.uidChannelName(), "event", data);
  },
  triggerPublicChannelEvent: function(channelName, eventName, tokens) {
    return Rylyz.Pusher.triggerChannelEvent("public", channelName, eventName, tokens);
  },
  triggerPrivateChannelEvent: function(channelName, eventName, tokens) {
    return Rylyz.Pusher.triggerChannelEvent("private", channelName, eventName, tokens);
  },
  triggerPresenceChannelEvent: function(channelName, eventName, tokens) {
    return Rylyz.Pusher.triggerChannelEvent("presence", channelName, eventName, tokens);
  },
  triggerChannelEvent: function(scope, channelName, eventName, tokens) {
    var scopedChannelName = scope + "-rylyz-" + channelName;
    var scopedEventName = "rylyz-" + eventName;
    if ("public"!=scope) scopedEventName = "client-" + scopedEventName;
    var channel = this.channel(scope, channelName);
    var payload = this.payload(tokens);
    return channel.trigger(scopedEventName, payload); //add refferrerr, ip, clientUID and stuff
  },
  payload: function(tokens) {
    var p = jQuery.extend({}, Rylyz.Wyjyt.wyjytSource, tokens)
    p = JSON.stringify(p);
    return p;
  },
  publicChannel: function(channelName, onSuccessCallback, onFailureCallback) {
    return Rylyz.Pusher.channel("public", channelName, onSuccessCallback, onFailureCallback);
  },
  privateChannel: function(channelName, onSuccessCallback, onFailureCallback) {
    return Rylyz.Pusher.channel("private", channelName, onSuccessCallback, onFailureCallback);
  },
  presenceChannel: function(channelName, onSuccessCallback, onFailureCallback) {
    return Rylyz.Pusher.channel("presence", channelName, onSuccessCallback, onFailureCallback);
  },
  channel: function(scope, channelName, onSuccessCallback, onFailureCallBack) {
    //+++ check for existing channel name, and state, and re-establish if necessary
    var p = Rylyz.Pusher.singleton;
    if (!p) {
      p = Rylyz.Pusher.authenticateConnection();
      if (!p) throw "Could not establish connection with pusher!";
    };
    //convert all channels to private so they are bi-directional (required by Pusher Trigge API)
    var scopedChannelName = scope + "-rylyz-" + channelName
    var channel = Rylyz.Pusher.channels[scopedChannelName];
    if (channel) {
      //+++check if channel is ok, else destroy it an re-subscribe
      return channel;
    }
    //else create a new channel
    channel = p.subscribe(scopedChannelName);

    if (onSuccessCallback) channel.bind('pusher:subscription_succeeded',onSuccessCallback);
    if (onFailureCallBack) channel.bind('pusher:subscription_error', onFailureCallBack);

    //+++put the channel in a pending state bucket, on sucess, move into a subscribed state
    Rylyz.Pusher.channels[scopedChannelName] = channel;
    return channel;
  },
  closePublicChannel: function(channelName) {
    return Rylyz.Pusher.closeChannel("public", channelName);
  },
  closePrivateChannel: function(channelName) {
    return Rylyz.Pusher.closeChannel("private", channelName);
  },
  closePresenceChannel: function(channelName) {
    return Rylyz.Pusher.closeChannel("presence", channelName);
  },
  closeChannel: function(scope, channelName) {
    var scopedChannelName = scope + "-rylyz-" + channelName
    return Rylyz.Pusher.unsubscribe(scopedChannelName);
  },
  unsubscribe: function(channelName) {
    Rylyz.Pusher.authenticateConnection().unsubscribe(channelName);
  }
};


// ========= Bootstrap utilities =========
function bootstrap(){
  localizeJQuery(); //load jquery first, then calls Rylyz.Wyjyt.load().
};

function localizeJQuery() {
  if (window.jQuery === undefined || window.jQuery.fn.jquery !== jQueryVersion) {
    var script_tag = document.createElement('script');
    script_tag.setAttribute("type","text/javascript");
    script_tag.setAttribute("src", jQueryScriptURL);
    if (script_tag.readyState) {
      script_tag.onreadystatechange = function () { // For old versions of IE
        if (this.readyState == 'complete' || this.readyState == 'loaded') restoreJQuery();
      };
    } 
    else { script_tag.onload = restoreJQuery; }
    (document.getElementsByTagName("head")[0] || document.documentElement).appendChild(script_tag);
  } else {
    jQuery = window.jQuery; // The jQuery version on the window is the one we want to use
    $ = jQuery
    Rylyz.Wyjyt.setup();
  }
}

/******** Called once jQuery has loaded ******/
function restoreJQuery() {
  // Restore $ and window.jQuery to their previous values and store the
  // new jQuery in our local jQuery variable
  jQuery = window.jQuery.noConflict(true);
  $ = jQuery;
  if (undefined == window.jQuery) window.jQuery = jQuery
  if (undefined == window.$) window.$ = jQuery
  // Call our main function
  Rylyz.Wyjyt.setup();
}

bootstrap(); //start loading everything

})();