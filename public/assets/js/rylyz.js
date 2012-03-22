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
  Rylyz.Tag = "rylyz";

  Rylyz.appReferenceTable = new Rylyz.ReferenceTable();
  Rylyz.appStack = [];

  Rylyz.currentApp = function() { return Rylyz.appStack.peek(); };
  Rylyz.pushApp = function(app){
    var a = app;
    if ('string' == typeof app) a = Rylyz.lookupApp(app);
    if ('app'!=a.dataType) throw "Only an app can only pushed onto the appStack!";
    Rylyz.appStack.push(a);
  };
  Rylyz.popApp = function() {
    if (Rylyz.appStack.length) return this.appStack.pop();
    return null;
  };

  Rylyz.sendForm = function(domElement) {
    jQuery(domElement).closest('form').submit();
  }

  Rylyz.materializeUID = function (pattern) {
    pattern = pattern ||  'rylyz-xxxxxxxx-xxxx-yxxx-yxxx-xxxxxxxxxxxx';
    var unique = pattern.replace(/[xy]/g, function(c) {
        var r = Math.random()*16|0, v = c == 'x' ? r : (r&0x3|0x8);
        return v.toString(16);
      });
    return unique;
  };

  Rylyz.showApp = function(appName, appSpotSelector) {
    var spotSelector = appSpotSelector || "#app-spot"
    var oldApp = null, newApp = null;
    var newApp = Rylyz.lookupApp(appName);
    if (!newApp) throw "No app named '" +appName+ "' was found. Can not show it!"

    if (newApp==Rylyz.currentApp()) return; //already loaded
    oldApp = Rylyz.popApp();
    if (oldApp) {
      oldApp.minimize()
    }
    newApp.triggerShowStart({});
    newApp.renderInto($(spotSelector));
    Rylyz.pushApp(newApp);
    newApp.triggerShowEnd();
  };

  Rylyz.currentScreen = function() {
    if (!Rylyz.currentApp()) return null;
    return Rylyz.currentApp().currentScreen();
  };

  //window.Rylyz.refTables = { models:{}, collections:{}, screens:{}, currentScreen:null } //remove this
  //window.Rylyz.refTable = { objectData:{},  objectDisplays:{}, collectionData:{}, collectionDisplays:{}, appData:{}, appDisplays:{}, screenData:{}, screenDisplays:{}}



  Rylyz.lookupProperty = function(propertyName, info) {
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
    var appName = Rylyz.lookupProperty('appName', info);
    if (!appName) throw "Did not find appName for info: " + toString(info);
    return Rylyz.appReferenceTable.lookupApp(appName);
  }

  Rylyz.lookupScreen= function(info) {
    var app = Rylyz.lookupApp(info);
    if(!app){
      console.log ('info=' + toString(info));
      console.log ('context=' + toString(info['context']));
      console.log ('appname=' + toString(info['context']['appName']));
      throw "Can not look up Screen: No app found for info: " + toString(info);
    } 
    var screenName = Rylyz.lookupProperty('screenName', info);
    if (!screenName) throw "Did not find screenName for info: " + toString(info);
    return app.lookupScreen(screenName);
  }

  Rylyz.lookupDisplay= function(info) {
    var screen= Rylyz.lookupScreen(info);
    if(!screen) throw "Can not look up Display: No screen found for info: " + toString(info);

    var displayName =  Rylyz.lookupProperty('displayName', info);
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

  Rylyz.loadAppDisplays  = function (appName){  //load (intantiate) all appDisplays
    var appDisplay = null;
    var appTemplates = $(Rylyz.Tag + "[name="+appName+"] > app[name="+appName+"]");

    $.each(appTemplates, function(idx, template) {
      appTemplateName = template.getAttribute('name');
      //+++TODO check see if app is already loaded, else create new AppDisplay
      appDisplay = new Rylyz.AppDisplay({name:appTemplateName});
    })
  };

  Rylyz.showScreenWithFadeIn = function(screen, newSettings) { //+++ putinto app
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

  Rylyz.showScreen = function(screen, newSettings) {
    if (screen) {
      var app = screen.app;
      app.showScreen(screen.name, newSettings);
    }
    else {
      if (DBUG) dbugOut("Could not navigate to screen!");
    }
  };

})(jQuery)