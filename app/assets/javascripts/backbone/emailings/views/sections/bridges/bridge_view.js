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
        },

        // @param collectionName - The name of the collection in our model (ex. images, subjects)
        // @param collectionId   - The name of the id attribute of our collection in our model (ex. media_id, subject_id)
        // @param collectionSet  - The function setting the our new value. (ex. setCurrentImage, setCurrentSubject)
        // TODO: Refactor `collection*` functions into one by passing a flag to know if next or prev.
        collectionNext: function collectionNext(collectionName, collectionId, collectionSet) {
          var collection = this.model.get(collectionName);
          var current    = _.find(collection, function(collectionItem) {
            return (collectionItem.id == this.model.get(collectionId));
          }.bind(this));

          var next = collection[collection.indexOf(current) + 1];
          collectionSet(next);
        },

        collectionPrev: function collectionPrev() {
          var collection = this.model.get(collectionName);
          var current    = _.find(collection, function(collectionItem) {
            return (collectionItem.id == this.model.get(collectionId));
          }.bind(this));

          var next = collection[collection.indexOf(current) - 1];
          collectionSet(next);
        },

        slideNext: function slideNext (event) {
            collectionNext('images', 'media_id', this.setCurrentImage);
            // var images = this.model.get('images');
            // var current   = _.find(images, function(image) {
            //     return (image.id == this.model.get('media_id'));
            // }.bind(this));
            //
            // var next = images[images.indexOf(current) + 1];
            // this.setCurrentImage(next);
        },

        slidePrev: function slideNext () {
            collectionPrev('images', 'media_id', this.setCurrentImage);
            // var images  = this.model.get('images');
            // var current = _.find(images, function(image) {
            //     return (image.id == this.model.get('media_id'));
            // }.bind(this));
            //
            // var prev = images[images.indexOf(current) - 1];
            // this.setCurrentImage(prev);
        },

        subjectNext : function subjectNext () {
            collectionNext('subjects', 'subject_id', this.setCurrentSubject);
            // var subjects = this.model.get('subjects');
            // var current  = _.find(subjects, function(subject) {
            //     return (subject.id == this.model.get('subject_id'));
            // }.bind(this));
            //
            // var next = subjects[subjects.indexOf(current) + 1];
            // this.setCurrentSubject(next);
        },

        subjectPrev : function subjectPrev () {
            collectionPrev('subjects', 'subject_id', this.setCurrentSubject);
            // var subjects = this.model.get('subjects');
            // var current  = _.find(subjects, function(subject) {
            //     return (subject.id == this.model.get('subject_id'));
            // }.bind(this));
            //
            // var prev = subjects[subjects.indexOf(current) - 1];
            // this.setCurrentSubject(prev);
        },

        setCurrentImage: function setCurrentImage (image) {
            if (image) {
                console.log(image);
                this.model.set( { media_url: image.url, media_id: image.id } );
            }
        },

        setCurrentSubject : function setCurrentSubject(subject) {
          if (subject) {
            console.log(subject);
            this.model.set( { subject_name: subject.name, subject_id: subject.id } );
          }
        }
    });
});

