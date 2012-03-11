window.Rylyz = window.Rylyz || {}

window.Rylyz.ReferenceTable = function (){
  this.table = {};
  this.storeData = function(name, data) {
    var d = this.table[name] || null;
    if (d && d.data && d.data!=data) throw "Name conflict! A Data named " + name + " already exists.";
    d = d || {}
    d.data = data;
    this.table[name] = d;
  };
  this.storeDisplay = function(name, display) {
    var d = this.table[name] || null;
    if (d && d.display && d.display!=display) throw "Name conflict! A Display named " + name + " already exists.";
    d = d || {}
    d.display = display;
    this.table[name] = d;
  };
  this.storeObjectDisplay =     function(name, display) { this.storeDisplay(name, display); }
  this.storeCollectionDisplay = function(name, display) { this.storeDisplay(name, display); }
  this.storeAppDisplay =        function(name, display) { this.storeDisplay(name, display); }
  this.storeScreenDisplay =     function(name, display) { this.storeDisplay(name, display); }

  this.lookup = function(name) {
    var d = this.table[name] || null;
    return d;
  };
  this.lookupData = function(name) {
    var d = this.table[name] || null;
    d = d || {}
    this.table[name] = d;
    return d.data;
  };
  this.lookupDisplay = function(name) {
    var d = this.table[name] || null;
    d = d || {}
    this.table[name] = d;
    return d.display;
  };
  this.lookupScreen = function(name) { return this.lookupDisplay(name); }
  this.lookupApp = function(name) { return this.lookupDisplay(name); }

  this.allDisplays = function(idx){
    var list = [];
    $.each(this.table, function(idx, value) {
      if(value && value.display)  list.push(value.display);
    });

    if (!idx) return list;
    if (idx && -1<idx && list.length>idx) return list[idx];
    return null;
  };
}
