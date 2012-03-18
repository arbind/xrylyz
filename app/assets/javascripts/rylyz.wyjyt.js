(function() {
var  rylyzPlayerHost = "http://rylyz-player.herokuapp.com";
var  wyjytCSS = 'rylyz.wyjyt';

  
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

  fetchCSS: function(name) {
    var css_href = rylyzPlayerHost + '/assets/' + name + ".css";
    var css_link = $("<link>", { rel: "stylesheet", type: "text/css", href: css_href });
    css_link.appendTo('head');
  },
  setup: function() {
    jQuery(document).ready(function($) {
      Rylyz.Wyjyt.fetchCSS(wyjytCSS);

      //setup socket service and register socket event handlers
      var socketSvcLoader = 'setup'+socketService; //i.e. setupPusher()
      var triggerSocketServiceLoading = Rylyz.Wyjyt[socketSvcLoader];

      Rylyz.Wyjyt.loadRylyzCore(triggerSocketServiceLoading);
    });
  },
  loadRylyzCore: function(callbackOnComplete) {
    if (Rylyz.Service) {
      callbackOnComplete();
      return;
    }
    //+++ load all from one js file
    var scriptNames = [ "modernizr-2.0.6.js", "underscore-min.1.3.1.js" , "backbone-min.0.9.1.js",
      "rylyz.util.js", "rylyz.util.string.js",
      "rylyz.context.js", "rylyz.display.referencetable.js",
      "rylyz.display.object.js", "rylyz.display.collection.js", "rylyz.display.screen.js", "rylyz.display.app.js",
      "rylyz.js", "rylyz.event.js", "rylyz.service.js"
      ];
    console.info("o-- Cycle: about to load javascripts");
    Rylyz.Wyjyt.loadScriptsSerially(rylyzPlayerHost+ "/assets", scriptNames, function() {
      // now we can call framework functions like Rylyz.wid();
      Rylyz.Wyjyt.wyjytSource.wid = Rylyz.Wyjyt.wyjytSource.wid || Rylyz.materializeUID();
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
  onWIDChannelConnected: function() {
      console.info("---------o subscribed to wid channel: " + Rylyz.wid())
  },
  onWIDChannelFailed: function(status) {
    console.error("---------! Error [" +status+" ]: Could not establish wid channel: "+ Rylyz.wid())
    if(status == 408 || status == 503){
      // retry?
    }
  },
  onChannelConnected: function(chanelName) {
    console.info("---------o subscribed to custom channel: " + chanelName);
  },
  onChannelFailed: function(status) {
    console.error("---------! Error [" +status+" ]: Could not establish channel: "+ Rylyz.wid())
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
    var app_name = data["app"];
    Rylyz.Wyjyt.fetchCSS("app_" + app_name);
    Rylyz.Pusher.triggerWIDEvent("open_app", data)
    // Rylyz.Wyjyt.loadChat();
    // console.info("o-- Cycle: got data back to Start Wyjyt: " + data);
  },

  openApp: function(appName) {
    console.info("o-- Cycle: about to open app: " + appName);
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
  },

  triggerWIDEvent: function(action, tokens) {
    Rylyz[socketService].triggerWIDEvent(action, tokens);
  },
  triggerPublicChannelEvent: function(channelName, eventName, tokens) {
    Rylyz[socketService].triggerPublicChannelEvent(channelName, action, tokens);
  },
  triggerPrivateChannelEvent: function(channelName, eventName, tokens) {
    Rylyz[socketService].triggerPrivateChannelEvent(channelName, action, tokens);
  },
  triggerPresenceChannelEvent: function(channelName, eventName, tokens) {
    Rylyz[socketService].triggerPresenceChannelEvent(channelName, action, tokens);
  },



}
Rylyz.wid = function() { return Rylyz.Wyjyt.wyjytSource.wid; }

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

    // establish a private WID channel
    // once wid channel connects, establish a private wyjyt channel
    // once wyjyt channel connects, let the server know about the wID channel so it can listen
    // the serve will send an ack on new wid channel
    // once ack is received, disconnect from the wyjyt channel

    //create a private client channel then let the widget know about it from the wyjyt channel
    //+++ refactor so it is independent of Pusher or any socketService!
    console.info("o-- Cycle: about to start wyjyt");
    var onConnect, onFail;

    Rylyz.Wyjyt.clientChannel = Rylyz.Pusher.privateChannel(Rylyz.wid(), Rylyz.Pusher.onWIDChannelConnected, Rylyz.Pusher.onWIDChannelFailed);
    Rylyz.Pusher.onPrivateChannelEvent(Rylyz.wid(), "started-listening", function(data) {
      Rylyz.Pusher.closePrivateChannel(Rylyz.Wyjyt.wyjytChannelName);
      Rylyz.Wyjyt.start({app:'connect4'});
    });
    Rylyz.Pusher.onPrivateChannelEvent(Rylyz.wid(), "open-app", function(data) {
      var display = data["display"];
      jQuery("#rylyz-widget").append(display);
      Rylyz.loadAppDisplays();
      //Rylyz.showApp('chat', "#rylyz-widget");
      Rylyz.showApp('connect4', "#rylyz-widget");
    });

    Rylyz.Pusher.onPrivateChannelEvent(Rylyz.wid(), "update-me", function(data) {
      Rylyz.me = data; ///+++ turn this into a Model Class that can be referenced by other displays
    });

    Rylyz.Pusher.onPrivateChannelEvent(Rylyz.wid(), "fire-event", function(data) {
      Rylyz.event.fireEvent(data);
    });
    Rylyz.Pusher.onPrivateChannelEvent(Rylyz.wid(), "server-side-exception", function(data) {
      Rylyz.Service.reportServerSideException(Rylyz.wid(), data)
    });
    Rylyz.Pusher.onPrivateChannelEvent(Rylyz.wid(), "launch-listener", function(data) {
      scope = data["scope"];
      wid = data["wid"];
      launchChannel = data["launchChannel"];
      //+++TODO: break this into 2 = launch-channel-listener and launch-channel-event-listner
      chanelEvents = data['channelEvents'];
      if (wid != Rylyz.wid()) throw "Received incomprehensible event: " + data;
      onConnect = function(){ Rylyz.Pusher.onChannelConnected(launchChannel); }
      channel = Rylyz.Pusher.channel(scope, launchChannel, onConnect, Rylyz.Pusher.onChannelFailed);
      Rylyz.Pusher.channels[launchChannel] = channel;
      ///+++TODO: save channel based on context so it can be unloaded
      Rylyz.Pusher.onPrivateChannelEvent(launchChannel, "chat", function(data) {
        //++TODO: get eventNames to listen to from the launchChannel event, and add a listener to each one.
        alert("whohoo got a chat event: " + data)
      });
      Rylyz.Pusher.onPrivateChannelEvent(launchChannel, "fire-event", function(ev) {
        Rylyz.event.fireEvent(ev);
      });      
      Rylyz.Pusher.onPrivateChannelEvent(launchChannel, "server-side-exception", function(data) {
        Rylyz.Service.reportServerSideException(launchChannel, data)
        var exception = data["exception"];
        console.error("Server Side Exception!\n Message: " + exception)
      });
    });
  },

  onWyjytChannelConnected: function() {
    Rylyz.Pusher.triggerPrivateChannelEvent(Rylyz.Wyjyt.wyjytChannelName,"open-wid-channel")
    Rylyz.Wyjyt.onWyjytChannelConnected();
    console.info("---------o subscribed to wyjyt channel!!!")
  },
  onWyjytChannelFailed: function(status) {
    console.error("----------! Error [" +status+" ]: Could not establish wyjyt channel!")
    if(status == 408 || status == 503){
      // retry?
    }
    Rylyz.Wyjyt.onWIDChannelFailed(status)
  },
  onWIDChannelConnected: function() {
    Rylyz.Wyjyt.wyjytChannel = Rylyz.Pusher.privateChannel(Rylyz.Wyjyt.wyjytChannelName, Rylyz.Pusher.onWyjytChannelConnected, Rylyz.Pusher.onWyjytChannelFailed);
    Rylyz.Wyjyt.onWIDChannelConnected();
      console.info("---------o subscribed to wid channel: " + Rylyz.wid())
  },
  onWIDChannelFailed: function(status) {
    console.error("---------! Error [" +status+" ]: Could not establish wid channel: "+ Rylyz.wid())
    if(status == 408 || status == 503){
      // retry?
    }
    Rylyz.Wyjyt.onWIDChannelFailed(status)
  },
  onChannelConnected: function(chanelName) {
    Rylyz.Wyjyt.onChannelConnected(chanelName);
    console.info("---------o subscribed to custom channel: " + chanelName);
  },
  onChannelFailed: function(status) {
    console.error("---------! Error [" +status+" ]: Could not establish channel")
    if(status == 408 || status == 503){
      // retry?
    }
    Rylyz.Wyjyt.onChannelFailed(status)
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
  triggerWIDEvent: function(action, tokens) {
    data = { action: action }
    jQuery.extend(data, tokens)
    return Rylyz.Pusher.triggerPrivateChannelEvent(Rylyz.wid(), "event", data);
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
    return channel.trigger(scopedEventName, payload); //add refferrerr, ip, clientWID and stuff
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

//some debug functions
window.rylyzRefreshCSS = Rylyz.Wyjyt.refreshCSS;

bootstrap(); //start loading everything

})();