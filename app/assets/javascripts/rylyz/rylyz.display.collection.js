window.Rylyz.CollectionData = Backbone.Collection.extend({});
window.Rylyz.CollectionDisplay = Rylyz.ObjectDisplay.extend({
  dataType: 'collection',
  itemTemplateName: null,

  app: null,
  screen:null,
  dataDefaults:null,

  initializeTemplateName: function() {
    this.templateName = this.templateName || this.options.templateName || this.name;
    //this.itemTemplateName is set in initializeDisplay()
  },
  initializeData: function() {
    this.collection = this.collection || this.options.collection || this.collectionData || this.options.collectionData || new Rylyz.CollectionData(this.dataDefaults);
  },
  initializeCollectionDisplay: function() {
    this.dataDefaults = [];
    if (!this.app) throw "The Collection named " +this.name+ " needs to specify an app!"
    if (!this.screen) throw "The Collection named " +this.name+ " needs to specify a screen!"
    //this.screen.referenceTable.storeData(this.name, this.model);
    //this.screen.referenceTable.storeCollectionDisplay(this.name, this);
  },
  initializeDataEventBindings: function() {
    _.bindAll(this, 'render');
    this.collection.bind('reset', this.render);      
    this.collection.bind('add', this.render);      
    this.collection.bind('remove', this.render);      
  },

  initializeCollectionContext: function() {
    this.context.store("isCollection", "true");
  },

  getTemplateSelector: function() {
    if (!this.name) { throw "No collection template found for <collection name='" +this.name+ "'>\n"; }
    var appName = this.app.name;
    return "rylyz[name='" +appName+ "']  > collection[name='"+ this.name + "']";
  },
  renderCollectionObjects: function() {
    this.objectDisplayClass = this.objectDisplayClass || Rylyz.ObjectDisplay

    var $listSelector = this.$("collection");
    if (!$listSelector.length) {
      var msg = "The "+ this.getTemplateSelector() + " is missing it's collection element!\n";
      msg += "Here's an example template in order to render the collection's elements:\n";
      msg += " ------------------------------------------------------------------ \n";
      msg += "  <script collection='"+this.name+" element='"+this.name+"-element' type='text/template' >\n"
      msg += "    <collection/>\n"
      msg += "  </script>\n";
      msg += " ------------------------------------------------------------------ \n";
      console.error(msg);
      return;
    }
    var thisApp = this.app;
    var thisScreen = this.screen;
    if(!thisScreen && 'screen' == this.dataType) thisScreen = this;
    var objectDisplay;
    var displayConstructor = this.objectDisplayClass
    var itemName = this.name + "-";
    var itemTemplateName = this.itemTemplateName;
    var idx=0;
    var parentDisplay = this;
    // this.collection.each (function(model) {
    //   objectDisplay = new displayConstructor({name:itemName+idx, templateName:itemTemplateName, model:model, isCollectionItem:true, app: thisApp, screen: thisScreen, parent:parentDisplay})
    //   $listSelector.append(objectDisplay.render().el);
    //   idx++;
    // });
    var itemContainer;
    var itemContent;
    this.collection.each (function(model) {
      objectDisplay = new displayConstructor({name:itemName+idx, templateName:itemTemplateName, model:model, isCollectionItem:true, app: thisApp, screen: thisScreen, parent:parentDisplay})
      itemContainer = objectDisplay.render().el;
      $listSelector.append($(itemContainer).contents());
      idx++;
    });
    $listSelector.replaceWith($listSelector.contents());
  }
});



