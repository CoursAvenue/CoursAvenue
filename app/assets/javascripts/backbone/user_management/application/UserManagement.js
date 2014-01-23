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
            'pagination:next'             : 'nextPage',
            'pagination:prev'             : 'prevPage',
            'pagination:page'             : 'goToPage',
            'filter:summary'              : 'filterQuery',
            'controls:save'               : 'Commit',
            'controls:cancel'             : 'Cancel',
            'controls:select:all'         : 'selectAll',
            'controls:deselect:all'       : 'deselectAll',

            'click [data-behavior=select-all]'  : 'selectAll',
            'click [data-behavior=manage-tags]' : 'manageTags',
            'click [data-behavior=add-tags]'    : 'bulkAddTags',
            'click [data-sort]'                 : 'filter',
            'click [data-behavior=destroy]'     : 'destroySelected',
            'click [data-behavior=new]'         : 'newUserProfile',
            'click [data-behavior=uber-select]' : 'deepSelect',
        }
    });

    user_profiles.bootstrap();
    window.pfaff = user_profiles;

    layout = new UserManagement.Views.UserProfilesLayout();

    UserManagement.mainRegion.show(layout);

    var Controls = UserManagement.Views.UserProfilesCollection.Controls;

    pagination_top       = new CoursAvenue.Views.PaginationToolView({});
    pagination_bottom    = new CoursAvenue.Views.PaginationToolView({});
    bulk_action_controls = new Controls.BulkActionControls.BulkActionControlsView({});

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

    layout.showWidget(bulk_action_controls)

    layout.master.show(user_profiles_collection_view);

});

$(document).ready(function() {
    /* we only want the filteredsearch on the search page */
    if (UserManagement.detectRoot()) {
        UserManagement.start({});
    }

});
