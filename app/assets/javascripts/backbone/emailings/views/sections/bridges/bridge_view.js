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

        slideNext: function slideNext (event) {
            var images = this.model.get('images');
            var current   = _.find(images, function(image) {
                return (image.id == this.model.get('media_id'));
            }.bind(this));

            var next = images[images.indexOf(current) + 1];

            this.setCurrentImage(next);
        },

        slidePrev: function slideNext () {
            var images  = this.model.get('images');
            var current = _.find(images, function(image) {
                return (image.id == this.model.get('media_id'));
            }.bind(this));

            var prev = images[images.indexOf(current) - 1];

            this.setCurrentImage(prev);
        },

        subjectNext : function subjectNext () {
            var subjects = this.model.get('subjects');
            var current  = _.find(subjects, function(subject) {
                return (subject.id == this.model.get('subject_id'));
            }.bind(this));

            var next = subjects[subjects.indexOf(current) + 1];
            this.setCurrentSubject(next);
        },

        subjectPrev : function subjectPrev () {
            var subjects = this.model.get('subjects');
            var current  = _.find(subjects, function(subject) {
                return (subject.id == this.model.get('subject_id'));
            }.bind(this));

            var prev = subjects[subjects.indexOf(current) - 1];
            this.setCurrentSubject(prev);
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

