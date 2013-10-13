/*
    Usage:
    .flash{data: {behavior: 'flash'}}
      message
*/
;(function ( $, window, document, undefined ) {

    // Create the defaults once
    var pluginName = "inputUpdater",
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
            this.to_update       = $(this.$element.data('element'));;
            this.type            = this.$element.attr('type');
            this.associated_form = this.to_update.parents('form');

            this.submitOnKeyPress();

            if (this.type === 'submit') {
                this.$element.click(function(event) {
                    this.to_update.click();
                }.bind(this));
            } else {
                this.$element.change(function(event) {
                    switch (this.type) {
                        case 'checkbox':
                            this.to_update[0].checked = this.element.checked;
                            break;
                        default:
                            this.to_update.val(this.$element.val());
                            break;
                    }
                }.bind(this));
            }
        },

        submitOnKeyPress: function() {
            this.$element.keypress(function(event) {
                this.$element.trigger('change'); // In case the input haven't been focused out
                if (event.keyCode === 13) { // Enter
                    this.associated_form.submit();
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
    var input_update_initializer = function() {
        $('[data-behavior=input-update]').inputUpdater();
    };
    GLOBAL.initialize_callbacks.push(input_update_initializer);
});
