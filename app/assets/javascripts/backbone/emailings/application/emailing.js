Emailing = new Backbone.Marionette.Application({ slug: 'emailings' });

Emailing.addRegions({
    mainRegion: '#emailings-region'
});

Emailing.addInitializer(function(options) {

    var bootstrap = window.coursavenue.bootstrap;

    var emailing_section_collection       = new Emailing.Models.EmailingSectionsCollection(bootstrap.models, bootstrap.options);
    var emailing_sections_collection_view = new Emailing.Views.EmailingSectionsCollection.EmailingSectionsCollectionView({
        collection: emailing_section_collection,
        events: {}
    });


    var layout           = new Emailing.Views.EmailingSectionsLayout();


    Emailing.mainRegion.show(layout);
    layout.master.show(emailing_sections_collection_view);
});

$(document).ready(function() {
    if (Emailing.detectRoot()) {
        Emailing.start({});
    }
});
