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

GLOBAL.DataTable = GLOBAL.DataTable || {};
GLOBAL.DataTable.dateParseFunction = function(date) {
    if (date.replace(/^\s+|\s+$/g, '').length === 0) { // Strip
        return 0;
    } else {
        return new Date(date).getTime();
    }
};
