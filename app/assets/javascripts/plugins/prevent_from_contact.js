/*
    Usage: TODO
*/
;(function ( $, window, document, undefined ) {

    // Create the defaults once
    var pluginName = "preventFromContact",
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

        popup_div: "<div style='display: none;' class='soft-half alert alert--warning one-whole push-half--bottom'>Pas besoin d'envoyer vos coordonnées de contact, elles seront automatiquement transmises.</div>",
        init: function init () {
            _.bindAll(this, 'showMessageIfHasContact', 'hasContactInfo')
            this.$enclosing_form = this.$element.closest('form');
            this.$enclosing_form_submit_button = this.$enclosing_form.find('[type=submit]');
            this.$popup_div     = $(this.popup_div);
            this.$element.before(this.$popup_div);
            this.$element.keyup(this.showMessageIfHasContact);
            this.$enclosing_form.submit(function() {
                if (this.hasContactInfo()) {
                    this.$popup_div.slideDown().yellowFade();
                    return false;
                }
                return true;
            }.bind(this));
        },

        showMessageIfHasContact: function showMessageIfHasContact () {
            if (!this.popup_is_visible && this.hasContactInfo()) {
                this.$popup_div.slideDown();
                this.popup_is_visible = true;
                this.$enclosing_form_submit_button.attr('disabled', true);
            } else if (!this.hasContactInfo()) {
                this.popup_is_visible = false;
                this.$popup_div.slideUp();
                this.$enclosing_form_submit_button.attr('disabled', false);
            }
        },

        hasContactInfo: function hasContactInfo () {
            var text = this.$element.val()
            if (text.match(COURSAVENUE.constants.REGEX.email))        { return true; }
            if (text.match(COURSAVENUE.constants.REGEX.phone_number)) { return true; }
            if (_.select(COURSAVENUE.constants.REGEX.links, function(link_regex) {
                return text.match(link_regex);
            }).length > 0) { return true; }
            return false;
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
    var prevent_from_contact_initializer = function() {
        $('[data-behavior=prevent_from_contact]').preventFromContact();
    }
    COURSAVENUE.initialize_callbacks.push(prevent_from_contact_initializer);
});
