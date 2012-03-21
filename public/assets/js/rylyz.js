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


  window.Rylyz.sendForm = function(domElement) {
    jQuery(domElement).closest('form').submit();
  }
  
  window.Rylyz.materializeUID = function (pattern) {
    pattern = pattern ||  'rylyz-xxxxxxxx-xxxx-yxxx-yxxx-xxxxxxxxxxxx';
    var unique = pattern.replace(/[xy]/g, function(c) {
        var r = Math.random()*16|0, v = c == 'x' ? r : (r&0x3|0x8);
        return v.toString(16);
      });
    return unique;
  };

  window.Rylyz.showApp = function(appName, appSpotSelector) {
    var spotSelector = appSpotSelector || "#app-spot"
    var oldApp = null, newApp = null;
    var newApp = Rylyz.lookupApp(appName);
    if (!newApp) throw "No app named '" +appName+ "' was found. Can not show it!"

    if (newApp==Rylyz.activeApp) return; //already loaded
    if (Rylyz.activeApp) {
      //activeApp.minimize();
    }
    newApp.renderInto($(spotSelector));
    Rylyz.activeApp = newApp;
  };

  window.Rylyz.currentScreen = function() {
    if (!Rylyz.activeApp) return null;
    return Rylyz.activeApp.currentScreen();
  };

  window.Rylyz.appReferenceTable = new Rylyz.ReferenceTable();
  //window.Rylyz.refTables = { models:{}, collections:{}, screens:{}, currentScreen:null } //remove this
  //window.Rylyz.refTable = { objectData:{},  objectDisplays:{}, collectionData:{}, collectionDisplays:{}, appData:{}, appDisplays:{}, screenData:{}, screenDisplays:{}}



  window.Rylyz.lookupProperty = function(info, propertyName) {
    console.log(info);
    if(!info) throw "can not look up "+propertyName+": info given is null!";

    var value=null;
    if ('string' == typeof(info) ) value=info;
    else if (info.hasOwnProperty(propertyName)) value = info[propertyName];
    else if ($.isArray(info)) throw "Can not lookup "+propertyName+" when given an array: \n" + toString(info);
    else if (info.hasOwnProperty('context')){
      var context = info['context'];
      if (context.hasOwnProperty(propertyName)) value = context[propertyName];
    }
    return value;
  }

  Rylyz.lookupApp = function(info) {
    var appName = Rylyz.lookupProperty(info, 'appName');
    if (!appName) throw "Did not find appName for info: " + toString(info);
    return Rylyz.appReferenceTable.lookupApp(appName);
  }

  window.Rylyz.lookupScreen= function(info) {
    var app = Rylyz.lookupApp(info);
    if(!app){
      console.log ('info=' + toString(info));
      console.log ('context=' + toString(info['context']));
      console.log ('appname=' + toString(info['context']['appName']));
      throw "Can not look up Screen: No app found for info: " + toString(info);
    } 
    var screenName = Rylyz.lookupProperty(info, 'screenName');
    if (!screenName) throw "Did not find screenName for info: " + toString(info);
    return app.lookupScreen(screenName);
  }

  window.Rylyz.lookupDisplay= function(info) {
    var screen= Rylyz.lookupScreen(info);
    if(!screen) throw "Can not look up Display: No screen found for info: " + toString(info);

    var displayName =  Rylyz.lookupProperty(info, 'displayName');
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

  Rylyz.loadAppDisplays  = function (){  //load (intantiate) all appDisplays
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