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
        sticky_google_maps_view, places_collection,
        certified_comments_collection_view, guestbook_collection_view, participation_request,
        participation_request_view, message_form_view, message;

    places_collection          = structure.get('places');

    sticky_google_maps_view    = new StructureProfile.Views.Map.StickyGoogleMapsView({
        collection:         places_collection,
        mapOptions:         { scrollwheel: false },
        infoBoxViewOptions: { infoBoxClearance: new google.maps.Size(0, 0) }
    });

    certified_comments_collection_view = new StructureProfile.Views.Structure.Comments.CertifiedCommentsCollectionView({
        collection: structure.get('certified_comments'),
        about     :  structure.get('about')
    });

    guestbook_collection_view = new StructureProfile.Views.Structure.Comments.GuestbookCollectionView({
        collection: structure.get('guestbook'),
        about     :  structure.get('about')
    });

    layout.render();

    if (bootstrap.meta.have_upcoming_plannings) {
        participation_request      = new StructureProfile.Models.ParticipationRequest({ structure: structure });
        participation_request_view = new StructureProfile.Views.ParticipationRequests.RequestFormView( {
          model: participation_request
        } );
        layout.showWidget(participation_request_view, {
            selector: '[data-type=contact-form]',
            events: {
                'planning:register'         : 'showRegistrationForm',
                'lessons:collection:reset'  : 'resetCourseCollection',
                'privates:collection:reset' : 'resetCourseCollection'
            }
        });
    } else {
        message      = new StructureProfile.Models.Message({ structure: structure });
        message_form_view = new StructureProfile.Views.Messages.MessageFormView( {
          model: message
        } );
        layout.showWidget(message_form_view, { selector: '[data-type=contact-form]' });
    }

    layout.showWidget(sticky_google_maps_view, {
        selector: '[data-type=sticky-map]',
        events: {
            'course:mouse:enter': 'exciteMarkers',
            'course:mouse:leave': 'unexciteMarkers',
            'place:mouse:enter' : 'exciteMarkers',
            'place:mouse:leave' : 'unexciteMarkers',
            'map:marker:click'  : 'showInfoWindow'
        }
    });

    layout.showWidget(certified_comments_collection_view);
    layout.showWidget(guestbook_collection_view);

    layout.master.show(structure_view);
    /* --------------------------
     *         PRERENDER
     * -------------------------- */
    collection_that_has_to_be_loaded = { privates: false, lessons: false, trainings: false, certified_comments: false, guestbook: false }
    var triggerPrerenderIfReady = function triggerPrerenderIfReady (collection_name) {
        collection_that_has_to_be_loaded[collection_name] = true;
        var everything_is_loaded = _.every(_.values(collection_that_has_to_be_loaded), function(value) {
            return value == true;
        });
        if (everything_is_loaded) { window.prerenderReady = true; }
    }
    structure.get('lessons')           .on('reset', function() { triggerPrerenderIfReady('lessons');            });
    structure.get('privates')          .on('reset', function() { triggerPrerenderIfReady('privates');           });
    structure.get('trainings')         .on('reset', function() { triggerPrerenderIfReady('trainings');          });
    structure.get('certified_comments').on('reset', function() { triggerPrerenderIfReady('certified_comments'); });
    structure.get('guestbook')         .on('reset', function() { triggerPrerenderIfReady('guestbook');          });

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
        // TODO: Track events somewhere else and differently.
        // $(document).on('facebook:initialized', function() {
        //     FB.Event.subscribe('edge.create', function(page_url) {
        //         if (page_url != 'https://www.facebook.com/CoursAvenue') {
        //             CoursAvenue.statistic.logStat(window.coursavenue.bootstrap.structure.id, 'action', { infos: 'facebook' });
        //         }
        //     });
        // });
        // // Create view for current structure only if not a current admin
        // // Create impressions for similar profiles
        // if (!window.coursavenue.bootstrap.current_pro_admin) {
        //     $('body').on('click', '[data-action=log-action]', function() {
        //         var infos = $(this).text().trim();
        //         if ($(this).data('action-info')) {
        //             infos = $(this).data('action-info');
        //         }
        //         CoursAvenue.statistic.logStat(window.coursavenue.bootstrap.structure.id, 'action', { infos: infos });
        //         if (CoursAvenue.isProduction()) {
        //             window._fbq.push(['track', '6016785958627', {'value':'0.00','currency':'EUR'}]);
        //             ga('send', 'event', 'Action', infos);
        //             goog_report_conversion();
        //         }
        //     });
        // }
    }
});
