/*
    If one checkbox has value all and is checked, other will be unchecked.
    If other are checked, all value will uncheck
    Usage:
        %ul{ data: { behavior: 'checkbox-list' } }
          %li
            = check_box_tag '', '', data: {value: 'all'}
            = label_tag "...", 'All label'
          %li
            = check_box_tag 'time_slots[]', '...'
            = label_tag "..."

*/
;(function ( $, window, document, undefined ) {

    // Create the defaults once
    var pluginName = "checkboxList",
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
            this.inputs_except_all = this.$element.find('input:not([data-value=all])');
            this.$input_all        = this.$element.find('input[data-value=all]');
            if (!this.input_all) {
                this.$input_all        = this.$element.find('input').first();
                var all_inputs = this.$element.find('input');
                this.inputs_except_all = [];
                all_inputs.each(function(index, input) {
                    if(index > 0) { this.inputs_except_all.push(input); }
                }.bind(this));
                this.inputs_except_all = $(this.inputs_except_all);
            }
            this.input_all         = this.$input_all[0];

            this.$input_all.change(function(event){
                if (this.input_all.checked) {
                    this.uncheckAllInputs();
                }
            }.bind(this));

            this.inputs_except_all.change(function(event) {
                if (this.input_all.checked) {
                    this.input_all.checked = false;
                } else {
                    // If all inputs are unchecked, check the 'all' input
                    var filtered_checkboxes = this.inputs_except_all.filter(function(checkbox) {
                        return checkbox.checked != false
                    });
                    if (filtered_checkboxes.length === 0) {
                        this.input_all.checked = true;
                    }
                }

            }.bind(this));
        },

        /**
         * Will uncheck all inputs except the 'all' one
         */
        uncheckAllInputs: function() {
            this.inputs_except_all.map(function() {
                this.checked = false;
            });
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
    var checkbox_list_initializer = function(){
        $('[data-behavior=checkbox-list]').checkboxList();
    };
    COURSAVENUE.initialize_callbacks.push(checkbox_list_initializer);
});
