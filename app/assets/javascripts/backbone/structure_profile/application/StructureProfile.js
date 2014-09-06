StructureProfile = new Backbone.Marionette.Application({ slug: 'structure-profile' });

StructureProfile.addRegions({
    mainRegion: '#' + StructureProfile.slug
});

StructureProfile.addInitializer(function(options) {
    var bootstrap      = window.coursavenue.bootstrap,
        layout         = new StructureProfile.Views.StructureProfileLayout(),
        structure      = new StructureProfile.Models.Structure(bootstrap.structure, bootstrap.meta),
        structure_view = new StructureProfile.Views.Structure.StructureView({
            model: structure
        }),
        google_maps_view, sticky_google_maps_view, filter_breadcrumbs, places_collection, places_list_view, comments_collection_view;

    places_collection = structure.get('places');
    message_form_view = new StructureProfile.Views.Messages.MessageFormView( { structure: structure } );
    google_maps_view  = new StructureProfile.Views.Map.GoogleMapsView({
        collection:         places_collection,
        infoBoxViewOptions: { infoBoxClearance: new google.maps.Size(0, 0) },
        mapOptions:         { scrollwheel: false },
        mapClass:           'google-map--medium'
    });

    sticky_google_maps_view  = new StructureProfile.Views.Map.GoogleMapsView({
        collection:         places_collection,
        sticky:             true,
        mapOptions:         { scrollwheel: false },
        infoBoxViewOptions: { infoBoxClearance: new google.maps.Size(0, 0) }
    });

    places_list_view         = new StructureProfile.Views.Structure.Places.PlacesCollectionView({ collection: places_collection });
    comments_collection_view = new StructureProfile.Views.Structure.Comments.CommentsCollectionView({
        collection: structure.get('comments'),
        about     :  structure.get('about')
    });

    filter_breadcrumbs = new FilteredSearch.Views.StructuresCollection.Filters.FilterBreadcrumbs.FilterBreadcrumbsView({
        template: StructureProfile.Views.Structure.templateDirname() + 'filter_breadcrumbs_view',
        fancy_breadcrumb_names: {
            'search_term'         : 'Mot clé',
            'subject_id'          : 'Discipline',
            'address_name'        : 'Lieux',
            'lat'                 : 'Lieux',
            'lng'                 : 'Lieux',
            'bbox_sw'             : 'Lieux',
            'bbox_ne'             : 'Lieux',
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

    layout.showWidget(message_form_view, {
        selector: '[data-type=contact-form]'
    });
    layout.showWidget(sticky_google_maps_view, {
        selector: '[data-type=sticky-map]',
        events: {
            'course:mouse:enter'       : 'exciteMarkers',
            'course:mouse:leave'       : 'unexciteMarkers',
            'place:mouse:enter'        : 'exciteMarkers',
            'place:mouse:leave'        : 'unexciteMarkers',
            'places:collection:updated': 'recenterMap',
            'map:marker:click'         : 'showInfoWindow'
        }
    });

    layout.showWidget(google_maps_view, {
        events: {
            'course:mouse:enter'       : 'exciteMarkers',
            'course:mouse:leave'       : 'unexciteMarkers',
            'place:mouse:enter'        : 'exciteMarkers',
            'place:mouse:leave'        : 'unexciteMarkers',
            'places:collection:updated': 'recenterMap',
            'map:marker:click'         : 'showInfoWindow'
        }
    });

    layout.showWidget(filter_breadcrumbs, {
        events: {
            'filter:breadcrumbs:add'  :  'addBreadCrumbs',
            'filter:breadcrumb:remove':  'removeBreadCrumb'
        }
    });

    layout.showWidget(places_list_view);
    layout.showWidget(comments_collection_view);

    layout.master.show(structure_view);

    if (window.location.hash.length > 0 && window.location.hash != '#_=_' && $(window.location.hash).length > 0) {
        $('[href=' + window.location.hash + ']').click();
        _.delay(function() {
            $.scrollTo($(window.location.hash), { duration: 500, offset: { top: -$('#media-grid').height() } });
        }, 500);
    }
});

$(document).ready(function() {
    /* we only want the current app on the search page */
    if (StructureProfile.detectRoot()) {
        StructureProfile.start({});
        // Create view for current structure only if not a current admin
        // Create impressions for similar profiles
        if (!window.coursavenue.bootstrap.current_pro_admin) {
            $('body').on('click', '[data-action=log-action]', function() {
                var infos = $(this).text().trim();
                if ($(this).data('action-info')) {
                    infos = $(this).data('action-info');
                }
                CoursAvenue.statistic.logStat(window.coursavenue.bootstrap.structure.id, 'action', { infos: infos });
                ga('send', 'event', 'Action', infos);
            });

            $.ajax({
                type: "POST",
                dataType: 'js',
                url: Routes.structure_statistics_path(window.coursavenue.bootstrap.structure.id),
                data: {
                    action_type: 'view',
                    fingerprint: $.cookie('fingerprint')
                }
            });
            var similar_profile_structure_ids = [];
            $('[data-similar-profile]').map(function(index, element) {
                similar_profile_structure_ids.push($(element).data('structure-id'));
            });
            $.ajax({
                type: "POST",
                dataType: 'js',
                url: Routes.statistics_path(),
                data: {
                    action_type: 'impression',
                    fingerprint: $.cookie('fingerprint'),
                    structure_ids: similar_profile_structure_ids
                }
            });
        }
    }
});
