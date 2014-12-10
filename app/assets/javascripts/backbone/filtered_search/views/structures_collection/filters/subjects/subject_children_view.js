
FilteredSearch.module('Views.StructuresCollection.Filters.Subjects', function(Module, App, Backbone, Marionette, $, _) {

    var ACTIVE_CLASS = 'f-weight-bold';
    Module.SubjectChildrenView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'subject_children_view',

        initialize: function () {
            _.bindAll(this, 'fetchDone');
            // We don't use modelEvents because the current model is being changed by the subjects_collection_view
            this.on('fetch:done', this.fetchDone);
        },

        events: {
            'click [data-subject]'          : 'announceSubject',
            'mouseenter [data-toggle="tab"]': 'showTab'
        },

        ui: {
            '$buttons': '[data-type=button]'
        },

        fetchDone: function fetchDone (event) {
            this.render();
        },

        onRender: function onRender () {
            if (this.$('ul li').length > 0) {
                this.$('[data-loader]').hide();
                // We show the first tab OR the first activated tab
                if (this.$('ul li.selected a').length > 0) {
                    this.$('ul li.selected a').tab('show');
                } else {
                    this.$('ul li:first a').tab('show');
                }
            }
            this.activateButtons(this.current_subject_slug);
        },

        showTab: function showTab (event) {
            $(event.currentTarget).tab('show');
        },

        announceSubject: function announceSubject (event) {
            $.cookie('understood_how_subjects_worked', true);
            var $currentTarget = $(event.currentTarget);
            // If already activated, deactivate
            if ($currentTarget.hasClass(ACTIVE_CLASS)) {
                // if it's a child, deactivate itself but keep parent activated
                if ($currentTarget.data('depth') == '2') {
                    $currentTarget.removeClass(ACTIVE_CLASS);
                    var data = { root_subject_id: event.currentTarget.dataset.rootSubject,
                                 subject_id: event.currentTarget.dataset.parentSubject };
                    this.trigger("filter:subject", data);
                } // else deactivate but keep parent activated
                else {
                    this.deactivateButtons();
                    var data = { root_subject_id: event.currentTarget.dataset.rootSubject,
                                 subject_id: event.currentTarget.dataset.rootSubject };
                    this.trigger("filter:subject", data);
                }

            } else {
                this.activateButtons(event.currentTarget.dataset.value);
                var data = { root_subject_id: event.currentTarget.dataset.rootSubject,
                             parent_subject_id: (event.currentTarget.dataset.parentSubject || event.currentTarget.dataset.value),
                             subject_id: event.currentTarget.dataset.value };
                this.trigger("filter:subject", data);
            }
            this.current_subject_slug       = data.subject_id;
            this.selected_parent_subject_id = data.parent_subject_id;
        },

        deactivateButtons: function deactivateButtons (event) {
            this.$('[data-subject]').removeClass(ACTIVE_CLASS);
            this.$('li.' + ACTIVE_CLASS).removeClass(ACTIVE_CLASS);
        },

        activateButtons: function activateButtons (subject_id) {
            // var $currentTarget = $(event.currentTarget);
            this.$('[data-subject]').removeClass(ACTIVE_CLASS);
            var $currentTarget = this.$('[data-value="' + subject_id + '"]');
            $currentTarget.addClass(ACTIVE_CLASS);
            // Activate associated tab IF not a tab itself
            if ($currentTarget.data('toggle') != 'tab') {
                var tab_pane_id = $currentTarget.closest('.tab-pane').attr('id');
                $('[href="#' + tab_pane_id + '"]').addClass(ACTIVE_CLASS);
            }
        },

        serializeData: function serializeData () {
            var data = this.model.toJSON();
            return _.extend(data, {
                selected_slug             : this.current_subject_slug,
                selected_parent_subject_id: this.selected_parent_subject_id
            });
        }
    });
});
