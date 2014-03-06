
FilteredSearch.module('Views.StructuresCollection.Filters.Subjects', function(Module, App, Backbone, Marionette, $, _) {

    Module.SubjectView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'subject_view',
        pill: Handlebars.compile('<a class="inline-block very-soft hard--ends rounded--double f-decoration-not-underlined hl-orange pointer nowrap" data-subject={{slug}}>{{name}}</a>'),

        initialize: function () {
            _.bindAll(this, "renderPill");
        },

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

        modelEvents: {
            'change': 'modelChanged'
        },

        modelChanged: function (model) {
            _.each(model.get("grand_children"), this.renderPill);

        },

        renderPill: function renderPill (grand_child) {
            var data = {
                name: grand_child.name,
                slug: grand_child.slug
            };

            var pill = $(Marionette.Renderer.render(this.pill, data));

            pill.appendTo(this.$el);
        },

        announceSubject: function announceSubject (e) {
            var data = { name: $(e.target).text() };
            this.trigger("announced:subject", data);
        }

    });
});
