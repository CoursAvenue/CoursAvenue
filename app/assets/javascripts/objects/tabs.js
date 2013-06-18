(function() {
    'use strict';
    var objects = GLOBAL.namespace('GLOBAL.Objects');

    /*
     * Given an input element, will update a relative element.
     */

    objects.Tab = new Class({

        initialize: function(el) {
            this.el = el;
            this.tabs = el.getElements('li');
            this.tab_panes = $$(el.getChildren('li').map(function(li) {
                return '#' + li.get('data-el');
            }).join(','));
            this.tabs.addEvent('click', this.changeTab.bind(this))
        },

        changeTab: function(event) {
            if (!event.target.get('data-external')) {
                // Add active only on selected title (li)
                this.tabs.removeClass('active');
                event.target.addClass('active');

                // Add active only on selected content (tab-pane)
                this.tab_panes.removeClass('active');
                $(event.target.get('data-el')).addClass('active');
            }
        }

    });
})();

// Initialize all tabs objects
window.addEvent('domready', function() {
    $$('[data-behavior=tabs]').each(function(el) {
        new GLOBAL.Objects.Tab(el);
    });
});
