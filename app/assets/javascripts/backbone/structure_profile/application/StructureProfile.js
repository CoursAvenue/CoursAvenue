StructureProfile = new Backbone.Marionette.Application({ slug: 'structure-profile' });

StructureProfile.addRegions({
    mainRegion: '#' + StructureProfile.slug,
    mapContainer: '#google-maps-view'
});

StructureProfile.addInitializer(function(options) {
    var bootstrap      = window.coursavenue.bootstrap.structure,
        layout         = new StructureProfile.Views.StructureProfileLayout(),
        structure      = new FilteredSearch.Models.Structure(bootstrap, bootstrap.options),
        structure_view = new StructureProfile.Views.Structure.StructureView({
            model: structure,
            events: {
                'breadcrumbs:clear': 'refetchCourses',
                'summary:clicked'  : 'refetchCourses'
            }
        }),
        bounds         = window.coursavenue.bootstrap.center,
        google_maps_view, filter_breadcrumbs;

    window.pfaff = structure;

    google_maps_view = new StructureProfile.Views.Map.GoogleMapsView({
        collection: new Backbone.Collection(window.coursavenue.bootstrap.structure.places, { model: StructureProfile.Models.Place }),

        mapOptions: {
            center: new google.maps.LatLng(bounds.lat, bounds.lng)
        },
        infoBoxViewOptions: {
            infoBoxClearance: new google.maps.Size(0, 0)
        }
    });

    filter_breadcrumbs        = new FilteredSearch.Views.StructuresCollection.Filters.FilterBreadcrumbs.FilterBreadcrumbsView({
        template: StructureProfile.Views.Structure.templateDirname() + 'filter_breadcrumbs_view',
        fancy_breadcrumb_names: {
            'week_days'           : 'Date',
            'audience_ids'        : 'Public',
            'level_ids'           : 'Niveaux',
            'min_age_for_kids'    : 'Audience',
            'max_price'           : 'Prix',
            'min_price'           : 'Prix',
            'price_type'          : 'Prix',
            'max_age_for_kids'    : 'Audience',
            'trial_course_amount' : 'Cours d\'essai',
            'course_types'        : 'Type de Cours',
            'week_days'           : 'Date',
            'discount_types'      : 'Tarifs réduits',
            'start_date'          : 'Date',
            'end_date'            : 'Date',
            'start_hour'          : 'Date',
            'end_hour'            : 'Date',
        }
    });

    layout.render();
    layout.showWidget(google_maps_view, {
        events: {
            "course:mouse:enter": "exciteMarkers",
            "course:mouse:leave": "exciteMarkers"
        }
    });

    layout.showWidget(filter_breadcrumbs, {
        events: {
            'filter:breadcrumbs:add'  :  'addBreadCrumbs',
            'filter:breadcrumb:remove':  'removeBreadCrumb'
        }
    });

    layout.master.show(structure_view);
});

$(document).ready(function() {
    /* we only want the filteredsearch on the search page */
    if (StructureProfile.detectRoot()) {
        StructureProfile.start({});
    }

});
