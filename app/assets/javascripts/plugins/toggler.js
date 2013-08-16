/*
    Usage:
    Example
       <h5 data-behavior='toggleable' data-el='+ .search-panel-content'>
           Dates
           <i class='icon-caret-left'></i>
       </h5>
       <div class='hide search-panel-content'>
            ...
       </div>
*/
;(function ( $, window, document, undefined ) {

    // Create the defaults once
    var pluginName = "toggler",
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
            this.caret_icon = this.$element.find('i');
            this.toggled_el = this.$element.find(this.$element.data('el'));
            this.attachEvents();
        },

        attachEvents: function() {
            var is_hidden       = this.toggled_el.hasClass('hide');
            var height          = this.toggled_el.outerHeight();
            var padding_top     = this.toggled_el.css('padding-top');
            var padding_bottom  = this.toggled_el.css('padding-bottom');
            if (is_hidden) {
                this.toggled_el.css({
                    'height'        : 0,
                    'padding-top'   : 0,
                    'padding-bottom': 0
                });
                this.toggled_el.css('overflow', 'hidden');
                this.toggled_el.removeClass('hide');
            }
            this.$element.click(function() {
                if (is_hidden) {
                    this.caret_icon.addClass('icon-caret-down').removeClass('icon-caret-left');
                    this.toggled_el.animate({
                        'height'        : height,
                        'padding-top'   : padding_top,
                        'padding-bottom': padding_bottom
                    }, 400, 'easeOutCubic');
                } else {
                    this.caret_icon.removeClass('icon-caret-down').addClass('icon-caret-left');
                    this.toggled_el.css('overflow', 'hidden');
                    this.toggled_el.animate({
                        'height'        : 0,
                        'padding-top'   : 0,
                        'padding-bottom': 0
                    }, 400, 'easeOutCubic');
                }
                is_hidden = !is_hidden;
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
    $('[data-behavior=toggleable]').each(function(index, el) {
        $(this).toggler();
    });
});
