
/* just a basic marionette view */
FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.PriceFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'price_filter_view',

        initialize: function() {
            this.announce = _.debounce(this.announce, 800);
        },

        setup: function (data) {
            var $option, range, step,
                $min_value = this.ui.$min_value,
                $max_value = this.ui.$max_value;

            if (data.price_type === "") {
                $option = this.ui.$select.find('option').first();
            } else {
                $option = $('[value="' + data.price_type + '"]');
            }

            range = $option.data("range").split(',');
            step  = $option.data("step");

            if (data.min_price === "" && data.max_price === "") {
                min = range[0];
                max = range[1];
            } else {
                min = data.min_price;
                max = data.max_price;
            }
            this.ui.$slider.noUiSlider({
                range: range,
                start: [min, max],
                connect: true,
                handles: 2,
                margin: 2,
                step: step,
                serialization: {
                    to: [ [$min_value, 'text'], [$max_value, 'text']],
                    resolution: 1
                }
            });
            this.announceBreadcrumb();
        },

        ui: {
            '$select':    'select',
            '$slider':    '[data-behavior=slider]',
            '$min_value': '[data-behavior="slider-min-value"]',
            '$max_value': '[data-behavior="slider-max-value"]'
        },

        events: {
            'change @ui.$select': 'changeRange',
            'change @ui.$slider': 'announce'
        },

        changeRange: function() {
            var $option = $('[value="' + this.ui.$select.val() + '"]'),
                range   = $option.data('range').split(','),
                step    = $option.data('step');
            this.ui.$slider.noUiSlider({ range: range, start: range, step: step }, true);
            this.ui.$slider.parent().animate({backgroundColor: 'rgba(255, 255, 13, 0.35)'}, {duration: 300})
                                    .animate({backgroundColor: 'transparent'}, {duration: 300});
            this.announce();
        },

        announce: function (e) {
            var slider_value = this.ui.$slider.val();
            this.trigger("filter:price", {
                'price_type': this.ui.$select.val(),
                'min_price': slider_value[0],
                'max_price': slider_value[1],
            });
            this.announceBreadcrumb();
        },
        announceBreadcrumb: function() {
            if (this.ui.$select.val() === 'per_course' &&
                this.ui.$slider.val()[0] === '5' &&
                this.ui.$slider.val()[1] === '500') {
                this.trigger("filter:breadcrumb:remove", {target: 'price'});
            } else {
                this.trigger("filter:breadcrumb:add", {target: 'price'});
            }
        },

        // Clears all the given filters
        clear: function (filters) {
            this.ui.$select.val('per_course');
            this.ui.$slider.val([5, 500]);
            this.announce();
        }
    });
});
