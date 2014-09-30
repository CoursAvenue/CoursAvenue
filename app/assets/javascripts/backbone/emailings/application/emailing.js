Emailing = new Backbone.Marionette.Application({ slug: 'emailings' });

Emailing.addRegions({
    mainRegion: '#emailings-region'
});

Emailing.addInitializer(function(options) {

    var bootstrap = window.coursavenue.bootstrap;

    var section_collection       = new Emailing.Models.SectionsCollection(bootstrap.models, bootstrap.options);
    var sections_collection_view = new Emailing.Views.Sections.SectionsCollectionView({
        collection: section_collection,
        events: {}
    });

    var layout           = new Emailing.Views.EmailingSectionsLayout();

    Emailing.mainRegion.show(layout);
    layout.master.show(sections_collection_view);
});

$(document).ready(function() {
    if (Emailing.detectRoot()) {
        Emailing.start({});
    }
});
