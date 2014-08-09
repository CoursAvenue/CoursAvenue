/* OpenDoorsSearch extends FilteredSearch
 *
 * This is an experiment to see if a deep copy of an app will work */

OpenDoorsSearch = FilteredSearch.rebrand('open-doors-search', Routes.open_courses_path().replace('/', ''));

OpenDoorsSearch.addRegions({
    mainRegion: '#' + OpenDoorsSearch.slug
});

OpenDoorsSearch.addInitializer(function(options) {

    var bootstrap, structures, structures_view, layout, maps_view, $loader, clearEvent;

    bootstrap = window.coursavenue.bootstrap;

    // Create an instance of your class and populate with the models of your entire collection
    /* TODO so much repetition down there, should be able to specify a comma separated list of events
    *  to be handled by a single callback */
    structures      = new OpenDoorsSearch.Models.StructuresCollection(bootstrap.models, bootstrap.options);
    if ( !structures.server_api['course_types[]'] ) { structures.server_api['course_types[]'] = 'open_course' }
    if ( !structures.server_api['start_date'] )     { structures.server_api['start_date']     = '05/04/2014' }
    if ( !structures.server_api['end_date'] )       { structures.server_api['end_date']       = '06/04/2014' }
    if ( !structures.server_api['address_name'] )   { structures.server_api['address_name']   = 'Paris' }
    structures_view = new OpenDoorsSearch.Views.StructuresCollection.StructuresCollectionView({
        collection: structures,
        events: {
            'pagination:next':         'nextPage',
            'pagination:prev':         'prevPage',
            'pagination:page':         'goToPage',
            'filter:summary':          'filterQuery',
            'map:bounds':              'filterQuery',
            'filter:subject':          'filterQuery',
            'filter:level':            'filterQuery',
            'filter:audience':         'filterQuery',
            'filter:date':             'filterQuery',
            'filter:search_term':      'filterQuery',
            'map:marker:click':        'findItemView',
            'structures:updated':      'renderSlideshows'
        }
    });

    structures.bootstrap();

    /* set up the layouts */
    layout = new OpenDoorsSearch.Views.SearchWidgetsLayout();

    layout.on('paginator:updating', function(){
        $loader = $loader || $('[data-type="loader"]');
        $loader.slideDown();
    });

    layout.on('structures:updated', function(){
        $loader = $loader || $('[data-type="loader"]');
        $loader.slideUp();
    });

    // TODO the app loader lives outside of the layout, so
    // it felt weird to have this code inside the layout
    layout.on("show", function() {
        $("[data-type=app-loader]").fadeOut('slow');
    });

    var bounds       = structures.getLatLngBounds();
    /* TODO does the google map need a reference to the collection?
    *  I don't think so, and I don't remember why this is here */
    google_maps_view = new OpenDoorsSearch.Views.Map.GoogleMapsView({
        collection: structures,
        mapOptions: {
            center: new google.maps.LatLng(bounds.lat, bounds.lng)
        },
        infoBoxViewOptions: {
            infoBoxClearance: new google.maps.Size(30, 100)
        }
    });

    var FiltersModule = OpenDoorsSearch.Views.StructuresCollection.Filters;

    var subjects = new FilteredSearch.Models.SubjectsCollection(coursavenue.bootstrap.subjects);

    /* basic filters */
    results_summary           = new FiltersModule.ResultsSummaryView({});
    subject_filter            = new FiltersModule.SubjectFilterView({});
    keyword_filter            = new FiltersModule.Subjects.SubjectsCollectionView({ collection: subjects });
    location_filter           = new FiltersModule.LocationFilterView({});

    /* advanced filters */
    filter_breadcrumbs        = new FiltersModule.FilterBreadcrumbs.FilterBreadcrumbsView({});

    level_filter              = new FiltersModule.LevelFilterView({});
    audience_filter           = new FiltersModule.AudienceFilterView({});
    date_filter               = new FiltersModule.DateFilterView({});

    OpenDoorsSearch.mainRegion.show(layout);

    /* we can add a widget along with a callback to be used
    * for setup */
    layout.showWidget(google_maps_view, {
        events: {
            'paginator:updating':                'hideInfoWindow retireMarkers',
            'structures:childview:highlighted':   'exciteMarkers',
            'structures:childview:unhighlighted': 'exciteMarkers',
            'filter:update:map':                 'centerMap',
            'structures:childview:found':         'showInfoWindow',
            'structures:childview:peacock':       'togglePeacockingMarkers'
        }
    });

    /* TODO all these widgets have "dependencies", that is, they
     * can depend on the main widget for data. Let's make this
     * explicit so that the order of the 'showWidget' calls doesn't
     * matter */

    layout.showWidget(filter_breadcrumbs, {
        events: {
            'filter:breadcrumb:add':     'addBreadCrumb',
            'filter:breadcrumb:remove':  'removeBreadCrumb'
        }
    });

    layout.showWidget(keyword_filter);
    layout.showWidget(location_filter);
    layout.showWidget(subject_filter);
    layout.showWidget(results_summary);

    // TODO for now this is fine. Just add this
    // to any filter that implements clear
    layout.showWidget(level_filter,          { events: { 'breadcrumbs:clear:level':    'clear'} });
    layout.showWidget(audience_filter,       { events: { 'breadcrumbs:clear:audience': 'clear'} });
    layout.showWidget(date_filter,           { events: { 'breadcrumbs:clear:date':     'clear'} });

    layout.master.show(structures_view);

    if (GLOBAL.is_mobile) {
        $('[data-type="location-filter"]').appendTo($('#mobile-location-filter'));
    }
});

$(document).ready(function() {

    /* we only want the filteredsearch on the search page */
    if (OpenDoorsSearch.detectRoot()) {
        OpenDoorsSearch.start({});
    }

});
