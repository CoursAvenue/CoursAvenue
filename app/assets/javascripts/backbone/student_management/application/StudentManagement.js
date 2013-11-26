StudentManagement = (function (){
    var self = new Backbone.Marionette.Application({
        slug: 'student-management',

        /* for use in query strings */
        root:   function() { return self.slug + '-root'; },
        loader: function() { return self.slug + '-loader'; },

        /* methods for returning the relevant jQuery collections */
        $root: function() {
            return $('[data-type=' + self.root() + ']');
        },

        /* Return the element in which the application will be appended */
        $loader: function() {
            return $('[data-type=' + self.loader() + ']');
        },

        /* A filteredSearch should only start if it detects
         * an element whose data-type is the same as its
         * root property.
         * @throw the root was found to be non-unique on the page */
        detectRoot: function() {
            var result = self.$root().length;

            if (result > 1) {
                throw {
                    message: 'StudentManagement->detectRoot: ' + self.root() + ' element should be unique'
                }
            }

            return result > 0;
        },
    });

    return self;
}());

StudentManagement.addRegions({
    mainRegion: '#' + StudentManagement.slug
});

StudentManagement.addInitializer(function(options) {
    // initialize the app
});

$(document).ready(function() {
    /* we only want the filteredsearch on the search page */
    if (StudentManagement.detectRoot()) {
        StudentManagement.start({});
    }

});
