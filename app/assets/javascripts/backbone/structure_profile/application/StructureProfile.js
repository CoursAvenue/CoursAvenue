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
        sticky_google_maps_view, places_collection, participation_request,
        participation_request_view, message_form_view, message;

    places_collection          = structure.get('places');

    sticky_google_maps_view    = new StructureProfile.Views.Map.StickyGoogleMapsView({
        collection:         places_collection,
        mapOptions:         { scrollwheel: false },
        infoBoxViewOptions: { infoBoxClearance: new google.maps.Size(0, 0) }
    });

    layout.render();

    if (bootstrap.meta.have_upcoming_plannings && !bootstrap.meta.is_sleeping) {
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
        message           = new StructureProfile.Models.Message({ structure: structure });
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

    layout.master.show(structure_view);
    /* --------------------------
     *         PRERENDER
     * -------------------------- */
    collection_that_has_to_be_loaded = { privates: false, lessons: false, trainings: false }
    var triggerPrerenderIfReady = function triggerPrerenderIfReady (collection_name) {
        collection_that_has_to_be_loaded[collection_name] = true;
        var everything_is_loaded = _.every(_.values(collection_that_has_to_be_loaded), function(value) {
            return value == true;
        });
        if (everything_is_loaded) { window.prerenderReady = true; }
    }
    structure.get('lessons')           .on('reset', function() { triggerPrerenderIfReady('lessons');   });
    structure.get('privates')          .on('reset', function() { triggerPrerenderIfReady('privates');  });
    structure.get('trainings')         .on('reset', function() { triggerPrerenderIfReady('trainings'); });

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
    }
});
