/* just a basic marionette view */
FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {
    Views.StructureView = Backbone.Marionette.ItemView.extend({
        template: 'backbone/templates/structure_view',

        tagName: 'li',
        className: 'one-whole course-element',

        initialize: function(options) {
            if (options == undefined)         { return; }
            if (options.context == undefined) { return; }

            var subject = options.model;
            _.each(_.pairs(options.context), function(pair) {
                var key   = pair[0];
                var value = pair[1];

                subject.set(key, value);
            });
        }

    });
});
