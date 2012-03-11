// 1. add name/user to the context
// 2. add create new game service
// 3. add move event handler
// 4. refactor into App Class
// 5. Integrate into widget

(function($) {
  _.templateSettings = { 
    // [! var x; !] execute code
    // [[ varname ]] prints value
    evaluate    : /\[!([\s\S]+?)!\]/g,  
    interpolate : /\[\[([\s\S]+?)\]\]/g  
  };

  window.Rylyz = window.Rylyz || {}
  window.Rylyz.Tag = "rylyz";

  window.Rylyz.activeApp = null;


  window.Rylyz.UID = function (pattern) {
    pattern = pattern || window.location.hostname + '-xxxxxxxx-xxxx-yxxx-yxxx-xxxxxxxxxxxx';
    var unique = pattern.replace(/[xy]/g, function(c) {
        var r = Math.random()*16|0, v = c == 'x' ? r : (r&0x3|0x8);
        return v.toString(16);
      });
    return unique;
  };

  window.Rylyz.showApp = function(appName) {
    var oldApp = null, newApp = null;
    var newApp = Rylyz.lookupApp(appName);
    if (!newApp) throw "No app named '" +appName+ "' was found. Can not show it!"

    if (newApp==Rylyz.activeApp) return; //already loaded
    if (Rylyz.activeApp) {
      //activeApp.minimize();
    }
    newApp.renderInto($('#app-spot'));
    Rylyz.activeApp = newApp;
  };

  window.Rylyz.currentScreen = function() {
    if (!Rylyz.activeApp) return null;
    return Rylyz.activeApp.currentScreen();
  };

  window.Rylyz.appReferenceTable = new Rylyz.ReferenceTable();
  //window.Rylyz.refTables = { models:{}, collections:{}, screens:{}, currentScreen:null } //remove this
  //window.Rylyz.refTable = { objectData:{},  objectDisplays:{}, collectionData:{}, collectionDisplays:{}, appData:{}, appDisplays:{}, screenData:{}, screenDisplays:{}}

  Rylyz.lookupApp = function(info) {
    if(!info) throw "can not look up Display: info given is null!";
    var name;
    if ('string' == typeof(info) ) name=info;
    else {
      if ($.isArray(info)) throw "Can not lookup name of app when given an array: \n" + toString(info);
      if (!info.hasOwnProperty('appName'))  throw "Can not lookup app when no appName is specified: \n" + toString(info);
      name = info.appName;
    }
    return Rylyz.appReferenceTable.lookupApp(name);
  }

  window.Rylyz.lookupScreen= function(info) {
    if(!info) throw "can not look up Display: info given is null!";

    var app = Rylyz.lookupApp(info);
    if(!app) throw "Can not look up Screen: No app found for info: " + toString(info);

    var screenName = info.screenName
    return app.lookupScreen(screenName);
  }

  window.Rylyz.lookupDisplay= function(info) {
    if(!info) throw "can not look up Display: info is null! "

    var screen= Rylyz.lookupScreen(info);
    if(!screen) throw "Can not look up Display: No screen found for info: " + toString(info);

    var displayName =  info.displayName
    if (undefined == displayName) return screen;
    return screen.displayTable[displayName];
  }

  /*
  window.Rylyz.currentApp = null;

  window.Rylyz.currentScreen = function(screen) {
    if(screen) Rylyz.currentApp.currentScreen = screen; 
    return Rylyz.currentApp.currentScreen;
    //if(screen) this.referenceTables.currentScreen = screen; 
    //return window.Rylyz.refTables.currentScreen;
  };
  */

  Rylyz.loadAppDisplays  = function (appSpotSelector){  //load (intantiate) all appDisplays
    var spotSelector = appSpotSelector || "#app-spot"
    var appName = null;
    var appDisplay = null;
    var appTemplates = $(Rylyz.Tag + " > app[name]");

    $.each(appTemplates, function(idx, template) {
      appName = template.getAttribute('name');
      appDisplay = new Rylyz.AppDisplay({name:appName});
    })
  };

  window.Rylyz.showScreenWithFadeIn = function(screen, newSettings) { //+++ putinto app
    if (!screen) {
      throw "showScreenWithFadeIn: No Screen specified!"
      return;
    }
    var oldScreen = Rylyz.currentScreen();
    if (oldScreen) {
      $(oldScreen.el).animate({opacity:0}, 300, function(){
        var old = oldScreen;
        var next = screen;
        if (old) old.unload();
        $(next.el).css("opacity",0.1);
        Rylyz.showScreen(next, newSettings);
        $(next.el).animate({opacity:1.0}, 300);
      });
    }
    else {
      $(screen.el).css("opacity",0.1);
      Rylyz.showScreen(screen, newSettings);
      $(screen.el).animate({opacity:1.0}, 500);
    }
  };

  window.Rylyz.showScreen = function(screen, newSettings) {
    if (screen) {
      var app = screen.app;
      app.showScreen(screen.name, newSettings);
    }
    else {
      if (DBUG) dbugOut("Could not navigate to screen!");
    }
  };

})(jQuery)