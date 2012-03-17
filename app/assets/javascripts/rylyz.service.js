(function($) {

	window.Rylyz = window.Rylyz || {};
	
	window.Rylyz.Service = {};
	window.Rylyz.Service = {
	
		//Data Events
		fireDataEvent4LoadApp: function(event) {
      var url = Rylyz.urlAPI + "/fire/data_event/load_app.json";
      if (DBUG) dbugOut("sending event to server:" + url);
      $.get(url, event, function(response){console.log(response)});
		},

		fireDataEvent4LoadScreen: function(event) {
      var url = Rylyz.urlAPI + "/fire/data_event/load_screen.json";
      if (DBUG) dbugOut("sending event to server:" + url);
      $.get(url, event, function(response){console.log(response)});
		},

		handleDataEvent4LoadApp: function(event) {
			var app = Rylyz.lookupApp(event);
			if (app) app.model.set(event.data);
		},

		handleDataEvent4LoadScreen: function(events) {
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
			 	 }
			});

		},

		fireDataEvent4lookup: function(event) {
      var url = Rylyz.urlAPI + "/fire/data_event/lookup.json";
      if (DBUG) dbugOut("sending event to server:" + url);
      $.get(url, event, function(response){console.log(response)});
		},
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
		 	 	/*
	      //var dataCollection = Rylyz.refTables.collections[event.name] || null;
	      var modelData = Rylyz.currentApp.currentScreen.referenceTable.lookupData(event.name) || null;
				if ($.isArray(event.data)){
  		    modelData.reset(event.data);
  	  	}
  	  	else {
	      	//var dataObject = Rylyz.refTables.models[event.name];
		    	modelData.set(event.data);
		 	 	}
		 	 	*/
		 	})
		},
		handleDataEvent4Update: function(event) {

		},
		handleDataEvent4AddItem: function(event) {
			display = Rylyz.lookupDisplay(event);
			//+++ check display
			data = event['data'];
			//+++check data
			display.collection.add(data);
		},

		handleDataEvent4Remove: function(event) {

		},


		/*
		ev = event;
		+++ if (currentApp().currentScreen().fireHiEvent4xxx) {
			ev = currentApp().currentScreen().fireHiEvent4xxx(ev) { //screen can override and morph the event if needed
			if (!ev) return; //fire method has been overriden by the screen and returned false.
		}
		fireHiEvent(ev), fireDataEvent(ev), etc..
	  */
	  //specify serverPlugin: URLbased, Pusher, other?
	  /*
			ServerPlugin:
			  fireHIEvent(event)
			  fireDataEvent(event)
			  fireTimerEvent(event)
	  */

		//User/Client events fired to Service
		fireTimerEvent: function(event) {
      var url = Rylyz.urlAPI + "/fire/hi_event/timer.json";
      if (DBUG) dbugOut("sending event to server:" + url);
      $.get(url, event, function(response){console.log(response)});
		},
		fireHIEvent: function(event) {
      var url = Rylyz.urlAPI + "/"+ev.type+"/"+ev.column+". json";
      if (DBUG) dbugOut("sending event to server:" + url);
      $.get(url, function(response){console.log(response)});
		},
		fireHIEvent4DataEntry: function(event) {
      var url = Rylyz.urlAPI + "/fire/hi_event/data_entry.json";
      if (DBUG) dbugOut("sending event to server:" + url);
      var ev = {
      	queue: event.queue,
      	type: event.type,
      	context: event.context,
      	formData: event.formData
      }
      //+++ TODO make this independent of Pusher!
      Rylyz.Pusher.triggerUIDEvent("data-input", ev);

      //$.get(url, ev, function(response){console.log(response)});			
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
		fireHIEvent4Navigation: function(event) {
      if (!ev.nextScreen) throw "Navigation event must specify nextScreen! " + ev;
      var url = Rylyz.urlAPI + "/fire/hi_event/navigation.json";
      if (DBUG) dbugOut("sending event to server:" + url);
      //$.get(url, event, function(response){console.log(response)});
      var nextScreenRoute = {
      	appName: ev.appName,
      	screenName: ev.nextScreen
      }
      var screen = Rylyz.lookupScreen(nextScreenRoute);
      if (!screen) throw "A screen named '" +ev.nextScreen+ "'' can not be found to handle this navigation event!";
      var newSettings = {
      	select: event.select || null
      };
      Rylyz.showScreenWithFadeIn(screen, newSettings);
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
	};




  var hAddItem = {
		queue:"app-server",
		type:"add-item",
    handleEvent: function(ev) {
    	console.log(ev)
    	Rylyz.Service.handleDataEvent4AddItem(ev);
    }
  }
  Rylyz.event.registerQueueHandler(hAddItem);

  var hScreenNavigation = {
    queue: "screen",
    type: "navigation",
    handleEvent: function(ev) { Rylyz.Service.fireHIEvent4Navigation(ev); }
  }
  Rylyz.event.registerQueueHandler(hScreenNavigation);

  var hLoadApp = {
    queue: "screen",
    type: "navigation",
    handleEvent: function(ev) { Rylyz.Service.fireHIEvent4Navigation(ev); }
  }
  Rylyz.event.registerQueueHandler(hLoadApp);

  var hFormSubmit = {
  	queue: "form",
  	type: "submit",
  	handleEvent: function(ev) { 
      f = srcElementForDOMEvent(ev.domEvent);
      var formData = extractFormData(f);
      ev.formData = formData;
      alert('form submitted and handled in handler: ' + formData.toString());

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
      Rylyz.Service.fireHIEvent4DataEntry(ev);
      //+++fire event to send formData to server
  	}
  }
  Rylyz.event.registerQueueHandler(hFormSubmit);

})(jQuery)