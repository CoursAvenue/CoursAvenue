
/* this file simply creates a top level Module in which Lib can live */

CoursAvenue = new Backbone.Marionette.Application({ slug: 'coursavenue' });

$(document).ready(function() {
    CoursAvenue.start({});
});

CoursAvenue.module('DataMining', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.addInitializer(function () {
        var fingerprint = new Fingerprint().get();

        FilteredSearch.mainRegion.on(function () {

        });
    });

}, undefined);
