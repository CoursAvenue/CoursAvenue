/*
    Usage:
    <form data-behavior='live-form' remote="true">
      ...
    </form>
*/
;(function ( $, window, document, undefined ) {

    // Create the defaults once
    var pluginName = "liveForm",
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

    var template = '<p data-type="live-form-flash" class="hidden green nowrap absolute"><strong>{{text}}</strong></p>';
    Plugin.prototype = {

        template: Handlebars.compile(template),

        init: function() {
            this.$form = this.$element;
            this.$form.append('<input type="hidden" name="live_form" value="true">');
            this.$wizard_container = ( this.$element.data('flash-container') ? $(this.$element.data('flash-container')) : $('.wizard-container') );
            this.$form.find('input, select, textarea').change(this.submitForm.bind(this));
        },

        submitForm: function() {
            var $flash = $(this.template({ text: 'Enregistrement en cours...' }));
            var offset_top = this.$element.offset().top - this.$wizard_container.offset().top;
            if (offset_top < 0) { offset_top = 0; }
            $flash.css({ top:  offset_top });
            $('.wizard-container').append($flash);
            // First hide all flash if they exists
            $('[data-type="live-form-flash"]').hide();
            $flash.fadeIn();
            this.$form.submit().on('ajax:success', function() {
                $flash.fadeOut();
                var $finished_flash = $(this.template({ text: 'Enregistré' }));
                $finished_flash.css({ top:  offset_top });
                $('.wizard-container').append($finished_flash);
                $finished_flash.fadeIn();
                setTimeout(function() {
                    $finished_flash.fadeOut();
                }, 2000);
            }.bind(this));
        }.debounce(500)
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
        $('[data-behavior=live-form]').liveForm();
    };
    GLOBAL.initialize_callbacks.push(input_update_initializer);
});
