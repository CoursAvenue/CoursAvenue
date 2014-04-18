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
    var wizard_template = "<div class='grid--full wizard-helper'><div class='grid__item two-twelfths text--center'><i class='fa fa-lightbulb-o blue wizard__icon'></i></div><div class='grid__item ten-twelfths text--muted'>{{{content}}}</div></div>";
    Plugin.prototype = {
        template: Handlebars.compile(wizard_template),
        init: function() {
            this.$content = $(this.template({ content: this.$element.data('content') }));
            $('.wizard-container').append(this.$content);
            // Make the wizard appear on the right on mouseenter
            this.$element.mouseenter(function() {
                $('.wizard-helper').hide();
                this.$content.css({
                    top:  this.$element.offset().top - $('.wizard-container').offset().top
                })
                this.$content.show();
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
    $('[data-behavior=wizard-helper]').wizardHelper();
});
