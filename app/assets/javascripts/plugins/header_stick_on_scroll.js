/*
    Usage:
    <input data-behavior='city-autocomplete'
           data-el='#input-to-complete'/>
*/
;(function ( $, window, document, undefined ) {

    // Create the defaults once
    var pluginName = "headerStickOnScroll",
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
            this.menu_scrolled_down = false;
            $(window).scroll(function() {
                if (!this.menu_scrolled_down && $(window).scrollTop() > 180 && parseInt(this.$element.css('top')) != 0 ) {
                    this.$element.animate({ 'top': '0' });
                    this.menu_scrolled_down = true;
                } else if ($(window).scrollTop() < 180 && parseInt(this.$element.css('top')) == 0 ) {
                    this.$element.animate({ 'top': '-100px' });
                    this.menu_scrolled_down = false;
                }
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
    var header_stick_on_scroll_initializer = function() {
        $('[data-behavior=header-stick-on-scroll]').headerStickOnScroll();
    };
    COURSAVENUE.initialize_callbacks.push(header_stick_on_scroll_initializer);
});
