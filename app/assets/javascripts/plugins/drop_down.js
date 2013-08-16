/*
    Usage:
    <input  data-behavior='address-picker'
            data-list='#address-list'
            data-lng='#address-lng'
            data-lat='#address-lat' />
*/
;(function ( $, window, document, undefined ) {

    // Create the defaults once
    var pluginName = "dropDown",
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
            // Access to this.element
            this.trigger        = this.$element;
            this.drop_down      = this.$element.find(this.$element.data('el'));
            this.position       = this.$element.data('position');
            this.$element.on('update:position', this.setPositionning.bind(this));
            this.setPositionning();
            this.attachEvents();
        },

        setPositionning: function() {
            if (this.position) {
                switch(this.position) {
                    case 'right':
                        this.drop_down.css({right: '0', left: 'auto'});
                        break;
                    case 'left':
                        this.drop_down.css({left: '0', right: 'auto'});
                        break;
                    case 'center':
                        var demi_trigger_width = this.trigger.outerWidth() / 2;
                        var demi_list_width    = this.drop_down.outerWidth() / 2;
                        var left_position      = demi_trigger_width - demi_list_width;
                        this.drop_down.css({left: left_position, right: 'auto'});
                        break;
                }
            }
        },
        attachEvents: function() {
            this.trigger.hover(
                // In
                function() {
                    this.drop_down.show();
                }.bind(this),
                // Out
                function() {
                    this.drop_down.hide();
                }.bind(this)
            );
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

// Initialize all input-update objects
$(function() {
    $('[data-behavior=drop-down]').each(function(el) {
        $(this).dropDown();
    });
});
