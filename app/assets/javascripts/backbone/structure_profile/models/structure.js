/* just a basic backbone model */
StructureProfile.module('Models', function(Module, App, Backbone, Marionette, $, _) {

    Module.Structure = Backbone.Model.extend({

        initialize: function initialize(bootstrap, bootstrap_meta) {
            var relations = ['places', 'lessons', 'privates', 'trainings', 'teachers'],
                self      = this;
            bootstrap_meta = bootstrap_meta || {};
            // Creating relations
            // relation will be "places", "courses", etc.
            // And will be transformed in PlacesCollection
            _.map(relations, function(relation) {
                var collection       = new Module[_.capitalize(relation) + 'Collection'](bootstrap[relation], bootstrap_meta);
                collection.structure = this;
                this.set(relation, collection);
            }, this);
        }
    });
});


