/*
    Usage:
    <a data-behavior='closer'
       data-el='#element-to-close'>X</a>
*/
;(function ( $, window, document, undefined ) {

    // Create the defaults once
    var pluginName = "closer",
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

        init: function init () {
            this.$element_to_close = $(this.$element.data('el'));
            switch (this.$element.data('effect')) {
                case 'left': this.$element_to_close.addClass('animate-to-left'); break;
                default: this.$element_to_close.slideUp();
            }
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
    $('body').on('click', '[data-behavior=closer]', function(event) {
        $(this).closer();
    });
});
