UserManagement = (function (){
    var self = new Backbone.Marionette.Application({
        slug: 'user-management',

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
                    message: 'UserManagement->detectRoot: ' + self.root() + ' element should be unique'
                }
            }

            return result > 0;
        },
    });

    return self;
}());

UserManagement.addRegions({
    mainRegion: '#' + UserManagement.slug
});

UserManagement.addInitializer(function(options) {
    console.log("UserManagement->initialize");
    // initialize the app

    var user_profiles                 = new UserManagement.Models.UserProfilesCollection({});
    var user_profiles_collection_view = new UserManagement.Views.UserProfilesCollection.UserProfilesCollectionView({
        collection: user_profiles,
        events: {
            'pagination:next':     'nextPage',
            'pagination:prev':     'prevPage',
            'pagination:page':     'goToPage'
        }
    });

    window.pfaff = user_profiles;

    layout = new UserManagement.Views.UserProfilesLayout();

    UserManagement.mainRegion.show(layout);

    pagination_top    = new CoursAvenue.Views.PaginationToolView({});
    pagination_bottom = new CoursAvenue.Views.PaginationToolView({});

    layout.showWidget(pagination_top, {
        events: {
            'user_profiles:updated:pagination': 'reset'
        },
        selector: '[data-type=pagination-top]'
    });

    layout.showWidget(pagination_bottom, {
        events: {
            'user_profiles:updated:pagination': 'reset'
        },
        selector: '[data-type=pagination-bottom]'
    });

    layout.results.show(user_profiles_collection_view);
    user_profiles_collection_view.changePage(2);
});

$(document).ready(function() {
    /* we only want the filteredsearch on the search page */
    if (UserManagement.detectRoot()) {
        UserManagement.start({});
    }

});
