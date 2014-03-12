 /*  TODO this needs to be set on the server side */
FilteredSearch = new Backbone.Marionette.Application({ slug: 'filtered-search', resource: 'etablissements' });

FilteredSearch.addRegions({
    mainRegion: '#' + FilteredSearch.slug
});

FilteredSearch.addInitializer(function(options) {
    var bootstrap, structures, structures_view, layout, maps_view, $loader, clearEvent;

    bootstrap = window.coursavenue.bootstrap;

    // Create an instance of your class and populate with the models of your entire collection
    /* TODO so much repetition down there, should be able to specify a comma separated list of events
    *  to be handled by a single callback */
    structures      = new FilteredSearch.Models.StructuresCollection(bootstrap.models, bootstrap.options);
    structures_view = new FilteredSearch.Views.StructuresCollection.StructuresCollectionView({
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
            'filter:course_type':      'filterQuery',
            'filter:discount':         'filterQuery',
            'filter:date':             'filterQuery',
            'filter:price':            'filterQuery',
            'filter:structure_type':   'filterQuery',
            'filter:payment_method':   'filterQuery',
            'filter:search_term':      'filterQuery',
            'filter:location':         'filterQuery',
            'filter:trial_course':     'filterQuery',
            'map:marker:focus':        'findItemView',
            'structures:updated':      'renderSlideshows'
        }
    });

    structures.bootstrap();
    window.pfaff = structures;

    /* set up the layouts */
    layout = new FilteredSearch.Views.SearchWidgetsLayout();

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
    google_maps_view = new FilteredSearch.Views.Map.GoogleMapsView({
        collection: structures,
        mapOptions: {
            center: new google.maps.LatLng(bounds.lat, bounds.lng)
        },
        infoBoxOptions: {
            infoBoxClearance: new google.maps.Size(30, 100)
        }
    });

    var FiltersModule = FilteredSearch.Views.StructuresCollection.Filters;

    var subjects = new FilteredSearch.Models.SubjectsCollection(coursavenue.bootstrap.subjects);

    /* basic filters */
    infinite_scroll_button    = new FiltersModule.InfiniteScrollButtonView({});
    results_summary           = new FiltersModule.ResultsSummaryView({});
    subject_filter            = new FiltersModule.SubjectFilterView({});
    keyword_filter            = new FiltersModule.Subjects.SubjectsCollectionView({ collection: subjects });
    location_filter           = new FiltersModule.LocationFilterView({});

    /* advanced filters */
    /* we pass in a dictionary defining what we want the titles of the breadcrumbs
     * to be*/
    filter_breadcrumbs        = new FiltersModule.FilterBreadcrumbs.FilterBreadcrumbsView({
        fancy_breadcrumb_names: {
            'level'           : 'Niveaux',
            'audience'        : 'Public',
            'course_type'     : 'Type de cours',
            'discount'        : 'Tarifs réduits',
            'date'            : 'Date',
            'price'           : 'Prix',
            'structure_types' : 'Type de structure',
            'payment_method'  : 'Financements acceptés',
            'trial_course'    : "Cours d'essai"
        }
    });

    level_filter              = new FiltersModule.LevelFilterView({});
    course_type_filter        = new FiltersModule.CourseTypeFilterView({});
    discount_filter           = new FiltersModule.DiscountFilterView({});
    audience_filter           = new FiltersModule.AudienceFilterView({});
    structure_type_filter     = new FiltersModule.StructureTypeFilterView({});
    payment_method_filter     = new FiltersModule.PaymentMethodFilterView({});
    date_filter               = new FiltersModule.DateFilterView({});
    price_filter              = new FiltersModule.PriceFilterView({});
    trial_course_filter       = new FiltersModule.TrialCourseFilterView({});

    FilteredSearch.mainRegion.show(layout);

    /* we can add a widget along with a callback to be used
    * for setup */
    layout.showWidget(google_maps_view, {
        events: {
            'paginator:updating':                'hideInfoWindow retireMarkers',
            'structures:itemview:highlighted':   'exciteMarkers',
            'structures:itemview:unhighlighted': 'exciteMarkers',
            'filter:update:map':                 'centerMap',
            'structures:itemview:found':         'showInfoWindow',
            'structures:itemview:peacock':       'togglePeacockingMarkers'
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

    layout.showWidget(keyword_filter, {
        events: {
            'filter:subject': 'blurIrrelevantSubjects',
            'structures:updated:query': 'updateQuery'
        }
    });
    layout.showWidget(location_filter);
    layout.showWidget(subject_filter);
    layout.showWidget(infinite_scroll_button, { events: { 'structures:updated:infinite_scroll': 'showOrHide' } });
    layout.showWidget(results_summary);

    // TODO for now this is fine. Just add this
    // to any filter that implements clear
    layout.showWidget(level_filter,          { events: { 'breadcrumbs:clear:level':           'clear'} });
    layout.showWidget(course_type_filter,    { events: { 'breadcrumbs:clear:course_type':     'clear'} });
    layout.showWidget(audience_filter,       { events: { 'breadcrumbs:clear:audience':        'clear'} });
    layout.showWidget(structure_type_filter, { events: { 'breadcrumbs:clear:structure_types': 'clear'} });
    layout.showWidget(payment_method_filter, { events: { 'breadcrumbs:clear:payment_method':  'clear'} });
    layout.showWidget(discount_filter,       { events: { 'breadcrumbs:clear:discount':        'clear'} });
    layout.showWidget(date_filter,           { events: { 'breadcrumbs:clear:date':            'clear'} });
    layout.showWidget(price_filter,          { events: { 'breadcrumbs:clear:price':           'clear'} });
    layout.showWidget(trial_course_filter,   { events: { 'breadcrumbs:clear:trial_course':    'clear'} });

    layout.master.show(structures_view);
});

$(document).ready(function() {
    /* we only want the filteredsearch on the search page */
    if (FilteredSearch.detectRoot()) {
        FilteredSearch.start({});
    }

});
