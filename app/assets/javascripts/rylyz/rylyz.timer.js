window.Rylyz = window.Rylyz || {};
Rylyz.js = Rylyz.js || {};


Rylyz.timer = function() {
  var registry = {};
  return {

    // +++ todo: for repeat=true - add ability to specify the max number of timer ticks
    register: function(timerName, onTick, milliseconds, repeat, onStart, onStop) {
      console.log("registering timer: " + timerName);
      this.unregister(timerName)
      if (undefined == milliseconds) milliseconds = -1;
      if (undefined == repeat) repeat = false;
      if (undefined == onStart) onStart = null;
      if (undefined== onStop) onStop = null;

      if (!timerName) {
          var msg = "a timerName is required to register a timer"
          console.error(msg);
          throw msg;        
      }
      var isFunction  = !!(onTick && onTick.constructor && onTick.call && onTick.apply)
      if (!isFunction) {
          var msg = "An onTick function handler must be given "
          console.error(msg);
          throw msg;        
      }

      if (onStart) {
        isFunction  = !!(onStart && onStart.constructor && onStart.call && onStart.apply)
        if (!isFunction) {
            var msg = "An onStart handler nust be a function"
            console.error(msg);
            onStart = null;
        }
      }
      if (onStop) {
        isFunction  = !!(onStop && onStop.constructor && onStop.call && onStop.apply)
        if (!isFunction) {
            var msg = "An onStop handler nust be a function"
            console.error(msg);
            onStop = null;
        }
      }

      var onFireStart = null;
      var onFireTick = null;
      var onFireStop = null;

      if (onStart) {
        onFireStart= function() {
          vars = Rylyz.js; // a space for handlers to share variables
          onStart();
        }
      }
      if (onStop) {
        onFireStop= function() {
          vars = Rylyz.js; // a space for handlers to share variables
          onStop();
        }
      }

      onFireTick= function() {
        //+++ add counter for track number of ticks
        vars = Rylyz.js; // a space for handlers to share variables
        onTick();
        if (!descriptor.repeat && onStop) Rylyz.timer.stop(timerName)
        //+++ if max number of ticks (repeat=true), call stop timer
      }

      descriptor = {
        timer: null,
        repeat: repeat,
        milliseconds: milliseconds,
        onFireStart: onFireStart,
        onFireTick: onFireTick,
        onFireStop: onFireStop
      }
      registry[timerName] = descriptor
    },

    unregister: function(timerName) {
      descriptor = registry[timerName]
      if (!descriptor) return;
      stop(timerName)
      registry[timerName] = null;
    },

    start: function(timerName, milliseconds, repeat) {
      descriptor = registry[timerName]

      if (!descriptor) {
        var msg = "Timer named " +timerName+ " is not registered"
        console.error(msg);
        throw msg;
      }
      if (descriptor.timer) return; // timer already started.

      if (undefined == milliseconds) milliseconds = descriptor.milliseconds
      descriptor.milliseconds = milliseconds

      if (undefined == repeat) repeat = descriptor.repeat
      descriptor.repeat = repeat

      if (0>milliseconds) {
        var msg = "Timer set to go off in the past: " +milliseconds+ " milliseconds"
        console.log(msg);
        return;
      }
      if (descriptor.onFireStart)  descriptor.onFireStart();
      if (descriptor.repeat) {
        descriptor.timer = setInterval(descriptor.onFireTick, descriptor.milliseconds);
      }
      else {
        descriptor.timer = setTimeout(descriptor.onFireTick, descriptor.milliseconds);
      }
    },
    stop: function(timerName) { // stop timer and invoke onStop handler
      this.end(timerName, true)
    },
    cancel: function(timerName) { // stop the timer; do not invoke any more handlers
      this.end(timerName, false)
    },
    end: function(timerName, invokeOnStop) { // simply stop the timer and do not invoke any more handlers
      descriptor = registry[timerName]
      if (!descriptor) return;
      if (descriptor.timer){
        if (descriptor.repeat) clearInterval(descriptor.timer)        
        else clearTimeout(descriptor.timer);
        descriptor.timer = null
        if (invokeOnStop && descriptor.onFireStop) descriptor.onFireStop();
      }
    },
  }
}();

/*

vars becomes available to each handler as a shared space where each handler can define, access and modify their own variables:

Usage:
var onstart = function() {
  console.log('starting..');
  vars.ticks = vars.ticks || 0;
  vars.allTicks = vars.allTicks || 0;
  console.log('tick #' + vars.ticks);
  console.log('all ticks #' + vars.allTicks);
};
var ontick = function() {
  console.log('..ticking');
  vars.ticks++
  vars.allTicks++
  console.log('tick #' + vars.ticks);
  console.log('all ticks #' + vars.allTicks);
};
var onstop = function() {
  console.log('stoping!!');
  vars.ticks = 0;
  console.log('tick #' + vars.ticks);
  console.log('all ticks #' + vars.allTicks);
};

Rylyz.timer.register('t1', ontick, 2000, true, onstart, onstop);

Rylyz.timer.start('t1')
Rylyz.timer.stop('t1')
Rylyz.timer.start('t1', 200, true)
Rylyz.timer.stop('t1')
Rylyz.timer.start('t1', 1000, false)

*/