/*
    Usage:
    <p data-behavior='flash'>Awesome flash</p>
*/
;(function ( $, window, document, undefined ) {

    // Create the defaults once
    var pluginName = "flash",
        defaults = {
            delay             : 10000,
            animation_duration: 300
        };

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
            this.el_height = this.$element.outerHeight();
            this.$element.css('top', - this.el_height);
            this.showAndHide();
        },
        showAndHide: function() {
            this.show();
            setTimeout(function() {
                this.hide();
            }.bind(this), this.options.delay);
        },
        show: function() {
            this.$element.animate({
              top: 0
            }, this.options.animation_duration, "linear");
        },
        hide: function() {
            var el_height = this.el_height;
            this.$element.animate({
              top: -el_height
            }, this.options.animation_duration, "linear");
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
    var flash_initializer = function() {
        $('[data-behavior=flash]').flash();
    };
    COURSAVENUE.initialize_callbacks.push(flash_initializer);
});
