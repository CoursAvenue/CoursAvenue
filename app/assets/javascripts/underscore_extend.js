/* Extending Underscore convenience method */
_.extend(_, {
    capitalize: function capitalize (word) {
        if (!word) { return ''; }
        return word.charAt(0).toUpperCase() + word.slice(1);
    },

    plural_map:{
        "oxen"  : "ox",
        "people": "person"
    },

    getSingularMap: function getSingularMap () {
        if (_._singular_map === undefined) {
            _._singular_map = _.invert(this.plural_map);
        }

        return _.clone(_._singular_map);
    },

    singularize: function singularize (word) {
        var last        = word.length - 1;
        var ends_with_s = word.lastIndexOf("s") === last;
        var is_plural   = ends_with_s || _.has(_.plural_map, word);

        if (!is_plural) {
            return word;
        }

        return (ends_with_s)? word.substring(0, last) : _.plural_map[word];
    },

    pluralize: function pluralize (word) {
        var last        = word.length - 1,
            ends_with_s = word.lastIndexOf("s") === last,
            is_plural   = ends_with_s || _.has(_.plural_map, word),
            map;

        if (is_plural) {
            return word;
        }

        map = _.getSingularMap();

        return (map[word] === undefined)? word + 's' : map[word];
    },

    camelize: function camelize (word) {
        return word.replace (/(?:^|[-_])(\w)/g, function (_, c) {
            return c ? c.toUpperCase () : '';
        });
    },

    ensureArray: function ensureArray (a, b, n) {
        if (arguments.length === 0) return []; //no args, ret []
        if (arguments.length === 1) { //single argument
            if (a === undefined || a === null) return []; // undefined or null, ret []
            if (Array.isArray(a)) return a; // isArray, return it
        }
        return Array.prototype.slice.call(arguments); //return array with copy of all arguments
    }
});
