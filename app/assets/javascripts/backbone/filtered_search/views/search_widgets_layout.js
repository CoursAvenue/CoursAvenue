FilteredSearch.module('Views', function(Module, App, Backbone, Marionette, $, _) {

    Module.SearchWidgetsLayout = CoursAvenue.Views.EventLayout.extend({
        template: Module.templateDirname() + 'search_widgets_layout',
        className: 'relative',
        master_region_name: 'structures',

        ui: {
            $infinite_scroll: '[data-behavior=infinite-scroll]'
        },

        /* layout implements infinite scroll */
        onRender: function () {

            /* TODO if you load this page and you are already at the bottom, then
             * this will start loading the next page, and again, forever. That's
             * just if you are already way at the bottom when the page loads for
             * the first time, though. */
            this.ui.$infinite_scroll.scroll(this.infiniteScroll.bind(this));
        },

        infiniteScroll: function () {
            var $el = this.ui.$infinite_scroll;

            if ($el.scrollTop() + $el.innerHeight() >= $el[0].scrollHeight) {
                this.trigger("infinite:scroll");
            }
        },

        regions: {
            master: "#search-results",
        },

    });
});

