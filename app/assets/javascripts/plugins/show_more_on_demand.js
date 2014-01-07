/*
    Usage:
    %div{data: {behavior: 'show-more-on-demand'}}
        %div{data: {el: true, hidden: !item.persisted?}}
            some content
        %div{data: {el: true, hidden: !item.persisted?}}
            some other content
        %div{data: {trigger: true}} Add item

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

        init: function() {
            this.$trigger      = $(this.$element.find('[data-trigger]'));
            this.$items        = $(this.$element.find('[data-el]'));
            this.$hidden_items = $(this.$element.find('[data-el][data-hidden]'));
            this.$hidden_items.hide();
            this.showMoreItem(); // Show first empty item
            this.attachEvents();
        },

        attachEvents: function() {
            this.$trigger.click(function() {
                this.showMoreItem();
            }.bind(this));
        },

        showMoreItem: function() {
            var item_to_show = this.$hidden_items.first();
            item_to_show.removeAttr('data-hidden');
            item_to_show.show();
            // Update hidden items
            this.$hidden_items = $(this.$element.find('[data-el][data-hidden]'));
            // Remove trigger if there is no more item
            if (this.$hidden_items.length == 0) {
                this.$trigger.hide();
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
