window.Rylyz.ObjectData = window.Rylyz || {};

window.Rylyz.ObjectData = Backbone.Model.extend({});
window.Rylyz.ObjectDisplay = Backbone.View.extend({
  dataType: 'object',
  dataDefaults: null,
  isCollectionItem: false,

  app:null,
  screen:null,
  parent:null,

  referenceTable: null,
  context: null,
  settings: null,
  eventBase: null, //cache the basic event info for this object

  tagName: "div",  //html tag element
  className: "",  //css classname

  origin: function() {
    var o = null;
    if (this.parent) o = this.parent.origin() + "." + this.name;
    else o = this.name;
    return o;
  },
  allSettings: function(){
    var displays = [];
    var d = this;
    while (d) {
      displays.push(d);
      d = d.parent;
    }
    allsettings = {}

    var s=null;
    for(var idx=0; idx<displays.length; idx++) {
      d = displays[idx];
      s = d.settings;
      if (s) jQuery.extend(allsettings, s);
    }
    return allsettings;
  },
  materializeEvent: function (options) {
    var hash = options || {}
    if (!this.eventBase) {
      var appName=null, screenName=null, displayName=null, origin=null, ctx=null;
      if (this.app) appName=this.app.name;
      if (this.screen) {
        screenName = this.screen.name;
        displayName = this.name;
      }
      else if ('screen' == this.dataType) screenName = this.name;
      origin =  this.origin();
      ctx = this.context.data();
      this.eventBase = {
        origin: origin,
        context: ctx,
      };
      if (this.app) this.eventBase.appName = this.app.name;
      if (this.screen) this.eventBase.screenName = this.screen.name;
    };
    jQuery.extend(hash, this.eventBase); //! this modifies hash
    hash.context = this.context.data();
    hash.settings = this.allSettings();
    return hash;
  },
  getTemplateSelector: function() {
    var templateSelector = null;
    var appName = this.app.name;
    if (this.isCollectionItem) {
      if (!this.templateName) { throw "No object template found for <item name='" +this.templateName+ "'>\n"; }
      templateSelector = "rylyz[name='" +appName+ "'] > item[name='" +this.templateName+ "']"
    }
    else {
      if (!this.templateName) { throw "No object template found for <object name='" +this.templateName+ "'>\n"; }
      //+++ 1st see if there is an object[template='"this.templateName"'], if not then get the object[name='']
      templateSelector = "rylyz[name='" +appName+ "'] > object[name='" +this.templateName+ "']";
      //+++ throw exception if there is both a template= and a name= found with the same name
      //+++ throw exception if there is more than 1 template found with this name
      //+++ be sure to do the same with collections
      //+++ be sue to do tha same with screens and apps also
      // (Don't need to check for collection-item template since it is always a template anyway, and never has a named data)
    }
    return templateSelector;
  },
  triggerInitStart: function(newSettings) { },
  triggerInitEnd: function() { },
  triggerRenderStart: function(newSettings) { },
  triggerRenderEnd: function() { },
  triggerDataLoadStart: function(newSettings) { },
  triggerDataLoadEnd: function() { },
  triggerShowStart: function(newSettings) { },
  triggerShowEnd: function() { },

  initialize: function() {
    this.triggerInitStart();


    this.settings = {};
    this.referenceTable = new Rylyz.ReferenceTable();

    this.context = new Rylyz.Context();
    this.context.display = this;

    this.name = this.name || this.options.name || null;
    this.app = this.app || this.options.app || null;
    this.screen = this.screen || this.options.screen || null;

    if(DBUG) console.info("Initializing " +this.dataType+ ": " + this.name);
    this.isCollectionItem = this.isCollectionItem || this.options.isCollectionItem || false;


    this.initializeRootTagCSS(); //setup css of root html tag

    this.initializeTemplateName();
    this.initializeParent();

    //initialize display first to load any data-defaults="{ ... } attributes"
    this.initializeDisplay();
    this.initializeData();
    this.initializeDataEventBindings();

    this.initializeReference();

    var initialize4Type = "initialize" + this.dataType.capitalize() + "Display";
    this[initialize4Type]();

    //initialize the context and type specific context
    var initializeContext4Type = "initialize" + this.dataType.capitalize() + "Context";
    this.initializeContext();
    this[initializeContext4Type]();

    this.dataDefaults = this.dataDefaults || {};

    this.triggerInitEnd();
    if(DBUG) console.info("Initializing Complete " +this.dataType+ ": " + this.name);
  },
  initializeRootTagCSS: function() {
    var dash = "-";
    //this.$el.addClass(this.name +sp+ this.dataType );
    this.$el.addClass(this.name +dash+ this.dataType );
  },
  initializeTemplateName: function() {
    this.templateName = this.templateName || this.options.templateName || this.name;
  },
  initializeParent: function() { this.parent = this.parent || this.options.parent || null; },
  initializeData: function() {
    this.model = this.model || this.options.model || this.objectData || this.options.objectData || new Rylyz.ObjectData(this.dataDefaults);
  },
  initializeReference: function() {
    //this.screen.referenceTable.storeData(this.name, this.model);
    //this.screen.referenceTable.storeObjectDisplay(this.name, this);
  },
  initializeContext: function() {
    this.context.store("displayName", this.name);
  },
  initializeObjectContext: function() {
  },
  initializeObjectDisplay: function() {
  },
  initializeDisplay: function() {
    var selector = this.getTemplateSelector();
    var elTemplate = $(selector);
    if (!elTemplate.length) {
      console.error("Template does not exist:\n" + selector + "\n\n")
      return;
    }
    if (1<elTemplate.length) {
      if(DBUG) console.info("Multiple templates found for:\n" + selector + "\n\n")
    }

    if (this.isCollection()) {
      //pick off the template name for the collection items
      // if(!elTemplate[0].getAttribute("item") ) throw "Collection must specify its itemTemplateName: <collection name='" +this.name+ "' item='???'>"
      // this.itemTemplateName = elTemplate[0].getAttribute("item");

      if(elTemplate[0].getAttribute("item") ) {
        this.itemTemplateName = elTemplate[0].getAttribute("item");
      }
      else {
        this.itemTemplateName = this.name + "-item";
      }

      if(elTemplate[0].getAttribute("data-defaults")){ // pick off the data-defaults attribute to set any defaults
        var defaults = null;  // should be specified as a collection: data-defaults='[{color:"blue"}, {color:"red"}]'
        var evalString = "defaults = " +elTemplate[0].getAttribute("data-defaults");
        try{
          eval(evalString);
          if(defaults) {
            if ($.isArray(defaults)) {
              this.dataDefaults = defaults;
            }
            else {
              console.error("data-defaults='[{}, {}]' for a collection must be an array!")
              console.error(elTemplate[0].getAttribute("data-defaults"));
            }
          }
        } catch(err) {
          var msg ="Template error in " + elTemplate[0].getAttribute("name") + ":\n" + err + "\n\n";
          msg += "Could not evaluate data-defaults:\n";
          msg += elTemplate[0].getAttribute("data-defaults");
          msg += "Check your syntax, commas, etc."
          console.error(msg);
          console.error(err);
          return;
        }

      }

    }

    if (!this.isCollection()) {
      if(elTemplate[0].getAttribute("data-defaults")){ // pick off the data-defaults attribute to set any defaults
        var defaults = null;  // should be specified as an object: data-defaults='{color:"blue"}'
        var evalString = "defaults = " +elTemplate[0].getAttribute("data-defaults");
        eval(evalString);
        if(defaults) {
          this.dataDefaults = defaults;
        }
      }
    }

    this.initializeTemplateSettings(elTemplate[0]);

    var htmlTemplate = elTemplate.html();
    try { this.compiledTemplate = _.template(htmlTemplate); }
    catch(err) {
      var msg ="Template error in " + selector + ":\n" + err + "\n\n";
      console.error(msg);
      console.error(htmlTemplate );
      console.error(err);
      return;
    }
  },
  initializeTemplateSettings: function(template) {}, //default empty hook
  initializeDataEventBindings: function() {
    _.bindAll(this, 'render');
    this.model.bind('change', this.render);
  },

  isCollection: function() { return 'collection' == this.dataType; },
  addSubDisplay: function(subDisplay) {
    if (!subDisplay) throw "Attempted to add null subdisplay";
    if (this==subDisplay) throw "Display named '" +this.name+ "' can not add itself as a subDisplay!";

    //check if adding a display will create a cycle.
    var p = this.parent;
    var thisDisplay = this;
    while (p) {
      if (p==subDisplay) throw "You will create a cycle by adding SubDisplay named '" +subDisplay.name+ "' to Display named '" +thisDisplay.name+ "'!";
      p=p.parent;
    }
    if ("app" != this.dataType) {
      var s = this.screen;
      if ('screen' == this.dataType) s = this;
      if (undefined != s.displayTable[subDisplay.name]) throw "The screen named '" +s.name+ "' already has a display named '" +subDisplay.name+ "'!";
      s.displayTable[subDisplay.name] = subDisplay;
    }
    subDisplay.parent = this;
    this.referenceTable.storeDisplay(subDisplay.name, subDisplay);
  },
  allSubDisplays: function(idx) { return this.referenceTable.allDisplays(idx); },
  lookupSubDisplay: function (name){
    return this.referenceTable.lookupDisplay(name);
  },


  minimize: function() {
    this.remove();
  },
  renderInto: function(elParent) {
    if (!elParent || !elParent.length) {
      var msg = "Parent Element does not exist!";
      if (elParent && elParent.selector) msg +="\nSelector: " + elParent.selector;
      msg += "\n\n";
      console.warn(msg)
      console.warn(elParent)
      return;
    }

    this.triggerDataLoadStart(this.settings);
    elParent.append(this.render().el);
    this.preparePrompts();
  },
  render: function() {
    if (!this.compiledTemplate) {
      console.error("render failed!")
      return this;
    }

    this.triggerRenderStart();

    var data = this.model || new Rylyz.ObjectData(this.dataDefaults);
    var jsonData = data.toJSON();
    try {
     var htmlContent = this.compiledTemplate(jsonData);
    }
    catch(err) {
      var msg ="Could not render template for " + this.getTemplateSelector() + " with data.\nError:\n" + err + "\n";
      msg += "Data:\n" + JSON.stringify(data) + "\n\n"
      console.error(msg);

      return this;
    }
    this.$el.html(htmlContent);

    //re-bind handlers for this display
    this.fireOn("click"); // bind all fire-onClick events
    this.fireOn("hover"); // bind all fire-onHover events
    this.eventOn("nav", "click"); // bind all nav-onClick events
    this.eventOn("intent", "click"); // bind all intent-onClick events

    var thisDisplay = this;
    this.$("form").unbind('submit'); //rebind forms
    this.$("form").submit(function(event){
      ev = thisDisplay.materializeEvent({queue:'form', type:'submit', domEvent:event});
      Rylyz.event.fireEvent(ev);
      return false;
    });

    //render sub displays
    if (this.renderCollectionObjects) this.renderCollectionObjects();
    this.loadSubDisplays();
    this.renderSubDisplays();
    if (this.launch) this.launch();


    this.triggerRenderEnd();

    return this;
  },
  renderSubDisplays: function() {
    var subName = null;
    var subTemplate = null;
    var spotSelector = null
    var parentDisplay = this;
    $.each(this.allSubDisplays(), function(idx, subDisplay) {
      subName = subDisplay.name;
      spotSelector = subDisplay.dataType+"[name='" +subName+ "']";
      subDisplay.renderInto(parentDisplay.$(spotSelector));
    });
  },
  unload: function() {
    if (this.unloadData) this.unloadData();
    this.remove();
  },
  unloadData: function() {
  },
  loadDataSet: function() {
    //console.info('---------' + this.dataSet)
    //Rylyz.Service.fireDataEvent4lookup({dataSet: this.dataSet})
  },
  loadSubDisplays: function() { // load (instantiate) sub displays objects
    if (this.subDisplaysAreLoaded) return;

    this.loadSubObjectDisplays();
    this.loadSubCollectionDisplays();

    this.subDisplaysAreLoaded = true;
  },
  loadSubObjectDisplays: function() { // load (instantiate) sub objectDisplays objects
    var objectName = null;
    var objectDisplay = null;
    var objectSpots = this.$("object[name]");

    var thisApp = this.app;
    var thisScreen = this.screen;
    if(!thisScreen && 'screen' == this.dataType) thisScreen = this;
    var parentDisplay = this;
    $.each(objectSpots, function(idx, objectSpot) {
      objectName = objectSpot.getAttribute('name');
      objectDisplay = new Rylyz.ObjectDisplay({name:objectName, app:thisApp, screen:thisScreen});
      parentDisplay.addSubDisplay(objectDisplay);
    })
  },
  loadSubCollectionDisplays: function() { // load (instantiate) sub objectDisplays objects
    var collectionName = null;
    var collectionDisplay = null;
    var collectionSpots = this.$("collection[name]");

    var thisApp = this.app;
    var thisScreen = this.screen;
    if(!thisScreen && 'screen' == this.dataType) thisScreen = this;
    var parentDisplay = this;
    $.each(collectionSpots, function(idx, collectionSpot) {
      collectionName = collectionSpot.getAttribute('name');
      collectionDisplay = new Rylyz.CollectionDisplay({name:collectionName, app:thisApp, screen:thisScreen});
      parentDisplay.addSubDisplay(collectionDisplay);
    })
  },
  fireOn: function(domEventType, suppressWarning) {
    var eventType = $.trim(domEventType.toLowerCase()); //name of the dom event in lower case
    var fireOn = "fire-on" + eventType.capitalize(); //name of the data attribute

    var eventBase = this.materializeEvent();
    this.$("[" + fireOn + "]").bind(eventType, function(domEvent) {
      Rylyz.event.fireOnDOMEvent(eventType, domEvent, eventBase);
    });
    //verify the syntax
    var onClickElements = this.$("[" + fireOn + "]");
    if (0==onClickElements.length){
      //if (!suppressWarning) console.warn("No events described with " + fireOn + "!\n\n");
      return;
    }
    var tmpl8 = this.getTemplateSelector();
    var eventDescription, toEval, ev;

    _.each(onClickElements, function(element){
      eventDescription = element.getAttribute(fireOn);
      try {
        ev = null;
        toEval = "ev = " + eventDescription;
        eval(toEval);
      }
      catch (err) {
        var msg = "Invalid syntax for " +eventType+ " event in template " +tmpl8+ ":\n"
        msg += fireOn +  ' = "' + eventDescription + '"\n';
        msg += "Be sure to quote the values and use commas to separate parameters!\n\n"
        console.error(msg);
      }
    })
  },

  eventOn: function(rylyzEventType, domEventType) {
    var uiEventType = $.trim(domEventType.toLowerCase()); //name of the dom event in lower case
    var eventOnDomEvent = rylyzEventType + "-on" + uiEventType.capitalize(); //name of the data attribute

    var eventBase = this.materializeEvent();
    eventBase.queue = rylyzEventType; //nav
    eventBase.type = eventOnDomEvent; //nav-onClick

    this.$("[" + eventOnDomEvent + "]").bind(uiEventType, function(domEvent) {
      var element = srcElementForDOMEvent(domEvent);
      var ev = eventBase;
      ev[eventOnDomEvent] = element.getAttribute(eventOnDomEvent);
      var settings = element.getAttribute('settings') || {};
      var select = element.getAttribute('select') || null;
      var data = element.getAttribute('data') || {};
      settings.select = settings.select || select;
      ev.settings = settings;
      ev.data = data;
      Rylyz.event.fireEvent(ev);
    });
  },
  preparePrompts: function() {
    /*
    <div class="prompt">
      <label>Enter email</label>
      <input id="login_id" name="login_id" size="30" type="text">
    </div>

    for each .field:
      on click: set focus to input
      for the field's input:
        onFocus: hide the label
        onBlur: show the label if value.nil?
    */
    this.$(".prompt").each (function (idx){
      var label = $(this).find("label");
      var input = $(this).find("input");
      if (input.val() != "") label.addClass("invisible")
      $(this).click(function(srcc){
        input.focus();
      })
      input.focus(function (srcc){
        label.removeClass("invisible") //remove the style so we do not add it 2x
        label.addClass("invisible")
      })
      input.blur(function (srcc){
        if ($(this).val() == "") label.removeClass("invisible")
      })
    })
  },


  /*
  renderObjectDisplay: function(setup) {
    return this.renderData(setup, false);
  },
  renderCollectionDisplay: function(setup) {
    return this.renderData(setup, true);
  },
  renderData: function(setup, isCollection) {
    var methodName = "render";
    methodName += isCollection? "Collection": "Model"
    if (!setup) throw "invalid setup to " + methodName ;
    if (!setup.name) throw "name is required to" + methodName ;
    if (!setup.placeInto) throw "placeInto is required to " + methodName ;

    var modelData, modelDisplay;
    modelData = this.screen.referenceTable.lookupData(name) || null;
    modelDisplay = this.screen.referenceTable.lookupDisplay(name) || null;

    //if !madelData this.materializeModelData
    //if !madelDiplay this.materializeModelDisplay
    if (!modelData || !modelDisplay) {
      var name = setup.name;
      var objectData = setup.objectData || setup.data || setup.object || {};
      var collectionData = setup.collectionData || setup.dataCollection || setup.collection ||[];
      if (!isCollection && objectData && $.isArray(objectData)) {
        throw "Use renderCollectionDisplay when your data is a collection: " + objectData;
      }
      else if (!collectionData && objectData) {
        collectionData = objectData;
      }
      var placeInto = setup.placeInto;
      var fireOn = setup.fireOn;

      var modelTemplate, collectionTemplate;
      if (isCollection) {
        modelTemplate = setup.objectTemplate || setup.objectDataTemplate || setup.dataTemplate || setup.modelTemplate || setup.elementTemplate || setup.elementName || setup.itemTemplate || setup.itemName; //required!
        if (!modelTemplate) throw "elementTemplate is required to renderCollection";
        collectionTemplate = setup.template || setup.collectionTemplate || name //default to use the same name
      }
      else {
        modelTemplate = setup.template ||  setup.modelTemplate || setup.objectTemplate ||  setup.objectDataTemplate || setup.itemName || name //default to use the same name
      }

      //setup the model class
      var modelDefaults = setup.modelDefaults || setup.objectDefaults || setup.objectDataDefaults || {}
      var modelClass = setup.modelClass || setup.objectClass || setup.objectDataClass || Rylyz.ObjectData.extend({defaults:modelDefaults})
      //setup the objectDisplayClass class
      var objectDisplayClass = Rylyz.ObjectDisplay.extend({templateName:modelTemplate});

      var collectionClass, collectionDisplayClass;
      if(isCollection) {
        // setup the Collection class
        collectionClass = Rylyz.CollectionData.extend({ model: modelClass });
        // setup the collectionDisplay class
        collectionDisplayClass = Rylyz.CollectionDisplay.extend({ templateName: collectionTemplate, objectDisplayClass: objectDisplayClass });
      }

      if(!isCollection) { // create an istance of the model and an objectDisplayClass, bind.
        if (!objectData) console.warn("objectData not specified in renderObjectDisplay");
        modelData = modelData || new modelClass(objectData); //new model instance
        modelDisplay = new objectDisplayClass({model:modelData}); //new modelDisplay instance
      }
      else { // create an instance of the collection and collectionDisplay, bind.
        if (!collectionData) console.warn("collectionData not specified in renderCollection");
        modelData = modelData || new collectionClass(collectionData);
        modelDisplay = new collectionDisplayClass({collection:modelData});
      }
//        this.screen.referenceTable.storeData(name, modelData);
//        this.screen.referenceTable.storeDisplay(name, modelDisplay);
    }

    modelDisplay.renderInto(placeInto);

    if (fireOn) {
      var events = fireOn.split(',');
      _.each(events, function(ev) {
        display.fireOn(ev);
      })
    }
    return modelDisplay;
  }
  */
});

