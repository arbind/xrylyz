(function($) {

	window.Rylyz = window.Rylyz || {};
	
	window.Rylyz.Service = {};
	window.Rylyz.Service = {

		//Exception reporting
		reportServerSideException: function(channel, data) {
      var exception = data["exception"];
      console.error("Service Exception received on ch: "+channel+" !\n Message: " + exception);
    },
    
		//Data Events
		fireDataEvent4Load: function(event) {
			Rylyz.Wygyt.triggerWIDEvent("load-data", event)
		},

		handleDataEvent4LoadData: function(events) {
			//var screen = Rylyz.lookupScreen(event);
			//if (screen) screen.model.set(event.data);
			var eventList = events;
			if (!$.isArray(eventList)) eventList = [events];

			$.each(eventList, function(idx, event) {
				var display = Rylyz.lookupDisplay(event);
				if (display) {
					if ($.isArray(event.data)){
						if (!display.isCollection()) throw "Can not update object data with a collection (must be an object).";
              display.collection.reset(event.data);
            }
			  	else {
						if (display.isCollection()) throw "Can not update collection data with an  object (must be an array).";
			    	display.model.set(event.data);
			 	 	}
			 	 }
			 	 else {
			 	 	console.warn("Display not found! Can not load screen data." + event);
			 	 	if (!event.context) return;
			 	 	console.warn("appName: " + event.context.appName);
			 	 	console.warn("screenName: " + event.context.screenName);
			 	 	console.warn("displayName: " + event.context.displayName);
			 	 }
			});
		},
		handleDataEvent4UpdateObject: function(event) {
		},
		handleDataEvent4AddCollectionItem: function(event) {
			display = Rylyz.lookupDisplay(event);
			//+++ check display
			var data = event['data'];
			//+++check data
			display.collection.add(data);
		},
		handleDataEvent4RemoveCollectionItem: function(event) {
		},

    handleAddCSSClass: function(event) {
      var cssList = event.data;
      if (!$.isArray(cssList)) cssList = [event.data];

      var selector, cssClass;
      $.each(cssList, function(idx, item) {
        selector = item['selector'];
        cssClass = item['cssClass'];
        jQuery(selector).addClass(cssClass);
        console.log('Adding class ' +cssClass+ 'to ' + selector)
      });

    },
    handleRemoveCSSClass: function(event){
      var cssList = event.data;
      if (!$.isArray(cssList)) cssList = [event.data];

      var selector, cssClass;
      $.each(cssList, function(idx, item) {
        selector = item['selector'];
        cssClass = item['cssClass'];
        jQuery(selector).removeClass(cssClass);
      });
    },
    handleSetCSSAttribute: function(event){
      var cssList = event.data;
      if (!$.isArray(cssList)) cssList = [event.data];

      var selector, cssAttribute, cssValue;
      $.each(cssClassList, function(idx, item) {
        selector = item['selector'];
        cssAttribute = item['cssAttribute'];
        cssValue = item['cssValue'];
        jQuery(selector).css(cssAttribute, cssValue);
      });
    },

    handleStartTimer: function(event) {
      var data = event['data'];
      if (!data) throw "No timer name was specified";
      var timerName = data['name'];
      timerName = timerName  || data['timer-name'];
      if (!timerName) throw "No timer named " +timerName+ " was specified";

      Rylyz.timer.start(timerName);

      // +++ Todo - make these params into options for the timer
      // var repeat = data['repeat'];
      // if (repeatTimer) repeatTimer = true;
      // else repeatTimer = false

      // var milliseconds = data['milliseconds'];
      // milli = -1
      // if (milliseconds) milli  = parseInt(milliseconds);

      // if (repeat && milli)
      //   Rylyz.timer.start(timerName, milli, repeatTimer);
      // else if (milli)
      //   Rylyz.timer.start(timerName, milli);
      // else
      //   Rylyz.timer.start(timerName);
    },
    handleStopTimer: function(event) {
      var data = event['data'];
      if (!data) throw "No timer name was specified";
      var timerName = data['name'];
      timerName = timerName  || data['timer-name'];
      if (!timerName) throw "No timer name was specified";

      Rylyz.timer.stop(timerName);
    },
    handleUnregisterTimer: function(event) {
      var data = event['data'];
      if (!data) throw "No timer name was specified";
      var timerName = data['name'];
      timerName = timerName  || data['timer-name'];
      if (!timerName) throw "No timer name was specified";

      Rylyz.timer.unregister(timerName);
    },
    handleCallJavascript: function(event){
      // +++ to test
      var data = event['data'];
      if (!data) throw "No javascript function name was specified";
      var namespace = data['namespace'];
      if (!namespace) throw "No javascript namespace was given: Rylyz.js.[namespace] must be used to call javascript methods";
      var functionName = data['function'];
      functionName = functionName || data['method'];
      ns = Rylyz.js[namespace]
      if (!ns) throw "No javascript namespace found for: Rylyz.js." + namespace + "!\nUse Rylyz.makeNamespace('" +namespace+ "') to define the namespace.\n Then create your functions in this namespace like this:\n\nvar " +namespace+ " = Rylyz.makeNamespace('" +namespace+ "');\n" +namespace+ ".myFunction = function(arg){\n  console.log('arg: ' + arg);\n}\n\n The naming convention for your namespace is: [appname]app";
      fn = ns[functionName]
      var isFunction  = !!(fn && fn.constructor && fn.call && fn.apply)
      if (!isFunction) throw "No javascript function is defined: Rylyz.js." + functionName + "()";
      var options = data['options']
      if (options) fn(options);
      else fn();
    },
		fireHIEvent: function(event) {
      Rylyz.Wygyt.triggerWIDEvent("hi", event);
		},
		fireHIEvent4DataInput: function(event) {
      var ev = {
      	queue: event.queue,
      	type: event.type,
      	context: event.context,
      	settings: event.settings,
      	formData: event.formData
      }
      Rylyz.Wygyt.triggerWIDEvent("data-input", ev);

		},
		fireHIEvent4Navigation: function(event) {
      var nextScreen = event.nextScreen
      var data = event.data
      if (!nextScreen) nextScreen = data.nextScreen
      if (!nextScreen) throw "Navigation event must specify nextScreen! " + event;
      var nextScreenRoute = {
        appName: Rylyz.lookupProperty('appName', event),
        screenName: nextScreen
      }
      var screen = Rylyz.lookupScreen(nextScreenRoute);
      if (!screen) throw "A screen named '" +nextScreen+ "'' can not be found to handle this navigation event!";

      var settings = {}
      if (data) settings = data.settings
      if (event.select) settings.select = event.select;

      console.log ("about to show next screen " + nextScreen + " with settings " + settings);
      Rylyz.showScreenWithFadeIn(screen, settings);

      // var nextScreen = event.nextScreen
      // if (!nextScreen && event.data) nextScreen = event.data.nextScreen
      // if (!nextScreen) throw "Navigation event must specify nextScreen! " + event;
      // var nextScreenRoute = {
      // 	appName: Rylyz.lookupProperty('appName', event),
      // 	screenName: nextScreen
      // }
      // var screen = Rylyz.lookupScreen(nextScreenRoute);
      // if (!screen) throw "A screen named '" +nextScreen+ "'' can not be found to handle this navigation event!";
      // var newSettings = event.settings
      // if (!newSettings && event.data) newSettings  = event.data.settings;
      // if (!newSettings) newSettings = {}
      // if (event.select) newSettings.select = event.select;

      // console.log ("about to show next screen " + nextScreen + " with settings " + settings);
      // Rylyz.showScreenWithFadeIn(screen, newSettings);
		},
		fireHIEvent4Intent: function(event) {
      if (!event.intent) throw "Intent event must specify an intent! " + event;
      Rylyz.Intent.open(event.intent);
		},
	};

		/*


		ev = event;
		+++ if (currentApp().currentScreen().fireHiEvent4xxx) {
			ev = currentApp().currentScreen().fireHiEvent4xxx(ev) { //screen can override and morph the event if needed
			if (!ev) return; //fire method has been overriden by the screen and returned false.
		}
		fireHiEvent(ev), fireDataEvent(ev), etc..

	  //specify serverPlugin: URLbased, Pusher, other?

			ServerPlugin:
			  fireHIEvent(event)
			  fireDataEvent(event)
			  fireTimerEvent(event)



		handleDataEvent4Load: function(events) {
			var eventList = events;
			if (!$.isArray(eventList)) eventList = [events]; //place into array

			$.each(eventList, function(idx, event) {
				var display = Rylyz.lookupDisplay(event);
				if (display) {
					if ($.isArray(event.data)){
						if (!display.isCollection) throw "Can not update object data with a collection (must be an object).";
				    display.collection.reset(event.data);
			  	}
			  	else {
						if (display.isCollection) throw "Can not update collectoin data with an  object (must be an array).";
			    	display.model.set(event.data);
			 	 	}
			 	 }
		 	 	
	   //    //var dataCollection = Rylyz.refTables.collections[event.name] || null;
	   //    var modelData = Rylyz.currentApp.currentScreen.referenceTable.lookupData(event.name) || null;
				// if ($.isArray(event.data)){
  		//     modelData.reset(event.data);
  	 //  	}
  	 //  	else {
	   //    	//var dataObject = Rylyz.refTables.models[event.name];
		  //   	modelData.set(event.data);
		 	//  	}
		 	 	
		 	})
		},
		//User/Client events fired to Service
		fireTimerEvent: function(event) {
      var url = Rylyz.urlAPI + "/fire/hi_event/timer.json";
      if (DBUG) dbugOut("sending event to server:" + url);
      $.get(url, event, function(response){console.log(response)});
		},
		fireHIEvent4Chat: function(event) {
      var url = Rylyz.urlAPI + "/fire/hi_event/chat.json";
      if (DBUG) dbugOut("sending event to server:" + url);
      $.get(url, event, function(response){console.log(response)});
		},
		fireHIEvent4Intention: function(event) {
      var url = Rylyz.urlAPI + "/fire/hi_event/intention.json";
      if (DBUG) dbugOut("sending event to server:" + url);
      $.get(url, event, function(response){console.log(response)});
		},
		fireHIEvent4Reservation: function(event) {
      var url = Rylyz.urlAPI + "/fire/hi_event/reservation.json";
      if (DBUG) dbugOut("sending event to server:" + url);
      $.get(url, event, function(response){console.log(response)});
		},
		fireHIEvent4CancelingReservation: function(event) {
      var url = Rylyz.urlAPI + "/fire/hi_event/reservation.json";
      if (DBUG) dbugOut("sending event to server:" + url);
      $.get(url, event, function(response){console.log(response)});
		},
		fireHIEvent4Screen: function(event) {
      var url = Rylyz.urlAPI + "/fire/hi_event/screen.json";
      if (DBUG) dbugOut("sending event to server:" + url);
      $.get(url, event, function(response){console.log(response)});
		},
		fireHIEvent4App: function(event) {
      var url = Rylyz.urlAPI + "/fire/hi_event/app.json";
      if (DBUG) dbugOut("sending event to server:" + url);
      $.get(url, event, function(response){console.log(response)});
		},
		fireHIEvent4Widget: function(event) {
      var url = Rylyz.urlAPI + "/fire/hi_event/widget.json";
      if (DBUG) dbugOut("sending event to server:" + url);
      $.get(url, event, function(response){console.log(response)});
		},

		//Game Events received from Service
		handleGameEvent: function(event) {

		},
		handleGameEvent4Timer: function(event) {

		},
		handleGameEvent4Chat: function(event) {

		},
		handleGameEvent4Reservation: function(event) {

		},
		handleGameEvent4Animation: function(even) {

		},
		handleGameEvent4MindLink: function(event) {

		},
		handleGameEvent4Navigation: function(event) {

		},
		handleGameEvent4Screen: function(event) {

		},
		handleGameEvent4App: function(event) {

		},
		handleGameEvent4Widget: function(event) {

		},
		*/



  var hFireHIEvent = {
		queue:"hi",
    handleEvent: function(ev) {
    	Rylyz.Service.fireHIEvent(ev);
    }
  }
  Rylyz.event.registerQueueHandler(hFireHIEvent);


  var hAddItem = {
		queue:"app-server",
		type:"add-item",
    handleEvent: function(ev) {
    	Rylyz.Service.handleDataEvent4AddCollectionItem(ev);
    }
  }
  Rylyz.event.registerEventHandler(hAddItem);

  var hLoadData = {
		queue:"app-server",
		type:"load-data",
    handleEvent: function(ev) {
    	Rylyz.Service.handleDataEvent4LoadData(ev);
    }
  }
  Rylyz.event.registerEventHandler(hLoadData);


  var hStartTimer = {
    queue:"timer",
    type:"start-timer",
    handleEvent: function(ev) {
      Rylyz.Service.handleStartTimer(ev);
    }
  }
  Rylyz.event.registerEventHandler(hStartTimer);

  var hStopTimer = {
    queue:"timer",
    type:"stop-timer",
    handleEvent: function(ev) {
      Rylyz.Service.handleStopTimer(ev);
    }
  }
  Rylyz.event.registerEventHandler(hStopTimer);

  var hUnregisterTimer = {
    queue:"timer",
    type:"unregister-timer",
    handleEvent: function(ev) {
      Rylyz.Service.handleUnregisterTimer(ev);
    }
  }
  Rylyz.event.registerEventHandler(hUnregisterTimer);

 var hCallJavascript = {
    queue:"javascript",
    type:"call-function",
    handleEvent: function(ev) {
      Rylyz.Service.handleCallJavascript(ev);
    }
  }
  Rylyz.event.registerEventHandler(hCallJavascript);

 
  var hScreenNavigation = {
    queue: "screen",
    type: "navigation",
    handleEvent: function(ev) { Rylyz.Service.fireHIEvent4Navigation(ev); }
  }
  Rylyz.event.registerEventHandler(hScreenNavigation);

  var hNavOnClick = {
    queue: "nav",
    type: "nav-onClick", 
    handleEvent: function(ev) {
    	ev.nextScreen = ev["nextScreen"] || ev["nav-onClick"]; //
    	Rylyz.Service.fireHIEvent4Navigation(ev);
    }
  }
  Rylyz.event.registerEventHandler(hNavOnClick);


  var hIntentOnClick = {
    queue: "intent",
    type: "intent-onClick", 
    handleEvent: function(ev) {
    	ev.intent = ev["intent-onClick"]; //
    	Rylyz.Service.fireHIEvent4Intent(ev);
    }
  }
  Rylyz.event.registerEventHandler(hIntentOnClick);


  // var hLoadApp = {
  //   queue: "screen",
  //   type: "navigation",
  //   handleEvent: function(ev) { Rylyz.Service.fireHIEvent4Navigation(ev); }
  // }
  // Rylyz.event.registerQueueHandler(hLoadApp);

  var hFormSubmit = {
  	queue: "form",
  	type: "submit",
  	handleEvent: function(ev) { 
      f = srcElementForDOMEvent(ev.domEvent);
      var formData = extractFormData(f);
      ev.formData = formData;

      var display = Rylyz.lookupDisplay(ev);
      //if form should only be submitted once, unbind its submit handler:
      /*
      display.$("form").unbind('submit'); //+++actually get form from the ev
      display.$("form").submit(function(){
        //send app message that form is already submitted
        display.app.flash("Already Submitted!");
        return false;
      }); //make sure a form is submitted only once
			*/
      Rylyz.Service.fireHIEvent4DataInput(ev);
      //+++fire event to send formData to server
  	}
  }
  Rylyz.event.registerEventHandler(hFormSubmit);


  var hAddCSSClass = {
    queue:"css",
    type:"add-css-class",
    handleEvent: function(ev) {
      Rylyz.Service.handleAddCSSClass(ev);
    }
  }
  Rylyz.event.registerEventHandler(hAddCSSClass);

  var hRemoveCSSClass = {
    queue:"css",
    type:"remove-css-class",
    handleEvent: function(ev) {
      Rylyz.Service.handleRemoveCSSClass(ev);
    }
  }
  Rylyz.event.registerEventHandler(hRemoveCSSClass);

  var hSetCSSAttribute = {
    queue:"css",
    type:"set-css-attribute",
    handleEvent: function(ev) {
      Rylyz.Service.handleSetCSSAttribute(ev);
    }
  }
  Rylyz.event.registerEventHandler(hSetCSSAttribute);

  var hEnableButton = {
    queue:"render",
    type:"enable-button",
    handleEvent: function(ev) {
      throw "handler not yet implemented: " + ev
      //Rylyz.Service.handle__(ev);
    }
  }
  Rylyz.event.registerEventHandler(hEnableButton);

  var hDisableButton = {
    queue:"render",
    type:"disable-button",
    handleEvent: function(ev) {
      throw "handler not yet implemented: " + ev
      //Rylyz.Service.handle__(ev);
    }
  }
  Rylyz.event.registerEventHandler(hDisableButton);

  var hStartAnimation = {
    queue:"animation",
    type:"start-animation",
    handleEvent: function(ev) {
      Rylyz.Service.handleStartAnimation(ev);
    }
  }
  Rylyz.event.registerEventHandler(hStartAnimation);

  var hStopAnimation = {
    queue:"animation",
    type:"stop-animation",
    handleEvent: function(ev) {
      Rylyz.Service.handleStopAnimation(ev);
    }
  }
  Rylyz.event.registerEventHandler(hStopAnimation);


  var hStartSound = {
    queue:"sound",
    type:"start-sound",
    handleEvent: function(ev) {
      Rylyz.Service.handleStartSound(ev);
    }
  }
  Rylyz.event.registerEventHandler(hStartSound);

  var hStopSound = {
    queue:"sound",
    type:"stop-sound",
    handleEvent: function(ev) {
      Rylyz.Service.handleStopSound(ev);
    }
  }
  Rylyz.event.registerEventHandler(hStopSound);

  var hServiceException = {
    queue:"exception",
    type:"service-exception",
    handleEvent: function(ev) {
      throw "handler not yet implemented: " + ev
      //Rylyz.Service.handle__(ev);
    }
  }
  Rylyz.event.registerEventHandler(hServiceException);


})(jQuery)