var GLOBAL = GLOBAL || {};

/*
 * Usage:
 * var constants = GLOBAL.namespace('GLOBAL.constants');
 */

GLOBAL.namespace = function (ns_string) {
    if (typeof ns_string === 'undefined') { ns_string = 'GLOBAL' }
    var parts = ns_string.split('.'), parent = GLOBAL, i;
    // strip redundant leading global
    if (parts[0] === "GLOBAL") {
        parts = parts.slice(1);
    }
    for (i = 0; i < parts.length; i += 1) {
    // create a property if it doesn't exist
        if (typeof parent[parts[i]] === "undefined") {
            parent[parts[i]] = {};
        }
        parent = parent[parts[i]];
    }
    return parent;
};

GLOBAL.flash = function(text) {
    var flash = $('<div class="flash">').text(text);
    $(document.body).append(flash)
    flash.flash();
}

// GLOBAL.DataTable = GLOBAL.DataTable || {};
// GLOBAL.DataTable.dateParseFunction = function(date) {
//     if (date.replace(/^\s+|\s+$/g, '').length === 0) { // Strip
//         return 0;
//     } else {
//         return new Date(date).getTime();
//     }
// };

// ----------------------- BIND Fuction
if (!Function.prototype.bind) {
  Function.prototype.bind = function (oThis) {
    if (typeof this !== "function") {
      // closest thing possible to the ECMAScript 5 internal IsCallable function
      throw new TypeError("Function.prototype.bind - what is trying to be bound is not callable");
    }

    var aArgs = Array.prototype.slice.call(arguments, 1),
        fToBind = this,
        fNOP = function () {},
        fBound = function () {
          return fToBind.apply(this instanceof fNOP && oThis
                                 ? this
                                 : oThis,
                               aArgs.concat(Array.prototype.slice.call(arguments)));
        };

    fNOP.prototype = this.prototype;
    fBound.prototype = new fNOP();

    return fBound;
  };
}
