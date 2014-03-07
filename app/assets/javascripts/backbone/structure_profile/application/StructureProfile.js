StructureProfile = new Backbone.Marionette.Application({ slug: 'structure-profile' });

StructureProfile.addRegions({
    mainRegion: '#' + StructureProfile.slug
});

StructureProfile.addInitializer(function(options) {
    var bootstrap = window.coursavenue.bootstrap,
        layout    = new StructureProfile.Views.StructureProfileLayout(),
        structure = new FilteredSearch.Models.Structure(bootstrap, bootstrap.options);

    window.pfaff = structure;

    StructureProfile.mainRegion.show(layout);
});

$(document).ready(function() {
    /* we only want the filteredsearch on the search page */
    if (StructureProfile.detectRoot()) {
        StructureProfile.start({});
    }

});
