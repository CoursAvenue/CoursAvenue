/* StructureProfileDiscoveryPass extends StructureProfile
 *
 * This is an experiment to see if a deep copy of an app will work */

StructureProfileDiscoveryPass = FilteredSearch.rebrand('structure-profile-discovery-pass', Routes.open_courses_path().replace('/', ''));

StructureProfileDiscoveryPass.addRegions({
    mainRegion: '#' + StructureProfileDiscoveryPass.slug
});

// StructureProfileDiscoveryPass.addInitializer(function(options) {
// });

$(document).ready(function() {

    /* we only want the filteredsearch on the search page */
    if (StructureProfileDiscoveryPass.detectRoot()) {
        StructureProfileDiscoveryPass.start({});
    }
});
