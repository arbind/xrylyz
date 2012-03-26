// +++ util for dom events: http://www.quirksmode.org/js/events_properties.html

//Debug messages
window.DBUG = window.DBUG || false;
window.dbugOut = window.dbugOut || function(){ return null };

window.Rylyz = window.Rylyz || {}

window.refreshCSSUniqueCounter = 0;
Rylyz.refreshCSS = function() {
  var css_link, links = [];
  jQuery("head link").each(function(idx, link) { links.push(link.href); })
  jQuery("head link").remove();
  jQuery.each(links, function(idx, href) {
    css_link = $("<link>", { rel: "stylesheet", type: "text/css", href: href+"?a="+refreshCSSUniqueCounter++});
    css_link.appendTo('head');
    console.log(href);
  });
};


// add peek to array
if ('function' != typeof Array.prototype.peek) {
  Array.prototype.peek = function(){ return this.length? (this[this.length-1]) : (null) ; }
}

if ('function' != typeof hostnameOfURL) {
  window.hostnameOfURL = function (url) {
    if (null==url || ""==url) return "";
    try { 
      var tokens = url.match(/:\/\/(.[^/]+)/)
      if (null==tokens || tokens.length < 2 ) return "";
      var hostname = tokens[1];
      if (null==hostname) return "";
      hostname = hostname.replace('www.','');
      return hostname;
    }
    catch (e) { return ""; }
  }
}


if ('function' != typeof extractFormDataSet) {
  window.extractFormData = function(form) {
    var formData = {};
    if (!form) return formData;

    if ('string' == typeof form.action ) formData.action = form.action;
    if ('string' == typeof form.target ) formData.target = form.target;
    if ('string' == typeof form.method ) formData.method = form.method;
    if ('string' == typeof form.title ) formData.title = form.title;
    if ('string' == typeof form.id ) formData.id = form.id;
    if ('string' == typeof form.name ) formData.name = form.name;

    var dataSet = {};

    var element;
    var data;
    for (var i=0;i<form.length;i++) {
      element = form.elements[i]
      if (undefined == element.value) continue;

      var count = 0;
      data = {};
      if ('string' == typeof element.type) data.type = element.type;
      if ('string' == typeof element.name) data.name = element.name;
      if (!data.name) data.name = data.type + "-"+count++;
      if ('string' == typeof element.value) data.value = element.value;
      dataSet[data.name] = data;
    };
    formData.dataSet = dataSet;
    return formData;
  }
}

// get the source DOM element for a Dom Event
if ('function' != typeof srcElementForDOMEvent) {
  window.srcElementForDOMEvent = function (ev) {
    if (!ev) return null;  
    var srcEl = ev.target || ev.srcElement; 
    if (!srcEl) return null;
    if (srcEl.nodeType == 3) srcEl = srcEl.parentNode; // when clicked on a text element, get its parent      
    return srcEl
  }
}

// get the data attributes from a DOM element for a Dom Event
if ('function' != typeof dataFromDOMElement) {
  window.dataFromDOMElement = function(domElement) {
    var data = {};
    if (!domElement) return data;

    var att, attName;
    var atts = domElement.attributes;
    for (var i = 0; i < atts.length; i++) {
      att = atts[i];
      if (att.specified && att.name.startsWith("data-")) {
        attName = att.name.slice(5);
        data[attName] = att.value;
      }
    }
    return data;
  }
}

// get the data attributes from Dom Event's srcElement
if ('function' != typeof dataFromDOMEvent) {
  window.dataFromDOMEvent = function(domEvent) {
    var srcEl = srcElementForDOMEvent(domEvent);
    var data = dataFromDOMElement(srcEl)
    return data;
  }
}

window.toString = function(object) {
  if ('string' == typeof object) return object;
  var s;
  if (undefined == object.length) { //this is an array
    s = "\n[\n";
    for (o in object) {
      s += "  " + toString(o) + ",\n";
    }
    s += "]\n";
  }
  else {
    s = "\n{\n";
    for (p in this) {
      s += " " +p +": " + this[p] + ",\n";
    }
    s += "}\n";
  }
  return s;
}

Object.toString = Object.prototype.toString;

if ('function' != typeof Object.keys) {
  Object.keys = function(o){
    if (o !== Object(o))
      throw new TypeError('Object.keys called on non-object');
    var ret=[],p;
    for(p in o) if(Object.prototype.hasOwnProperty.call(o,p)) ret.push(p);
    return ret;
  }
}

if ('function' != typeof objectsAreEqual) {
  window.objectsAreEqual = function (o1, o2) {
    if (o1 !== Object(o1) || o2 !== Object(o2))
      throw new TypeError('Object.keys called on non-object');
    for (p in o1) {
      if (o1[p] != o2[p]) return false;
    }
    return true;
  }
}
