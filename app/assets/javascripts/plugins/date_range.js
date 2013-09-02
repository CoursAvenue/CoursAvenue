/*
    Usage:
    <div date-behavior='date-range'
         data-start-date='#start-date-input'
         data-end-date='#end-date-input'>
        <input id='start-date'/>
        <input id='end-date'/>
    </div>
*/
;(function ( $, window, document, undefined ) {

    // Create the defaults once
    var pluginName = "dateRange",
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
            this.start_date  = this.$element.find(this.$element.data('start-date'));
            this.end_date    = this.$element.find(this.$element.data('end-date'));
            this.attachEvents();
        },

        attachEvents: function() {
            this.start_date.datepicker({
                format: 'dd/mm/yyyy',
                weekStart: 1,
                language: 'fr'
            });
            this.end_date.datepicker({
                format: 'dd/mm/yyyy',
                weekStart: 1,
                language: 'fr'
            });
            this.start_date.on('changeDate', function() {
                $(this).datepicker('hide');
            });
            var end_date = this.end_date;
            this.start_date.on('changeDate', function() {
                end_date.datepicker('update', this.value);
                end_date.datepicker('show');
            });
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
    $('[data-behavior=date-range]').each(function(index, el) {
        $(this).dateRange();
    });
});
