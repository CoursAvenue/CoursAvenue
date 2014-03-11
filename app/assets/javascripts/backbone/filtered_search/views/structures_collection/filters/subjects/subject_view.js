
FilteredSearch.module('Views.StructuresCollection.Filters.Subjects', function(Module, App, Backbone, Marionette, $, _) {

    Module.SubjectView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'subject_view',

        attributes: function () {
            var id = "tab-" + this.model.get("slug");
            var name = "tab-pane hard--top";
            if (this.options.is_first) {
                name = name + " active";
            }

            return {
                id: id,
                class: name
            };
        },

        ui: {
            '$loader'       : '[data-loader]',
            '$empty_message': '[data-empty-message]'
        },

        events: {
            'click [data-subject]': 'announceSubject'
        },

        modelEvents: {
            'change': 'modelChanged',
            'fetch:start': 'fetchStart',
            'fetch:done': 'fetchDone'
        },

        fetchStart: function showLoader() {
            this.ui.$loader.show();
            this.ui.$empty_message.hide();
        },
        fetchDone: function showEmptyMessage () {
            this.ui.$loader.hide();
            if (this.model.get('grand_children').length == 0) {
                this.ui.$empty_message.show();
            }
        },

        modelChanged: function modelChanged (model) {
            this.render();
        },

        announceSubject: function announceSubject (e) {
            var data = { name: $(e.target).text() };
            this.trigger("announced:subject", data);
        }

    });
});
