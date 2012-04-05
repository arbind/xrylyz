//String.capitalize()
if ('function' != typeof String.prototype.capitalize) {
  String.prototype.capitalize = function (){
    if (null==this || 0==this.length) return "";
    if (1==this.length) return this.toUpperCase();
    return this.substr(0,1).toUpperCase() + this.slice(1);
  }
}

//String.startsWith(substring)
if ('function' != typeof String.prototype.startsWith) {
  String.prototype.startsWith = function (str){
    return this.slice(0, str.length) == str;
  };
}

//String.endsWith(substring)
if ('function' != typeof String.prototype.endsWith) {
  String.prototype.endsWith = function (str){
    return this.slice(-str.length) == str;
  };
}

//String.trim()
if ('function' != typeof String.prototype.trim) {
  String.prototype.trim = function() {
    return this.replace(/^\s+|\s+$/g,"");
  }
}

//String.ltrim()
if ('function' != typeof String.prototype.ltrim) {
  String.prototype.ltrim = function() {
    return this.replace(/^\s+/,"");
  }
}

//String.rtrim()
if ('function' != typeof String.prototype.rtrim) {
  String.prototype.rtrim = function() {
    return this.replace(/\s+$/,"");
  }
}