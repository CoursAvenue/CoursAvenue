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
            var certified_comments_collection = new Module.Comments.CertifiedCommentsCollection([], bootstrap_meta);
            var guestbook_collection          = new Module.Comments.GuestbookCommentsCollection([], bootstrap_meta);
            var message_thread_collection     = new Module.Community.MessageThreadCollection([], bootstrap_meta);

            certified_comments_collection.structure = this;
            guestbook_collection.structure          = this;
            message_thread_collection.structure     = this;

            this.set('certified_comments', certified_comments_collection);
            this.set('guestbook', guestbook_collection);
            this.set('message_threads', message_thread_collection);
        }
    });
});


