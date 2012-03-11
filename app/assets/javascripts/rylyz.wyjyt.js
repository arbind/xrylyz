(function() {
var  rylyzPlayerHost = "http://rylyz-player.herokuapp.com";
var  wyjytCSS = rylyzPlayerHost + '/wyjyt/wyjyt.css';

  
var jQuery; // Localized jQuery variable

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
  wyjytSource:{ },
  triggerWyjytChannelConnected: function() {
    //create a private client channel then disconnect from the wyjyt channel
    //+++ refactor so it is independent of Pusher or any socketService!
    console.info("o-- Cycle: about to start wyjyt");

    var ip = 'unknown';
    var src = {
      uid: Rylyz.UID(),
      referrer: document.referrer,
      url: document.URL,
    };
    jQuery.extend(Rylyz.Wyjyt.wyjytSource, src);

    var clientChannelName = src.uid
    var onConnect = function() {
      console.info("x-- subscribed to " +clientChannelName+ "channel!!!")
      Rylyz.Wyjyt.triggerClientChannelConnected();
    };
    var onFail = function(status) {
      console.error("could not establish channel client-rylyz-"+ wyjytSource.uid)
      Rylyz.Wyjyt.triggerClientChannelFailed(status);
    };
    Rylyz.Wyjyt.clientChannel = Rylyz.Pusher.privateChannel(clientChannelName, onConnect, onFail);
  },
  triggerWyjytChannelFailed: function(status) {
    if(status == 408 || status == 503){
      // retry?
    }
  },
  triggerClientChannelConnected: function() {
    //Once we have a private client channel, we can disconnect from the wyjyt channel
    //setup all event handlers for the client connection
    Rylyz.Pusher.onPrivateChannelEvent(Rylyz.Wyjyt.wyjytSource.uid , "start-wyjyt", function(data) { Rylyz.Wyjyt.handleEvent4StartWyjyt(data); });
    var triggered = Rylyz.Pusher.triggerPrivateChannelEvent(Rylyz.Wyjyt.wyjytChannelName, 'start-wyjyt', {});
    //Rylyz.Pusher.closePrivateChannel(Rylyz.Wyjyt.wyjytChannelName);
  },
  triggerClientChannelFailed: function(status) {
    if(status == 408 || status == 503){
      // retry?
    }
  },
  handleEvent4AppInstall: function(datas) {
  },
  handleEvent4StartWyjyt: function(data) {
    Rylyz.Wyjyt.loadChat();
    console.info("o-- Cycle: got data back to Start Wyjyt: " + data);
  },
  openApp: function(appName) {
    console.info("o-- Cycle: about to open app: " + appName);
  },
  suspendApp: function(appName) {
  },
  closeApp: function(appName) {
  },
  load: function() {
    jQuery(document).ready(function($) {
      var css_link = $("<link>", { rel: "stylesheet", type: "text/css", href: wyjytCSS });
      css_link.appendTo('head');

      //setup socket service and register socket event handlers
      var socketSvcLoader = 'load'+socketService;

      //i.e. calls Rylyz.Wyjyt.loadPusher(); or loadWhatever the socket plugin is;
      var triggerSocketServiceLoading = Rylyz.Wyjyt[socketSvcLoader];

      Rylyz.Wyjyt.loadRylyzCore(triggerSocketServiceLoading);

      //load rylyz player html and add it to DOM

      //Rylyz.Wyjyt.installApp();
      //Rylyz.Wyjyt.openApp();

    });
  },
  loadRylyzCore: function(callbackOnComplete) {
    //+++ load all from one js file
    var scriptNames = [ "rylyz.util", "modernizr-2.0.6.js",
      "underscore-min.1.3.1.js" , "backbone-min.0.9.1.js",
      "rylyz.util.js", "rylyz.util.string.js",
      "rylyz.context.js", "rylyz.display.referencetable.js",
      "rylyz.display.object.js", "rylyz.display.collection.js", "rylyz.display.screen.js", "rylyz.display.app.js",
      "rylyz.js", "rylyz.event.js", "rylyz.service.js"
      ];
    console.info("o-- Cycle: about to load javascripts");
    Rylyz.Wyjyt.loadScriptsSerially(rylyzPlayerHost+ "/assets", scriptNames, callbackOnComplete);
  },
  loadPusher: function(){
    console.info("o-- Cycle: about to setup pusher");
    jQuery.getScript(pusherScriptURL, function() { Rylyz.Pusher.setup(); });
  },
  //+++ add other socket loaders here
  loadChat: function() {
    //var channel = Rylyz.Pusher.channel("chat");
    var channel = Rylyz.Pusher.privateChannel(Rylyz.Wyjyt.wyjytChannelName);

    //var channel = Rylyz.Pusher.channel("wyjyt");

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
      triggered = Rylyz.Pusher.triggerPrivateChannelEvent(Rylyz.Wyjyt.wyjytChannelName, 'text-event', data);
      var line = jQuery('<li class="local"></li>').html(data.text)
      display.prepend(line);
    });

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
    var scriptName = scriptNames.shift();
    console.info("Loading Javascript: " + scriptName);
    jQuery.getScript(endpoint+"/"+scriptName, function() {
      Rylyz.Wyjyt.loadScriptsSerially(endpoint, scriptNames, callbackOnComplete);
    });  
  },
}

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

    //create the wyjyt channel its callbacks
    var onConnect = function() {
      console.info("***********************************Subscribe to channel: " + Rylyz.Wyjyt.wyjytChannelName);
      Rylyz.Wyjyt.triggerWyjytChannelConnected();
    }
    var onFail = function(status) {
      console.error("Pusher Error[" +status+ "]: Failed to subscribe to channel: " + Rylyz.Wyjyt.wyjytChannelName);
      Rylyz.Wyjyt.triggerWyjytChannelFailed(status);
    }
    Rylyz.Wyjyt.wyjytChannel = this.privateChannel(Rylyz.Wyjyt.wyjytChannelName, onConnect, onFail);
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
    return this.onChannelEvent("public", channelName, eventName, handler);
  },
  onPrivateChannelEvent: function(channelName, eventName, handler) {
    return this.onChannelEvent("private", channelName, eventName, handler);
  },
  onPresenceChannelEvent: function(channelName, eventName, handler) {
    return this.onChannelEvent("presence", channelName, eventName, handler);
  },
  onChannelEvent: function(scope, channelName, eventName, handler) {
    var scopedEventName = "rylyz-" + eventName;
    if ("public"!=scope) scopedEventName = "client-" + scopedEventName;

    var channel = this.channel(scope, channelName);
    return channel.bind(scopedEventName, handler);
  },
  triggerPublicChannelEvent: function(channelName, eventName, tokens) {
    return this.triggerChannelEvent("public", channelName, eventName, tokens);
  },
  triggerPrivateChannelEvent: function(channelName, eventName, tokens) {
    return this.triggerChannelEvent("private", channelName, eventName, tokens);
  },
  triggerPresenceChannelEvent: function(channelName, eventName, tokens) {
    return this.triggerChannelEvent("presence", channelName, eventName, tokens);
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
    return this.channel("public", channelName, onSuccessCallback, onFailureCallback);
  },
  privateChannel: function(channelName, onSuccessCallback, onFailureCallback) {
    return this.channel("private", channelName, onSuccessCallback, onFailureCallback);
  },
  presenceChannel: function(channelName, onSuccessCallback, onFailureCallback) {
    return this.channel("presence", channelName, onSuccessCallback, onFailureCallback);
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
    return this.closeChannel("public", channelName);
  },
  closePrivateChannel: function(channelName) {
    return this.closeChannel("private", channelName);
  },
  closePresenceChannel: function(channelName) {
    return this.closeChannel("presence", channelName);
  },
  closeChannel: function(scope, channelName) {
    var scopedChannelName = scope + "-rylyz-" + channelName
    return this.singleton.unsubscribe(scopedChannelName);
  },
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
    Rylyz.Wyjyt.load();
  }
}

/******** Called once jQuery has loaded ******/
function restoreJQuery() {
  // Restore $ and window.jQuery to their previous values and store the
  // new jQuery in our local jQuery variable
  jQuery = window.jQuery.noConflict(true);
  // Call our main function
  Rylyz.Wyjyt.load();
}

bootstrap(); //start loading everything

})();