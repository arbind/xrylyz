window.Rylyz = window.Rylyz || {}

window.Rylyz.Context = function(display) {
  this.display = display || null;
  this.dataSet = {};
  this.store = function (key, value) {
    if (!key || undefined ==key) throw "Can not store into context without a key!";
    this.dataSet[key] = value;
  };
  this.lookup = function(key) {
    if (!key || undefined ==key) throw "Can lookup values from context without a key!";
    if (this.dataSet.hasOwnProperty(key)) {
      var v = this.dataSet[key];
      if (undefined == v) v = null;
      return v;
    }
    //data not found in this context, lookup it up in parent
    if (null==this.display || null==this.display.parent) return null;
    return this.display.parent.context.lookup(key);
  };
  this.localData = function() {
    return this.dataSet;
  }
  this.data = function() {
    if (!this.display) return this.localData();
    var ctx = {}
    return this.extendParentContext(ctx, this.display);
  };
  this.extendParentContext = function(ctx, dsply) {
    //add parent context
    if (dsply.parent) $.extend(ctx, this.extendParentContext(ctx, dsply.parent))
    //override with local context
    $.extend(ctx, dsply.context.localData());
    return ctx;
  };
};
