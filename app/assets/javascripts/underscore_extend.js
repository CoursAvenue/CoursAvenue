/* Extending Underscore convenience method */
_.extend(_, {

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
    }
});
