/*
    Usage:
    .flash{data: {behavior: 'flash'}}
      message
*/
;(function ( $, window, document, undefined ) {

    // Create the defaults once
    var pluginName = "timeRange",
        defaults = {};

    // The actual plugin constructor
    function Plugin( element, options ) {
        this.element  = element;
        this.$element = $(element);

        // jQuery has an extend method that merges the
        // contents of two or more objects, storing the
        // result in the first object. The first object
        // is generally empty because we don't want to alter
        // the default options for future instances of the plugin
        this.options = $.extend( {}, defaults, options) ;

        this._defaults = defaults;
        this._name = pluginName;

        this.init();
    }

    Plugin.prototype = {

        init: function() {
            this.start_wrapper          = this.$element.find(this.$element.data('start-time-wrapper')).first();
            this.start_time_selects     = this.start_wrapper.find('select.time');
            this.end_wrapper            = this.$element.find(this.$element.data('end-time-wrapper')).first();
            this.end_time_selects       = this.end_wrapper.find('select.time');
            this.getHourAndMinSelect();
            this.attachEvents();
        },

        getHourAndMinSelect: function() {
            this.start_time_selects.each(function(index, select) {
                var $select = $(select);
                if ($select.attr('name').indexOf('4i') !== -1) {
                    this.start_time_hour_select = $select;
                } else if ($select.attr('name').indexOf('5i') !== -1) {
                    this.start_time_min_select = $select;
                }
            }.bind(this));

            this.end_time_selects.each(function(index, select) {
                var $select = $(select);
                if ($select.attr('name').indexOf('4i') !== -1) {
                    this.end_time_hour_select = $select;
                } else if ($select.attr('name').indexOf('5i') !== -1) {
                    this.end_time_min_select = $select;
                }
            }.bind(this));

        },

        attachEvents: function() {
            this.start_time_hour_select.change(function(event) {
                var start_hour_time = parseInt($(event.target).val());
                this.end_time_hour_select.val(start_hour_time + 1)
            }.bind(this));
        }
    };

    // A really lightweight plugin wrapper around the constructor,
    // preventing against multiple instantiations
    $.fn[pluginName] = function ( options ) {
        return this.each(function () {
            if (!$.data(this, "plugin_" + pluginName)) {
                $.data(this, "plugin_" + pluginName,
                new Plugin( this, options ));
            }
        });
    }

})( jQuery, window, document );

$(function() {
    var time_range_initializer = function() {
        $('[data-behavior=time-range]').each(function(index, el) {
            $(this).timeRange();
        });
    };
    GLOBAL.initialize_callbacks.push(time_range_initializer);
});
