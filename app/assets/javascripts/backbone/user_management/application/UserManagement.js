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
            'filter:search_term'          : 'filterQuery',
            'filter:tags'                 : 'filterQuery',

            'controls:save'               : 'commit',
            'controls:cancel'             : 'cancel',
            'controls:new'                : 'newUserProfile',
            'controls:select:all'         : 'selectAll',
            'controls:deselect:all'       : 'deselectAll',
            'controls:deep:select'        : 'deepSelect',
            'controls:clear:selected'     : 'clearSelected',
            'controls:add:tags'           : 'addTags',
            'controls:destroy:selected'   : 'destroySelected',

            'click [data-behavior=bulk-select]'  : 'bulkSelect',
            'click [data-sort]'                  : 'sort'
        }
    });

    user_profiles.bootstrap();
    window.pfaff = user_profiles;

    layout = new UserManagement.Views.UserProfilesLayout();


    UserManagement.mainRegion.show(layout);

    layout.on('controls:show:filters', layout.showFilters); // very nice!

    var Controls = UserManagement.Views.UserProfilesCollection.Controls;

    pagination_top       = new CoursAvenue.Views.PaginationToolView({});
    pagination_bottom    = new CoursAvenue.Views.PaginationToolView({});
    bulk_action_controls = new Controls.BulkActionControls.BulkActionControlsView({});
    tag_filter           = new UserManagement.Views.UserProfilesCollection.Filters.TagFilterView({});
    keyword_filter       = new UserManagement.Views.UserProfilesCollection.Filters.KeywordFilterView({});

    layout.showWidget(pagination_top, {
        events: {
            'user_profiles:updated:pagination': 'reset'
        },
        selector: '[data-type=pagination-top]'
    });

    layout.showWidget(pagination_bottom, {
        events: {
            'user_profiles:updated:pagination': 'reset',
        },
        selector: '[data-type=pagination-bottom]'
    });

    layout.showWidget(bulk_action_controls, {
        events: {
            'user_profiles:changed:editing'   : 'toggleEditManager',
            'user_profiles:update:selected'   : 'updateSelected',
            'user_profiles:updated:filters'   : 'showFilters'
        }
    });

    // TODO for now the showFilters method is living here
    // but later we will need to find a better place
    layout.showWidget(keyword_filter, {
        events: {
            'user_profiles:updated:keyword:filters'    : 'populateInput'
        }
    });

    layout.showWidget(tag_filter, {
        events: {
            'user_profiles:updated:tag:filters'    : 'buildTaggies'
        }
    });

    layout.master.show(user_profiles_collection_view);

});

$(document).ready(function() {
    /* we only want the filteredsearch on the search page */
    if (UserManagement.detectRoot()) {
        UserManagement.start({});
    }

});
