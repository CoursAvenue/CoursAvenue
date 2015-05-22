/*
    Usage:
    <form data-behavior='live-form' remote="true">
      ...
    </form>
*/
;(function ( $, window, document, undefined ) {

    // Create the defaults once
    var pluginName = "liveForm",
        defaults = {
            live_form_attribute: true
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

    var template = '<p data-type="live-form-flash" class="soft-half--left bg-site-background hidden green nowrap absolute"><strong>{{text}}</strong></p>';
    Plugin.prototype = {

        template: Handlebars.compile(template),

        init: function init () {
            this.$form = this.$element;
            if (typeof(this.$element.data('live-form-attribute')) != 'undefined') { this.options.live_form_attribute = this.$element.data('live-form-attribute'); }
            if (this.options.live_form_attribute) {
                this.$form.append('<input type="hidden" name="live_form" value="true">');
            }
            this.$wizard_container = ( this.$element.data('flash-container') ? $(this.$element.data('flash-container')) : $('.wizard-container') );
            this.$form.find('textarea').keyup(this.submitForm.bind(this));
            this.$form.find('input, select').change(this.submitForm.bind(this));
        },

        /*
         * Create a flash in the wizard container telling 'Saving...'
         */
        flashSaving: function flashSaving () {
            this.$flash = $(this.template({ text: 'Enregistrement en cours...' }));
            this.offset_top = this.$element.offset().top - this.$wizard_container.offset().top;
            if (this.offset_top < 0) { this.offset_top = 0; }
            this.$flash.css({ top:  this.offset_top });
            $('.wizard-container').append(this.$flash);
            // First hide all flash if they exists
            $('[data-type="live-form-flash"]').hide();
            this.$flash.fadeIn();
        },
        /*
         * Removes the first flash that said 'Saving...' and replace it by 'Saved'
         */
        flashSaved: function flashSaved () {
            this.$flash.fadeOut();
            var $finished_flash = $(this.template({ text: 'Enregistré' }));
            $finished_flash.css({ top:  this.offset_top });
            $('.wizard-container').append($finished_flash);
            $finished_flash.fadeIn();
            setTimeout(function() {
                $finished_flash.fadeOut();
            }, 2500);
        },
        submitForm: function submitForm (event) {
            if (this.previous_value == event.currentTarget.value) { return; }
            this.flashSaving();
            this.$form.submit().on('ajax:complete', function() {
                this.flashSaved();
                this.previous_value = event.currentTarget.value;
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
    COURSAVENUE.initialize_callbacks.push(input_update_initializer);
});
