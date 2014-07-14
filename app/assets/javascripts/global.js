var GLOBAL = GLOBAL || {};
GLOBAL.initialize_callbacks = [];
GLOBAL.IMAGE_TYPE_REGEX     = /(\.|\/)(gif|jpe?g|png|bmp)$/i;
GLOBAL.MAX_IMAGE_SIZE       = 5000000; // 5mo
GLOBAL.DATE_FORMAT          = 'dd/mm/yyyy';
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

/*
 * @params text Text that will appear in the flash
 * @params class_name class added to the flash, by default it will be alert
                      the flash will be an error
 */
GLOBAL.flash = function(text, class_name) {
    class_name = class_name || 'alert';
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

GLOBAL.DEBOUNCE_DELAY = 400;

GLOBAL.normalizeAccents = function(string) {
  string = string.replace(/[éèêë]/g, 'e');
  string = string.replace(/[àäâ]/g, 'a');
  string = string.replace(/[îï]/g, 'i');
  return string;
}


/* wow debounce! Call it like this:
 *
 *   wat: function () {
 *
 *   }.debounce(500),
 *
 * Remeber that the function will still be called with "this" bound
 * to whatever it would normally be called with. So if you pass wat
 * as an event handler, it will not have a Marionette object as its
 * this, unless you also bind it to this in the context of the Marionette
 * object.
 *
 *   this.on("click", this.wat); // NO!
 *   this.on("click", this.wat.bind(this)); // OK!
 *
 *   wat: function () {
 *
 *   }.debounce(500).bind(this), // Sure, why not!?
 *
 * */
if (!Function.prototype.debounce) {
    Function.prototype.debounce = function (time) {
        if (typeof this !== "function") {
          // closest thing possible to the ECMAScript 5 internal IsCallable function
          throw new TypeError("Function.prototype.debounce - what is trying to be bound is not callable");
        }

        var args      = Array.prototype.slice.call(arguments, 0), // put the arguments into an arra
            wait      = args.shift(), // the first is the wait
            immediate = (args.shift() === undefined)? false : true; // the second is the "immediate" flag

        return _.debounce(this, wait, immediate);
    }
}
// Test links that should be matched
// ["toto.com", "http://toto.com", "http://www.coazd.com", "www.my-site.com"].join(' ')
// Test links that should NOT be matched
// ["U.S.A"]
GLOBAL.hideContactsInfo = function hideContactsInfo (text) {
    if (!text) { return ''; }
    // Phone numbers
    text = text.replace(/((\+|00)33\s?|0)[0-9]([\s-\.]?\d{2}){4}/g, '<a class="pointer" data-behavior="show-contact-panel">(numéro de téléphone)</a>')
    // Links
    text = text.replace(/((http|ftp|https):\/\/)?[\w\-_]{2,}(\(point\)[\w\-_]|\.[\w\-_])+([\w\-\.,@?^=%&amp;:/~\+#]*[\w\-\@?^=%&amp;/~\+#])?/gi, '<a class="pointer" data-behavior="show-contact-panel">(site internet)</a>')
    // Emails
    text = text.replace(/([^@\s]+)@(([-a-z0-9]+\.)+[a-z]{2,})/gi, '<a class="pointer" data-behavior="show-contact-panel">(e-mail de contact)</a>');
    return text;
}

