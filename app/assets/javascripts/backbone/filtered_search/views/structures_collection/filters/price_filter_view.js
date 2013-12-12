
/* just a basic marionette view */
FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.PriceFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'price_filter_view',

        setup: function (data) {
            this.activateInput(data.price);
        },

        ui: {
            '$select': '[data-behavior=chosen]',
            '$slider': '[data-behavior=slider]'
        },

        events: {
            'change    @ui.$select':        'announce',
            'change    @ui.$slider':        'announce'
        },

        toggleSlider: function () {

        },

        announce: function (e) {
debugger
            var $option = $('[value="' + e.currentTarget.value + '"]'),
                range = $option.data("range").split(','),
                slider_value = this.ui.$slider.val().split(',');

            this.ui.$slider.noUiSlider({ range: range }, true);

//            this.trigger("filter:price", {
 //               'price_types': this.ui.$select.val(),
  //              'min_price': slider_value[0],
   //             'max_price': slider_value[1],
    //        });
        },

        activateInput: function () {

        }
    });
});
