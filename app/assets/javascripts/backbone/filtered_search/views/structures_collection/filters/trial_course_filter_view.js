FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

   var SHOW_TEXT = "Voir uniquement les cours d'essai gratuits";
   var HIDE_TEXT = "Cacher tous les cours d'essai gratuits";

    Module.TrialCourseFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'trial_course_filter_view',

        setup: function setup (data) {
            var self = this;
            if (data.is_open_for_trial) {
                this.ui.$button.prop('checked', true);
                this.ui.$button_text.text(HIDE_TEXT);
            }
        },

        ui: {
            '$button'     : 'input',
            '$button_text': '[data-type=button-text]'
        },

        events: {
            'change input': 'announce'
        },

        toggleClass: function toggleClass (argument) {
            if (this.ui.$button.prop('checked')) {
                this.ui.$button_text.text(HIDE_TEXT);
            } else {
                this.ui.$button_text.text(SHOW_TEXT);
            }
        },

        announce: function announce (e, data) {
            this.toggleClass()
            var checked = this.ui.$button.is(':checked');
            if (checked) {
                this.trigger("filter:trial_course", { 'is_open_for_trial': true });
            } else {
                this.trigger("filter:trial_course", { 'is_open_for_trial': null });
            }
        },

        clear: function clear () {
            this.ui.$button.prop("checked", false);
            this.ui.$button_text.text(SHOW_TEXT);
            this.announce();
        }

    });
});
