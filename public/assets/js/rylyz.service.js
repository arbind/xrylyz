(function($) {

	window.Rylyz = window.Rylyz || {};
	
	window.Rylyz.Service = {};
	window.Rylyz.Service = {

		//Exception reporting
		reportServerSideException: function(channel, data) {
      var exception = data["exception"];
      console.error("Server Side Exception received on channel: "+channel+" !\n Message: " + exception);
    },
    
		//Data Events
		fireDataEvent4Load: function(event) {
			Rylyz.Wyjyt.triggerWIDEvent("load-data", event)
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
			data = event['data'];
			//+++check data
			display.collection.add(data);
		},
		handleDataEvent4RemoveCollectionItem: function(event) {
		},

		fireHIEvent: function(event) {
      //+++ TODO make this independent of Pusher!
      Rylyz.Wyjyt.triggerWIDEvent("hi", event);
		},
		fireHIEvent4DataInput: function(event) {
      var ev = {
      	queue: event.queue,
      	type: event.type,
      	context: event.context,
      	settings: event.settings,
      	formData: event.formData
      }
      //+++ TODO make this independent of Pusher!
      Rylyz.Wyjyt.triggerWIDEvent("data-input", ev);

		},
		fireHIEvent4Navigation: function(event) {
      if (!ev.nextScreen) throw "Navigation event must specify nextScreen! " + ev;
      var nextScreenRoute = {
      	appName: Rylyz.lookupProperty('appName', ev),
      	screenName: ev.nextScreen
      }
      var screen = Rylyz.lookupScreen(nextScreenRoute);
      if (!screen) throw "A screen named '" +ev.nextScreen+ "'' can not be found to handle this navigation event!";
      var select = event.select || null;
      if (!select && event.settings) select = event.settings.select;
      var newSettings = {
      	select: select
      };
      Rylyz.showScreenWithFadeIn(screen, newSettings);
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
    	console.log(ev);
    	Rylyz.Service.fireHIEvent(ev);
    }
  }
  Rylyz.event.registerQueueHandler(hFireHIEvent);


  var hAddItem = {
		queue:"app-server",
		type:"add-item",
    handleEvent: function(ev) {
    	console.log(ev);
    	Rylyz.Service.handleDataEvent4AddCollectionItem(ev);
    }
  }
  Rylyz.event.registerEventHandler(hAddItem);

  var hLoadData = {
		queue:"app-server",
		type:"load-data",
    handleEvent: function(ev) {
    	console.log(ev);
    	Rylyz.Service.handleDataEvent4LoadData(ev);
    }
  }
  Rylyz.event.registerEventHandler(hLoadData);

  var hScreenNavigation = {
    queue: "screen",
    type: "navigation",
    handleEvent: function(ev) { Rylyz.Service.fireHIEvent4Navigation(ev); }
  }
  Rylyz.event.registerEventHandler(hScreenNavigation);

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

})(jQuery)