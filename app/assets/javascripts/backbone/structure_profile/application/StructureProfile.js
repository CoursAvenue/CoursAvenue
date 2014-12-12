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
        google_maps_view, sticky_google_maps_view, places_collection, comments_collection_view;

    places_collection          = structure.get('places');
    message_form_view          = new StructureProfile.Views.Messages.MessageFormView( { structure: structure } );
    participation_request_view = new StructureProfile.Views.ParticipationRequests.RequestFormView( { structure: structure } );

    google_maps_view           = new StructureProfile.Views.Map.GoogleMapsView({
        collection:         places_collection,
        infoBoxViewOptions: { infoBoxClearance: new google.maps.Size(0, 0) },
        mapOptions:         { scrollwheel: false },
        mapClass:           'google-map--medium'
    });

    sticky_google_maps_view    = new StructureProfile.Views.Map.StickyGoogleMapsView({
        collection:         places_collection,
        mapOptions:         { scrollwheel: false },
        infoBoxViewOptions: { infoBoxClearance: new google.maps.Size(0, 0) }
    });

    comments_collection_view = new StructureProfile.Views.Structure.Comments.CommentsCollectionView({
        collection: structure.get('comments'),
        about     :  structure.get('about')
    });

    layout.render();

    layout.showWidget(participation_request_view, {
        selector: '[data-type=sticky-map-containerct-form]',
        events: {
            'planning:register' : 'showRegistrationForm'
        }
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

    layout.showWidget(comments_collection_view);

    layout.master.show(structure_view);

    if (window.location.hash.length > 0 && window.location.hash != '#_=_' && $(window.location.hash).length > 0) {
        try { // Prevent from bug when hash is corrupted
            $('[href=' + window.location.hash + ']').click();
            _.delay(function() {
                $.scrollTo($(window.location.hash), { duration: 500, offset: { top: -$('#media-grid').height() } });
            }, 500);
        } catch(err) {}
    }
});

$(document).ready(function() {
    /* we only want the current app on the search page */
    if (StructureProfile.detectRoot()) {
        StructureProfile.start({});
        $(document).on('facebook:initialized', function() {
            FB.Event.subscribe('edge.create', function(page_url) {
                if (page_url != 'https://www.facebook.com/CoursAvenue') {
                    CoursAvenue.statistic.logStat(window.coursavenue.bootstrap.structure.id, 'action', { infos: 'facebook' });
                }
            });
        });

        // Create view for current structure only if not a current admin
        // Create impressions for similar profiles
        if (!window.coursavenue.bootstrap.current_pro_admin) {
            $('body').on('click', '[data-action=log-action]', function() {
                var infos = $(this).text().trim();
                if ($(this).data('action-info')) {
                    infos = $(this).data('action-info');
                }
                CoursAvenue.statistic.logStat(window.coursavenue.bootstrap.structure.id, 'action', { infos: infos });
                if (CoursAvenue.isProduction()) {
                    window._fbq.push(['track', '6016785958627', {'value':'0.00','currency':'EUR'}]);
                    ga('send', 'event', 'Action', infos);
                    goog_report_conversion();
                }
            });
        }
    }
});
