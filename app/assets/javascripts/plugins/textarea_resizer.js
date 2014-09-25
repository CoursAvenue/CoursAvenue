/*
    Usage: TODO
*/
;(function ( $, window, document, undefined ) {

    // Create the defaults once
    var pluginName = "textareaResizer",
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
            this.default_height       = this.$element.css('height') || '50px';
            this.default_scrollheight = parseInt(this.default_height);
            this.attachEvents();
            this.resize();
        },

        attachEvents: function() {
            this.$element.keyup(this.resize.bind(this));
        },

        resize: function(event) {
            var new_height = Math.max(this.element.scrollHeight, this.default_scrollheight) + "px";
            if (new_height !== this.element.style.height) {
                this.element.style.height = ""; /* Reset the height*/
                this.element.style.height = Math.max(this.element.scrollHeight, this.default_scrollheight) + "px";
                $(window).trigger('resize'); // To adapt fancy popups
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
    var autoresize_initializer = function() {
        $('[data-behavior=autoresize]').textareaResizer();
    }
    GLOBAL.initialize_callbacks.push(autoresize_initializer);
});
