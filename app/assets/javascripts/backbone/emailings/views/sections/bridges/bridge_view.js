Emailing.module('Views.Sections.Bridges', function(Module, App, Backbone, Marionette, $, _) {
    Module.BridgeView = Backbone.Marionette.CompositeView.extend({
        template: Module.templateDirname() + 'bridge_view',

        tagName: 'td',
        attributes: {
            'width': '33%'
        },

        events: {
            'click [data-slide-next]': 'slideNext',
            'click [data-slide-prev]': 'slidePrev'
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

        setCurrentImage: function setCurrentImage (image) {
            if (image) {
                console.log(image);
                this.model.set( { media_url: image.url, media_id: image.id } );
            }
        },
    });
});

