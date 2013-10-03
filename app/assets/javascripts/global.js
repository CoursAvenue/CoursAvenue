var GLOBAL = GLOBAL || {};
GLOBAL.initialize_callbacks = [];
GLOBAL.IMAGE_TYPE_REGEX = /(\.|\/)(gif|jpe?g|png|bmp)$/i;
GLOBAL.MAX_IMAGE_SIZE   = 5000000; // 5mo
GLOBAL.DATE_FORMAT      = 'DD/MM/YYYY';
// GLOBAL.DATE_FORMAT      = 'dd/mm/yyyy';
GLOBAL.isImageValid = function(file) {
  return file.type.match(GLOBAL.IMAGE_TYPE_REGEX) && file.size < GLOBAL.MAX_IMAGE_SIZE
}

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

GLOBAL.flash = function(text, class_name) {
    var flash = $('<div class="flash ' + class_name + '">').text(text);
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
