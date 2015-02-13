
/* just a basic marionette view */
FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.PriceFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'price_filter_view',

        setup: function setup (data) {
            var $min_value = this.ui.$min_value,
                $max_value = this.ui.$max_value,
                range, step, min, max;

            if (data.is_open_for_trial) {
                this.ui.$price_type_radio.filter('[value=trials]').prop('checked', true);
            } else if (data.price_type == 'trainings') {
                this.ui.$price_type_radio.filter('[value=trainings]').prop('checked', true);
            }
            range = this.getRange();
            step  = this.getStep();

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
            this.showCorrectInputs();
            this.setButtonState();
        },

        ui: {
            '$price_type_radio_course'       : '#radio-course',
            '$price_type_radio_subscription' : '#radio-subscription',
            '$price_type_radio'              : '[name=price-type]',
            '$select'                        : 'select',
            '$slider'                        : '[data-behavior=slider]',
            '$min_value'                     : '[data-behavior="slider-min-value"]',
            '$max_value'                     : '[data-behavior="slider-max-value"]',
            '$trial_types_select'            : '[data-type="trial-types"]',
            '$clear_filter_button'           : '[data-behavior=clear-filter]',
            '$clearer'                       : '[data-el=clearer]',
            '$slider_wrapper'                : '[data-type=slider-wrapper]'

        },

        events: {
            'change @ui.$price_type_radio'   : 'showCorrectInputs',
            'change @ui.$trial_types_select' : 'showOrHideSlider',
            'change @ui.$slider'             : 'announce',
            'click @ui.$clear_filter_button' : 'clear'
        },

        showOrHideSlider: function showOrHideSlider () {
            if (this.ui.$trial_types_select.val() == 'free') {
                this.ui.$slider_wrapper.hide();
                this.announce();
            } else {
                this.ui.$slider_wrapper.show();
            }
        },
        /*
         * Show select box or slider regarding the option choosed
         */
        showCorrectInputs: function showCorrectInputs () {
            if (this.ui.$price_type_radio.filter(':checked').val() == 'trials') {
                this.ui.$slider_wrapper.hide();
                this.ui.$trial_types_select.show();
            } else if (this.ui.$price_type_radio.filter(':checked').val() == 'trainings') {
                this.ui.$slider_wrapper.show();
                this.ui.$trial_types_select.hide();
            }
            this.changeRange();
        },

        getRange: function getRange () {
            var checked_radio = this.ui.$price_type_radio.filter(':checked');
            if (checked_radio.length > 0) {
                return this.ui.$price_type_radio.filter(':checked').data('range').split(',');
            } else {
                return [0, 100]
            }
        },

        getStep: function getStep () {
            var checked_radio = this.ui.$price_type_radio.filter(':checked');
            if (checked_radio.length > 0) {
                return this.ui.$price_type_radio.filter(':checked').data('step');
            } else {
                return 5
            }
        },

        changeRange: function changeRange () {
            var range   = this.getRange(),
                step    = this.getStep();
            this.ui.$slider.noUiSlider({ range: range, start: range, step: step }, true);
            this.ui.$slider.parent().animate({backgroundColor: 'rgba(255, 255, 13, 0.35)'}, {duration: 300})
                                    .animate({backgroundColor: 'transparent'}, {duration: 300});
        },

        announce: function announce (e) {
            var slider_value = this.ui.$slider.val();
            if (this.ui.$price_type_radio.filter(':checked').val() == 'trials') {
                this.trigger("filter:price", {
                    'is_open_for_trial': true,
                    'price_type'       : null,
                    'min_price'        : null,
                    'max_price'        : null
                });
            } else {
                this.trigger("filter:price", {
                    'price_type': 'trainings',
                    'min_price' : slider_value[0],
                    'max_price' : slider_value[1]
                });
            }
            this.setButtonState();
        },//.debounce(GLOBAL.DEBOUNCE_DELAY),

        /*
         * Set the state of the button, wether or not there are filters or not
         */
        setButtonState: function setButtonState () {
            if (this.ui.$price_type_radio.filter(':checked').length > 0) {
                this.ui.$clearer.show();
                this.ui.$clear_filter_button.removeClass('btn--gray');
            }
        },

        // Clears all the given filters
        clear: function clear (filters) {
            this.ui.$clear_filter_button.addClass('btn--gray');
            this.ui.$clearer.hide();
            this.ui.$price_type_radio.prop('checked', false);
            this.ui.$trial_types_select.hide();
            this.ui.$slider.val([5, 200]);
            this.announce();
        }
    });
});
