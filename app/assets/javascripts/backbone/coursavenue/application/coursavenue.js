
/* this file simply creates a top level Module in which Lib can live */

CoursAvenue = new Backbone.Marionette.Application({ slug: 'coursavenue' });

$(document).ready(function() {
    CoursAvenue.start({});
});

CoursAvenue.module('DataMining', function(Module, App, Backbone, Marionette, $, _, Fingerprint, undefined) {

    Module.Visitor = Backbone.Model.extend({
        url: '/stuff'

    });

    Module.addInitializer(function () {
        var visitor = new Module.Visitor();

        visitor.set("fingerprint", new Fingerprint().get());

        $("form[data-gather]").on("submit", function (e) {
            visitor.set(this.id, $(this).serializeArray());

        });

        window.onbeforeunload = function (e) {
            visitor.save();
        }
    });

}, Fingerprint, undefined);
