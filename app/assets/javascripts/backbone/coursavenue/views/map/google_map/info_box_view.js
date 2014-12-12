
CoursAvenue.module('Views.Map.GoogleMap', function(Module, App, Backbone, Marionette, $, _) {

    /* TODO break this out into its own file (it got big...) */
    Module.InfoBoxView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'info_box_view',

        constructor: function constructor (options) {
            Backbone.Marionette.ItemView.prototype.constructor.apply(this, arguments);

            var defaultOptions = {
                alignBottom: true,
                pixelOffset: new google.maps.Size(-95, -53),
                boxStyle: {
                    width: "200px"
                },
                enableEventPropagation: true,
                infoBoxClearance: new google.maps.Size(30, 100),
                closeBoxUrl: ""
            };

            options = _.extend(defaultOptions, options);
            this.infoBox = new InfoBox(options);
            google.maps.event.addListener(this.infoBox, 'closeclick', _.bind(this.closeClick, this));
        },

        onClose: function onClose () {
            this.infoBox.destroy();
        },

        closeClick: function closeClick () {
            this.trigger('closeClick');
        },

        open: function open (map, marker) {
            this.infoBox.open(map, marker);
        },

        setContent: function setContent (model) {
            this.model = model;
            this.render();

            this.infoBox.setContent(this.el);
        },

        getInfoBox: function getInfoBox () {
            return this.infoBox;
        }
    });
});
