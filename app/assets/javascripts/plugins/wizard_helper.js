/*
    Usage: When I hover a part of the layout, a wizard will appear on the right.
    Example
       <div data-behavior='wizard-helper' data-content='lorem ipsum...'>
           ...
       </div>
*/
;(function ( $, window, document, undefined ) {

    // Create the defaults once
    var pluginName = "wizardHelper",
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

    // Simple template of the wizard appearing on the right
    var wizard_template = "<div class='grid--full wizard-helper'><div class='grid__item two-twelfths text--center'><i data-toggle='popover' data-content=\"{{{ content }}}\" data-html='true' data-placement='bottom left' class='cursor-help fa-lightbulb-o blue-green wizard__icon'></i></div><div class='grid__item ten-twelfths wizard-helper__content text--muted'>{{{ content }}}</div></div>";
    Plugin.prototype = {
        template: Handlebars.compile(wizard_template),
        init: function() {
            this.$wizard_container = ( this.$element.data('container') ? $(this.$element.data('container')) : $('.wizard-container') );
            if (this.$wizard_container.length == 0) { return; }
            this.$content          = $(this.template({ content: this.$element.data('content') }));
            this.$wizard_container.append(this.$content);
            // Make the wizard appear on the right on mouseenter
            this.$element.mouseenter(function() {
                $('.wizard-helper').hide();
                var offset_top = this.$element.offset().top - this.$wizard_container.offset().top;
                if (offset_top < 0) { offset_top = 0; }

                // If the content goes too much at the bottom and increases the size of the body
                // We remove the difference from offset_top
                // if ($(document).height() < offset_top + this.$content.height()) {
                if (($(document).height() - this.$wizard_container.offset().top) < offset_top + this.$content.height()) {
                    offset_top = $(document).height() - this.$content.height() - this.$wizard_container.offset().top;
                }

                this.$content.css({
                    top:  offset_top
                })
                this.$content.show();
            }.bind(this));
            this.$element.on('wizard:close', this.hideContent.bind(this))
        },

        hideContent: function hideContent () {
            this.$content.fadeOut();
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
    var wizard_helper_initializer = function() {
        $('[data-behavior=wizard-helper]').wizardHelper();
    };
    COURSAVENUE.initialize_callbacks.push(wizard_helper_initializer);
});
