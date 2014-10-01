/*
    Usage:
    %div{data: { behavior: 'show-more-on-demand' } }
        %div{ data: { el: true, hidden: !item.persisted? } }
            some content
        %div{ data: { el: true, hidden: !item.persisted? } }
            // First one will be removed
            // On click, will clear and hide the el
            %a{ data: { clear: true } }
                %i.fa.fa-times
            some other content
        %div{ data: { trigger: true } } Add item

*   Only one data-el that is hidden will be shown
*/
;(function ( $, window, document, undefined ) {

    // Create the defaults once
    var pluginName = "showMoreOnDemand",
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

        init: function init () {
            this.$trigger      = $(this.$element.find('[data-trigger]'));
            this.$items        = $(this.$element.find('[data-el]'));
            this.$clearers     = $(this.$element.find('[data-clear]'));
            this.$hidden_items = $(this.$element.find('[data-el][data-hidden]'));
            this.$hidden_items.hide();
            // Show first empty item if none is shown
            if (this.$items.first().is(':hidden')) {
                this.showMoreItem();
            }
            this.attachEvents();
        },

        attachEvents: function attachEvents () {
            this.$trigger.click(function() {
                this.showMoreItem();
            }.bind(this));
            this.$clearers.click(function(event) {
                this.clearAndHide(event);
            }.bind(this));
        },

        clearAndHide: function clearAndHide (event) {
            var $wrapping_el = $(event.currentTarget).closest('[data-el]');
            $wrapping_el.find('input, textarea').val('');
            // Don't set select value to '' if there is no blank options
            $wrapping_el.find('select').each(function() {
                if ($(this).find('option[value=""]').length == 1) {
                    $(this).val('');
                    $(this).removeAttr('value');
                } else {
                    $(this).val($(this).find('option').first().val());
                }
            });
            this.$hidden_items = $(this.$element.find('[data-el][data-hidden]'));
            if (this.$hidden_items.length < (this.$items.length - 1) ) {
                $wrapping_el.slideUp();
                // $wrapping_el.hide();
                $wrapping_el.attr('data-hidden', true);
            }
            // this.$trigger.show();
            this.$trigger.slideDown();
        },
        showMoreItem: function showMoreItem () {
            var item_to_show = this.$hidden_items.first();
            item_to_show.removeAttr('data-hidden');
            // item_to_show.show();
            item_to_show.slideDown();
            // Update hidden items
            this.$hidden_items = $(this.$element.find('[data-el][data-hidden]'));
            // Remove trigger if there is no more item
            if (this.$hidden_items.length == 0) {
                this.$trigger.slideUp();
                // this.$trigger.hide();
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
    $('[data-behavior=show-more-on-demand]').showMoreOnDemand();
});
