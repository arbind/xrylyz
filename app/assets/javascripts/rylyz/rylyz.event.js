/*
  //create a handler for an event that you know about:
  //if a handler should block other events until it completes, specifiy a duration:
  // type is the event type
  // queue is the target queue where events will be fired into
  var hWarn= {
    duration: 800,
    type: 'warn',
    queue: 'messages',
    handleEvent: function (ev) { console.warn(ev.message); }
  }

  // register the handler for an event type:
  Rylyz.event.registerEventHandler(hWarn);

  // create an event with a type and any other data:
  var eWarn  = {type:'warning', message:'this is a warning'};

  // fire the event into a default-queue:
  Rylyz.event.fire(eWarn);

  // or fire the event into a specific queue:
  Rylyz.event.fire(eWarn, 'animation');

  // or fire the event after some count down:
  Rylyz.event.fireAfterCountDown('turn-is-over', 5000, eWarn, 'default-queue');
  Rylyz.event.cancelCountDown('turn-is-over');

  // or fire the event with convenience queues:
  Rylyz.event.fireAnimation(eWarn);
*/

//+++ create event and handler base classes: each record time of creation, execution performance, and log history

window.Rylyz = window.Rylyz || {}

Rylyz.event = function() {
  var registry = {};
  var handlerReferenceTable = {};
  var queues = [];
  var queueIsRunning = {};
  var countdownTimers = {};
  return {
    clearQueues: function() { queues = {}; },
    getQueues: function() { return queues; },
    getQueue: function(queueName) { 
      queues[queueName] = queues[queueName] || [];
      return queues[queueName];
    },
    enableHandler: function(handlerName) {
      var h = handlerReferenceTable[handlerName];
      h.enabled = true;
      return h;
    },
    disableHandler: function(handlerName) {
      var h = handlerReferenceTable[handlerName];
      h.enabled = false;
      return h;
    },
    clearRegistry: function() { registry = {}; handlerReferenceTable = {}; },
    getregistry: function() { return registry; },

    registryKey: function (eh) {
      var q = eh.queue
      var type = eh.type;
      if (!type || !q) {
        var msg = "The event's type: and queue: must be specifed when for an event handler!";
        console.error(msg);
        console.error(eh);
        //throw msg;
      }
      return q + "." + type;
    },
    registerEventHandler: function(handler) { // register handler for specific event in target queue (key=queue.type)
      var key = this.registryKey(handler);
      if ('undefined' === typeof handler.enabled) handler.enabled = true;
      registry[key] = registry[key] || [];
      registry[key].push(handler);
      if (DBUG) dbugOut('handler['+key+']: REGISTERED');
      var refName = null;
      if (null!=handler.name) refName = handler.name;
      if (refName){
        if(!handlerReferenceTable[refName]) {
          handlerReferenceTable[refName] = handler;
          if (DBUG) dbugOut('handler['+key+']: REGISTERED as ' + refName);
        }
        else {
          var msg = "A handler named " +refName+ " is already registered!"
          console.error(msg);
          console.error(handler);
          throw msg;
        }
      } 
    },
    registerQueueHandler: function(handler) { // register handler for any event in target queue (key=queue)
      var q = handler.queue;
      if (!q) {
        var msg = "queue must be specifed when registering a queue handler!";
        console.error(msg);
        console.error(handler);
        throw msg;
      }
      if (handler.type) {
        var msg = "queue handler for [" +q+ "] should not specify an event type [" +handler.type+ "]!";
        console.error(msg);
        console.error(handler);
        throw msg;
      }
      registry[q] = registry[q] || [];
      if ('undefined' === typeof handler.enabled ) handler.enabled = true;
      registry[q].push(handler);
      if (DBUG) dbugOut('handler['+q+']: REGISTERED');
      var refName = null;
      if (null!=handler.name) refName = handler.name;
      if (refName){
        if(!handlerReferenceTable[refName]) {
          handlerReferenceTable[refName] = handler;
          if (DBUG) dbugOut('handler['+q+']: REGISTERED as ' + refName);
        }
        else {
          var msg = "A handler named " +refName+ " is already registered!"
          console.error(msg);
          console.error(handler);
          throw msg;
        }
      } 
    },
    unregisterHandler: function(handler) {
      var h;
      var key = this.registryKey(handler);
      var handlers = registry[key];
      //+++simpler way to remove an item from list? jquery?
      var newHandlers = [];
      if (handlers) {
        for (var idx = 0; idx < handlers.length; idx++) {
          h = handlers[idx];
          if (handler != h) newHandlers.push(h);
        }
        if (DBUG && newHandlers.length<handlers.length) dbugOut('unregistered handler: ' + key);
        registry[key] = newHandlers;
      }
    },
    cancelCountDown: function(countDownName, options) {
      options = options || {};
      var timer = countdownTimers[countDownName];
      if (!timer) {
        if (!options.silent) console.warn("There is no count down timer named '" + countDownName + "'");
        return;
      }
      clearTimeout(timer);
      timer = null;
      countdownTimers[countDownName] = null;
      if (DBUG) dbugOut('cancelled countdowntimer: ' + countDownName);
    },
    fireEventAfterCountDown: function(countDownName, waitForMilliseconds, ev ) {
      Rylyz.event.cancelCountDown(countDownName, {silent:true} );
      var timer = setTimeout(
          function(){
            var e = ev;
            Rylyz.event.fireEvent(e);
          },
          waitForMilliseconds);
      countdownTimers[countDownName] = timer;
      if (DBUG) dbugOut('scheduled countdowntimer: ' + countDownName + "to fire event: " +ev.type+ " in " +waitForMilliseconds+" ms");
    },
    //+++rename to fireThisDOMEvent, since it converts dom event to rylyz event and  fires immediately:
    fireOnDOMEvent: function(eventName, domEvent, eventBase) {
      var srcElement = srcElementForDOMEvent(domEvent);
      if (!srcElement) return;
      var fireOn = "fire-on" + eventName.capitalize(); //name of the data attribute
      var eventDescription = srcElement.getAttribute(fireOn);
      //+++ modify description from
      var ev;
      var msg;
      try {
        ev = null;
        //+++ modify (to simplify dom attribute interface) to be:
        //toEval = "ev = {" + eventDescription + "}";
        toEval = "ev = " + eventDescription;
        eval(toEval);
      }
      catch (err) {
        msg = "Invalid syntax for " +eventName+ ":\n";
        msg += fireOn +  ' = "' + eventDescription + '"\n';
        msg += "Be sure to quote the values and use commas to separate parameters!\n\n";
        console.error(msg);
        return;
      }
      if ('object' != typeof ev) {
        msg = (typeof ev) + " is an invalid type for " +eventName+ ":\n";
        msg += fireOn +  ' = "' + eventDescription + '"\n';
        msg += "The event should be evaluate to an object description!\n\n";
        console.error(msg);
        return;
      }
      if (!ev.type){
        msg = " type needs to be specified for " +eventName+ " event :\n";
        msg += fireOn +  ' = "' + eventDescription + '"\n';
        msg += "include type:'event-type'!\n\n";
        console.error(msg);
        return;
      }
      jQuery.extend(ev, eventBase);
      this.fireEvent(ev);
    },
    fireEvent: function(ev) {
      var eventList = ev;
      if (!$.isArray(ev)) eventList = [ev];  // create a list of events

      $.each(eventList, function(idx, e){ // fire each one
        Rylyz.event.enqueue(e);
      });
    },
    enqueue: function(ev) {
      var key = this.registryKey(ev);
      var q = ev.queue;
      var handlers =[]; // get the eventhanders that handle specifc events for this target queue
      var eventHandlers = registry[key] || []; // get the eventhanders that handle specifc events for this target queue
      var queueHandlers = registry[q] || []; // get the queueHanders that handle specifc events for this target queue
      $.merge(handlers, eventHandlers);  // execute the event handlers first
      $.merge(handlers, queueHandlers);  // execute the queue handlers next
      var numDisabledHandlers = 0;
      if (0 < handlers.length) {
        if (DBUG) dbugOut('event[' +key+ ']: FIRED'); 
        var h
        for (var idx = 0; idx < handlers.length; idx++) {
          h = handlers[idx];
          if (h.enabled) {
            Rylyz.event.getQueue(q).push( {event:ev, handler:h} )
          }
          else {
            numDisabledHandlers++;
          }
        }
        if (DBUG) dbugOut('event[' +key+ ']: ' + handlers.length+ ' handlers found (' +queueHandlers.length+ ' queue handlers) (' +numDisabledHandlers+ ' disabled)'); 
        Rylyz.event.startQueue(q);
      }
      else {
        if (DBUG) dbugOut('event[' +key+ ']: DID NOT FIRE - no handers are registered'); 
      }
    },
    startQueue: function(queueName) {
      //+++ This can be re-written to be thread-safe:
      //    - startQueue is called asynchronously from both enqueue(...) and from queueHandlerCompleted(...)
      //    - the var queueIsRunning is modified in both startQueue(...) and in queueHandlerCompleted(...)
      if (queueIsRunning[queueName]) {
        if (DBUG) dbugOut('queue[' +queueName+ '] already started!'); 
        return;
      }
      queueIsRunning[queueName] = true;
      if (!Rylyz.event.getQueue(queueName).length) {
        queueIsRunning[queueName] = false;
        if (DBUG) dbugOut('queue[' +queueName+ ']: STOPPED - no more events to handle'); 
        return;
      }
      if (DBUG) dbugOut('queue[' +queueName+ ']: STARTED'); 
      eh = Rylyz.event.getQueue(queueName).shift();
      ev = eh.event;
      h = eh.handler;
      if (DBUG) dbugOut("Queue[" +queueName+ "] CALLING HANDLER for event[" +ev.type+ "]" );
      try {
        h.handleEvent(ev);
      }
      catch (err) {
        console.error("Uncaught Exception when handling event:")
        console.error("queue: " + h.queue);
        console.error("type: " + h.type );
        console.error("err: " + err);
      }
      if (h.duration) {
        if (DBUG) dbugOut("Queue[" +queueName+ "] WAITING " +h.duration+ "ms for handler to finish." );
        setTimeout(
          function(){ 
            var q = queueName;
            Rylyz.event.queueHandlerCompleted(q);
          }, 
          h.duration)
      }
      else {
        Rylyz.event.queueHandlerCompleted(queueName);
      }
    },
    queueHandlerCompleted: function(queueName) {
      queueIsRunning[queueName] = false;
      if (DBUG) dbugOut('queue[' +queueName+ ']: STOPPED - handler completed execution.'); 
      Rylyz.event.startQueue(queueName);
    }
  }
}();

// +++Built In Handlers

// +++Handler API
// +++ build out a few generic handlers that can be used

/* Usage:
 
var eAlert = {type:'alert', message:'this is an alert'};
var eWarn  = {type:'warning', message:'this is a warning'};
var eError = {type:'error', message:'this is an error'};
var eInfo  = {type:'info', message:'this is an info'};
var eLog   = {type:'log', message:'this is a log'};

var hInfo = {
    duration: 3000,
    handle: function (ev) { console.info(ev.message); }
  }
var hAlert = {
    duration: 0,
    handle: function (ev) { alert(ev.message); }
  }
var hError = {
    duration: 2000,
    handle: function (ev) { console.error(ev.message); }
  }
var hWarn= {
    duration: 800,
    handle: function (ev) { console.warn(ev.message); }
  }
var hLog = {
    duration: 1000,
    handle: function (ev) { console.log(ev.message); }
}
Rylyz.event.clearRegistry;
Rylyz.event.register('info', hInfo);
Rylyz.event.register('alert', hAlert);
Rylyz.event.register('error', hError);
Rylyz.event.register('warning', hWarn);
Rylyz.event.register('log', hLog);

Rylyz.event.fire(eWarn);
Rylyz.event.fire(eInfo);
Rylyz.event.fire(eAlert);
Rylyz.event.fire(eLog);
Rylyz.event.fire(eError);
*/

/* Example:

<body>

<div id="box">
</div>

<script type="text/javascript">
var eMoveRight = {type:'move', property: 'left', value: '200px'};
var eMoveDown = {type:'move', property: 'top', value: '220px'};
var eMoveUp = {type:'moveUp', property: 'top', value: '20px'};
var hMove = {
    duration: 500,
    handle: function(ev) {
      style = {};
      style[ev.property] =  ev.value;
      $('#box').css(style);
      //$('#box').animate(style, '3000 ms', 'linear');
    }
}

var hMoveUp = {
    duration: 800,
    handle: function(ev) {
      style = {};
      style[ev.property] =  ev.value;
      $('#box').css(style);
    }
}

Rylyz.event.register('move', hMove);
Rylyz.event.register('moveUp', hMoveUp);

Rylyz.event.fireAnimation(eMoveRight);
Rylyz.event.fireAnimation(eMoveUp);
Rylyz.event.fire(eMoveDown, 'animation');
</script>
</body>

*/
