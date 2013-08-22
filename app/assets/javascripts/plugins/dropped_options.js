/*
    Usage:
    TODO
*/
;(function ( $, window, document, undefined ) {

    // Create the defaults once
    var pluginName = "droppedOptions",
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
            this.title      = this.$element.find('.dropped-options-title');
            this.list       = this.title.find('+ul');
            this.titleText  = this.title.find('span');
            this.inputs     = this.$element.find('input');

            this.attachEvents();
            this.updateTitle();
        },

        attachEvents: function() {
            this.inputs.change(this.updateTitle.bind(this));
            this.title.click(function() {
                this.list.toggle();
            }.bind(this));
            $(document.body).click(function(event) {
                // Check if event.target is not contained in the associated elements to toggle
                // If the clicked element is not part of the toggled elements, we can hide them
                if (this.$element.find(event.target).length === 0) {
                    if (this.list.is(':visible')) {
                        this.list.hide();
                    }
                }
            }.bind(this));
        },
        updateTitle: function() {
            var titles = [];
            var checked_inputs = [];
            $.each(this.inputs, function(index, input) {
                if (input.checked === true) {
                    checked_inputs.push(input);
                }
            });
            $.each(checked_inputs, function(index, selected_input) {
                // Get associated label to
                titles.push($('label[for='+$(selected_input).attr('id')+']').text());
            });
            if (titles.length > 0) {
                this.titleText.text(titles.join(', '));
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
    $('[data-behavior=dropped-options]').each(function(index, el) {
        $(this).droppedOptions();
    });
});
