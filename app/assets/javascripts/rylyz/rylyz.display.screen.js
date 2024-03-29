window.Rylyz.ScreenData = Rylyz.ObjectData.extend({});
window.Rylyz.ScreenDisplay = Rylyz.ObjectDisplay.extend({
  dataType: 'screen',
  displayTable: null, //holds a flat list of all subdisplays in this screen - even if they are sub displays of another subdisplay

  triggerShowStart: function(newSettings) {
    this.select = null;
    if (newSettings) $.extend(this.settings, newSettings);
  },
  triggerShowEnd: function() { },
  triggerDataLoadStart: function(newSettings) {
    thisApp = this.app;
    thisScreen = this;
    var ev = {
      context: {
        appName:thisApp.name,
        screenName:thisScreen.name,
      },
      settings: newSettings
    }
    Rylyz.Service.fireDataEvent4Load(ev);
  },
  getTemplateSelector: function() {
    if (!this.name) { throw "No screen template found for <screen name='" +this.name+ "'> \n"; }
    var appName = this.app.name;
    var selector = "rylyz[name='" +appName+ "']  > screen[name='"+ this.name + "']";
    return selector
  },

  initializeData: function() {
    this.model = this.model || this.options.model || this.screenData || this.options.screenData || new Rylyz.ScreenData(this.dataDefaults);
  },
  initializeParent: function() {this.parent = this.app; },
  initializeScreenDisplay: function() {
    this.displayTable = [];
    if (!this.app) throw "The Screen named " +this.name+ " needs to specify an app!"
    if (this.screen) throw "The Screen named " +this.name+ "can not specify any screen: in its constructor"
  },
  initializeScreenContext: function() {
    this.context.store("screenName", this.name);
  },
});
