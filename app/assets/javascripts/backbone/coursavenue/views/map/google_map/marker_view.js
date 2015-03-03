
CoursAvenue.module('Views.Map.GoogleMap', function(Module, App, Backbone, Marionette, $, _) {

    /* The markers! Oh the markers.
    *  hover over a marker on the map. It will be highlighted.
    *  hover over a structure in the list. All associate markers will be highlighted and excited
    *  hover over a planning in the list. The associated marker will start peacocking. */
    /* TODO markers are probably not the only element that has multiple levels of "priority".
    *  this could probably be abstracted so that the calling class sends messages like,
    *
    *    marker.priorityCode('red'); // green, blue, yellow, orange, red
    *
    *  and the receiving class defines how it reacts to the different priorities. For example,
    *  marker would have 'blue', 'green', 'yellow', and 'red' defined as:
    *
    *   blue: nothing, no highlight
    *   green: highlighted (class 'active')
    *   yellow: same as green + single bounce
    *   red: same as green + continuous bounce
    *
    *  Other classes would expose similar semantics, but implement their behaviour differently
    * */
    Module.MarkerView = Backbone.GoogleMaps.RichMarkerView.extend({
        template: '',

        // constructor: function (options) {
        initialize: function initialize (options) {
            // Merging options
            this.options = (options || {});
            /* TODO this setup should be done in the constructor, in the library, in another repo far, far away */
            this.$el = $(Marionette.Renderer.render(CoursAvenue.Views.Map.GoogleMap.templateDirname() + 'marker_view'));
            this.overlayOptions.content = this.$el[0];

            /* apparently the only way to get this done */
            this.$el.on('click', _.bind(this.markerClicked, this));
            this.bounce     = _.debounce(this.bounce, 300);
            this.bounceOnce = _.debounce(this.bounceOnce, 300);
        },

        mapEvents: {
            'click'    : 'showInfoBox',
            'mouseover': 'highlight',
            'mouseout' :  'unhighlight'
        },

        markerClicked: function markerClicked (e) {
            this.trigger('click', e);
            e.stopPropagation();
        },

        /* a highlighted marker needs to be different from the rest */
        unhighlight: function unhighlight () {
            if (!this.select_lock) {
                this.$el.removeClass('active');
            }
        },

        /* a highlighted marker needs to be different from the rest */
        highlight: function highlight (parameters) {
            parameters = parameters || { show_info_box: false, unhighlight_all: true };
            if (parameters.show_info_box)   { this.trigger('hovered', { model: this.model }); }
            if (parameters.unhighlight_all) { this.trigger('unhighlight:all'); }
            if (!this.select_lock) {
                this.$el.addClass('active');
            }
        },

        isHighlighted: function isHighlighted () {
            return this.$el.hasClass('active');
        },

        /* an excited marker needs to be more than just highlighted */
        excite: function excite () {
            this.bounceOnce();
        },

        /* cancel an animation in progress */
        calm: function calm () {
            this.$el.finish();
        },

        /* a marker that should be continuously excited is peacocking */
        startPeacocking: function startPeacocking () {
            this.is_peacocking = true;
            this.bounce();
        },

        stopPeacocking: function stopPeacocking () {
            this.is_peacocking = false;
            this.$el.finish();
        },

        bounceOnce: function bounceOnce () {
            var self = this,
                old_top = parseInt(this.$el.css('top'), 10),
                crest = old_top - 30;

            this.$el.finish().animate({ top: crest }, 200, 'easeOutQuint', function (event) {
                self.$el.finish().animate({ top: old_top }, 400, 'easeOutBounce');
            });
        },

        bounce: function bounce () {
            if (! this.is_peacocking) {
                return;
            }

            var self = this,
                old_top = parseInt(this.$el.css('top'), 10),
                crest = old_top - 30;

            this.$el.finish().animate({ top: crest }, 200, 'easeOutQuint', function () {
                self.$el.finish().animate({ top: old_top }, 400, 'easeOutBounce', _.bind(self.bounce, self));
            });
        }
    });
});
