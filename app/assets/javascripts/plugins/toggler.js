/*
    Usage:
    Example
       <h5 data-behavior='toggleable' data-el='+ .search-panel-content'>
           Dates
           <i class='icon-caret-down'></i>
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

        init: function init () {
            this.caret_icon = this.$element.find('i');
            this.getToggledEl();
            this.attachEvents();
        },

        getToggledEl: function getToggledEl () {
            var toggled_el = this.$element.find(this.$element.data('el'));
            if (toggled_el.length == 0) {
                this.toggled_el = $(this.$element.data('el'));
            } else {
                this.toggled_el = toggled_el;
            }
        },

        attachEvents: function attachEvents () {
            var is_hidden = this.toggled_el.hasClass('hide') || this.toggled_el.hasClass('hidden');
            if (is_hidden) {
                this.toggled_el.slideUp(0);
                this.toggled_el.removeClass('hide');
            }
            this.$element.click(function() {
                this.getToggledEl();
                if (is_hidden) {
                    this.caret_icon.addClass('icon-caret-down').removeClass('icon-caret-left');
                    this.toggled_el.slideDown();
                    $(window).resize();
                } else {
                    this.toggled_el.slideUp();
                    this.caret_icon.removeClass('icon-caret-down').addClass('icon-caret-left');
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
    var toggleable_initializer = function () {
        $('[data-behavior=toggleable]').each(function(index, el) {
            $(this).toggler();
        });
    };
    COURSAVENUE.initialize_callbacks.push(toggleable_initializer);
});
