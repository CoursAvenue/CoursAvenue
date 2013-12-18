UserManagement = new Backbone.Marionette.Application({ slug: 'user-management' });

UserManagement.addRegions({
    mainRegion: '#' + UserManagement.slug
});

UserManagement.addInitializer(function(options) {
    var bootstrap = window.coursavenue.bootstrap;

    var user_profiles                 = new UserManagement.Models.UserProfilesCollection(bootstrap.models, bootstrap.options);
    var user_profiles_collection_view = new UserManagement.Views.UserProfilesCollection.UserProfilesCollectionView({
        collection: user_profiles,
        events: {
            'pagination:next':     'nextPage',
            'pagination:prev':     'prevPage',
            'pagination:page':     'goToPage'
        }
    });

    user_profiles.bootstrap();
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

    layout.master.show(user_profiles_collection_view);

});

$(document).ready(function() {
    /* we only want the filteredsearch on the search page */
    if (UserManagement.detectRoot()) {
        UserManagement.start({});
    }

});
