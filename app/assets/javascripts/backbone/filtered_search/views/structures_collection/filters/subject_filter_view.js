FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    var ACTIVE_CLASS = 'btn--blue subject-active';

    Module.SubjectFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'subject_filter_view',

        setup: function (data) {
            this.activateButton(data.subject_id);
        },

        serializeData: function(data) {
            return { subjects: coursavenue.bootstrap.subjects };
        },

        events: {
            'click [data-type="button"]': 'announce'
        },

        announce: function (event, data) {
            if (event) {
                var subject_slug = event.currentTarget.getAttribute('data-value');
            } else {
                var subject_slug = this.$('.' + ACTIVE_CLASS + '[data-type="button"]').data('value');
            }
            if (this.$('[data-value=' + subject_slug + ']').hasClass(ACTIVE_CLASS)) {
                this.trigger("filter:subject", { 'subject_id': null });
                this.disabledButton(subject_slug);
            } else {
                this.trigger("filter:subject", { 'subject_id': subject_slug });
                this.activateButton(subject_slug);
            }
        },

        disabledButton: function(subject_slug) {
            this.$('[data-value=' + subject_slug + ']').removeClass(ACTIVE_CLASS);
        },

        activateButton: function(subject_slug) {
            this.$('[data-type="button"]').removeClass(ACTIVE_CLASS);
            this.$('[data-value=' + subject_slug + ']').addClass(ACTIVE_CLASS);
        },

        // Clears all the given filters
        clear: function (filters) {
            this.$('[data-type="button"]').removeClass(ACTIVE_CLASS);
            this.announce();
        }
    });
});
