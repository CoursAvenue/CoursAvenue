Emailing.module('Views.Sections.Bridges', function(Module, App, Backbone, Marionette, $, _) {
    Module.BridgeView = Backbone.Marionette.CompositeView.extend({
        template: Module.templateDirname() + 'bridge_view',

        tagName: 'td',
        attributes: {
            'width': '50%'
        },

        events: {
            'click [data-slide-next]': 'slideNext',
            'click [data-slide-prev]': 'slidePrev',
            'click [data-subj-next]' : 'subjectNext',
            'click [data-subj-prev]' : 'subjectPrev'
        },

        initialize: function initialize () {
            this.model.on('change', this.render);
            _.bindAll(this, 'setCurrentImage', 'setCurrentSubject');
        },

        /*
         * @param collectionName - The name of the collection in our model (ex. images, subjects)
         * @param collectionId   - The name of the id attribute of our collection in our model (ex. media_id, subject_id)
         * @param collectionSet  - The function setting the our new value. (ex. setCurrentImage, setCurrentSubject)
         * TODO: Refactor `collection*` functions into one by passing a flag to know if next or prev.
         */
        collectionNext: function collectionNext (collectionName, collectionId, collectionSet) {
            var collection = this.model.get(collectionName);
            var current    = _.find(collection, function(collectionItem) {
                return (collectionItem.id == this.model.get(collectionId));
            }.bind(this));

            var next = collection[collection.indexOf(current) + 1];
            collectionSet(next);
        },

        collectionPrev: function collectionPrev () {
            var collection = this.model.get(collectionName);
            var current    = _.find(collection, function(collectionItem) {
                return (collectionItem.id == this.model.get(collectionId));
            }.bind(this));

            var next = collection[collection.indexOf(current) - 1];
            collectionSet(next);
        },

        slideNext: function slideNext (event) {
            this.collectionNext('images', 'media_id', this.setCurrentImage);
        },

        slidePrev: function slideNext () {
            this.collectionPrev('images', 'media_id', this.setCurrentImage);
        },

        subjectNext : function subjectNext () {
            this.collectionNext('subjects', 'subject_id', this.setCurrentSubject);
        },

        subjectPrev : function subjectPrev () {
            this.collectionPrev('subjects', 'subject_id', this.setCurrentSubject);
        },

        setCurrentImage: function setCurrentImage (image) {
            if (image) {
                this.model.set( { media_url: image.url, media_id: image.id } );
            }
        },

        setCurrentSubject : function setCurrentSubject(subject) {
          if (subject) {
            this.model.set( { subject_name: subject.name, subject_id: subject.id } );
          }
        }
    });
});

