
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

        events: {
            'click [data-subject]': 'announceSubject'
        },

        announceSubject: function announceSubject (e) {
            var data = { name: $(e.target).text() };
            this.trigger("announced:subject", data);
        }

    });
});
