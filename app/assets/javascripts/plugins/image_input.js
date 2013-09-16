/*
    Usage:
    <p data-behavior='flash'>Awesome flash</p>
*/
;(function ( $, window, document, undefined ) {

    // Create the defaults once
    var pluginName = "imageInput",
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
            this.input_element = this.$element.find('input');
            this.image_element = this.$element.find('img');
            this.link_element  = this.$element.find('a');
            this.attacheEvents();
        },

        attacheEvents: function() {
            var image_element = this.image_element,
                input_element = this.input_element;
            $(this.link_element).click(function(){
                input_element.click();
            });
            this.input_element.change(function(){
                if (this.files && this.files[0]) {
                    var reader = new FileReader();
                    reader.onload = function (e) {
                        $(image_element).attr('src', e.target.result);
                    }
                    reader.readAsDataURL(this.files[0]);
                }
            })
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
    var image_input_initializer = function() {
        $('[data-behavior=image-input]').each(function(index, el) {
            $(this).imageInput();
        });
    };
    GLOBAL.initialize_callbacks.push(image_input_initializer);
});
