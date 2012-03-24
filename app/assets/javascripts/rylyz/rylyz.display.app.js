window.Rylyz.AppData = Rylyz.ObjectData.extend({});
window.Rylyz.AppDisplay = Rylyz.ScreenDisplay.extend({
  dataType: 'app',
  screenStack:null,
  startScreen: null,
  triggerDataLoadStart: function(settings) {
    var ev = {
      context: { appName:this.name }
    }
    Rylyz.Service.fireDataEvent4Load(ev);
  },
  getTemplateSelector: function() {
    if (!this.name) { throw "No app template found for <app name='" +this.name+ "'>\n"; }
    return "rylyz > app[name='"+ this.name + "']";
  },
  initializeParent: function() { this.parent = null; },
  initializeData: function() {
    this.model = this.model || this.options.model || this.appData || this.options.appData || new Rylyz.AppData(this.dataDefaults);
  },

  initializeAppDisplay: function() {
    this.screenStack = [];
    Rylyz.appReferenceTable.storeData(this.name, this.model);
    Rylyz.appReferenceTable.storeAppDisplay(this.name, this);
  },
  initializeTemplateSettings: function(template) {
    this.startScreen = template.getAttribute("start-screen");
  },
  initializeAppContext: function() {
    this.context.store("appName", this.name);
  },
  currentScreen: function() { return this.screenStack.peek(); },
  pushScreen: function(screen){
    var s = screen;
    if ('string' == typeof screen) s = this.lookupScreen(screen);
    if ('screen'!=s.dataType) throw "An app can only push a display that is a screen!";
    this.screenStack.push(s);
  },
  popScreen: function() {
    if (this.screenStack.length) return this.screenStack.pop();
  },
  lookupScreen: function(screen) {
    return this.lookupSubDisplay(screen);
  },  
  allScreens: function(idx) { return this.allDisplays(); },
  loadSubDisplays: function() { // app can only have screen subDisplays (no ObjectDisplays or CollectionDisplays)
    if (this.subDisplaysAreLoaded) return;

    var screenName = null;
    var screenDisplay = null;
    var screenSpots = this.$("screen[name]");

    var thisApp = this;
    $.each(screenSpots, function(idx, screenSpot) {
      screenName = screenSpot.getAttribute('name');
      screenDisplay = new Rylyz.ScreenDisplay({name:screenName, app:thisApp});
      thisApp.addSubDisplay(screenDisplay);
    })
    this.subDisplaysAreLoaded = true;
  },
  renderSubDisplays: function() {
    if (!this.subDisplaysAreLoaded) this.loadSubDisplays();
    var screenName = this.startScreen;
    console.info("--1" + this.name + ": " + screenName + ": ");

    var screen = this.currentScreen();
    if (screen) screenName = screen.name;

    console.info("--1" + this.name + ": " + screenName + ": ");

    if (!screenName) throw "This app has no current screen, and no start screen is defined!"
    console.info("--1" + this.name + ": " + screenName + ": ");
    this.showScreen(screenName);
    console.info("--2");
  },
  showScreen: function(screenName, newSettings) {
    var oldScreen = this.popScreen();
    if (oldScreen) oldScreen.minimize();

    var screen = this.lookupScreen(screenName);
    if (!screen) 
      throw "Can not show screen named '" +screenName+ "' because it is not one of the screens for this app: '" +this.name+ "'!"
    screen.triggerShowStart(newSettings);
    var spotSelector = null;
    spotSelector = screen.dataType+"[name='" +screenName+ "']";
    screen.renderInto(this.$(spotSelector));
    this.pushScreen(screenName);
    screen.triggerShowEnd();
  },
  flash: function(message) {
    alert("Flash: " + message);
  },
});