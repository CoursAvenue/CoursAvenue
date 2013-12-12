
/* just a basic marionette view */
FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.PriceFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'price_filter_view',

        setup: function (data) {
            var $option, range;

            if (data.price_type === "") {
                $option = this.ui.$select.find('option').first();
            } else {
                $option = $('[value="' + data.price_type + '"]');
            }

            range = $option.data("range").split(',');

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
                handles: 2,
                margin: 2,
                step: 1,
                serialization: {
                    to: [ $('value'), 'text']
                }
            });
        },

        ui: {
            '$select': 'select',
            '$slider': '[data-behavior=slider]'
        },

        events: {
            'change    @ui.$select':        'announce',
            'change    @ui.$slider':        'announce'
        },

        toggleSlider: function () {

        },

        announce: function (e) {
            var option = this.ui.$select.val(),
                $option = $('[value="' + this.ui.$select.val() + '"]'),
                range = $option.data('range').split(','),
                slider_value;

            this.ui.$slider.noUiSlider({ range: range }, true);
            slider_value = this.ui.$slider.val(),

            this.trigger("filter:price", {
                'price_type': this.ui.$select.val(),
                'min_price': slider_value[0],
                'max_price': slider_value[1],
            });
        }
    });
});
