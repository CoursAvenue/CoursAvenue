/*
    Usage:
    <div data-behavior="image-input" class="input">
        <a data-trigger>Upload my file</a>
        <img> // Image preview
        <div data-progress class='progress-bar'>
        </div>
        <input type="file" />
    </div>
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
            this.$input_element    = this.$element.find('input[type=file]');
            this.$image_element    = this.$element.find('img');
            this.$trigger          = this.$element.find('[data-trigger]');
            this.$progress_bar_el  = this.$element.find('[data-progress]');
            this.attacheEvents();
        },

        attacheEvents: function() {
            var image_element   = this.$image_element,
                input_element   = this.$input_element,
                progress_bar_el = this.$progress_bar_el,
                inputChangeCallback;

            $(this.$trigger).click(function(){
                input_element.click();
            });
            this.$input_element.change(function(){
                if (COURSAVENUE.isImageValid(this.files[0])) {
                    if (this.files && this.files[0]) {
                        var reader = new FileReader();
                        reader.onload = function (e) {
                            $(image_element).attr('src', e.target.result);
                            $(image_element).show();
                            $(window).trigger('resize'); // To adapt fancy popups
                        }
                        reader.readAsDataURL(this.files[0]);
                    }
                } else {
                    COURSAVENUE.helperMethods.flash("Veuillez insérer une image au bon format", 'alert');
                    setTimeout(function(){
                        progress_bar_el.hide();
                    }, 5);
                    return false;
                }
            });
        },
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
        $('[data-behavior=image-input]').imageInput();
    };
    COURSAVENUE.initialize_callbacks.push(image_input_initializer);
});
