/*
    Usage: TODO
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
            this.duration               = this.$element.find(this.$element.data('duration')).first();
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

        updateDuration: function() {
            if (!this.duration) { return; }
            var duration = 0
            duration += (parseInt(this.end_time_hour_select.val()) - parseInt(this.start_time_hour_select.val())) * 60;
            duration += parseInt(this.end_time_min_select.val()) - parseInt(this.start_time_min_select.val());
            this.duration.val(duration);
        },

        attachEvents: function() {
            this.start_time_hour_select.change(function(event) {
                var start_hour_time = parseInt($(event.target).val());
                if (start_hour_time >= parseInt(this.end_time_hour_select.val(), 10)) {
                    this.end_time_hour_select.val(start_hour_time + 1)
                }
                this.updateDuration.call(this);
            }.bind(this));
            this.end_time_hour_select.change(this.updateDuration.bind(this));
            this.end_time_min_select.change(this.updateDuration.bind(this));
            this.start_time_min_select.change(this.updateDuration.bind(this));
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
        $('[data-behavior=time-range]').timeRange();
    };
    COURSAVENUE.initialize_callbacks.push(time_range_initializer);
});
