
FilteredSearch.module('Views.StructuresCollection.Filters.Subjects', function(Module, App, Backbone, Marionette, $, _) {

    var ACTIVE_CLASS = 'f-weight-bold';
    Module.SubjectChildrenView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'subject_children_view',

        // As all subjects are loaded by default, we hide them
        className: 'hidden flexbox bg-white',

        initialize: function initialize () {
            _.bindAll(this, 'fetchDone');
            // We don't use modelEvents because the current model is being changed by the subjects_collection_view
            this.on('fetch:done', this.fetchDone);
        },

        events: {
            'click [data-subject]'          : 'announceSubject',
            'mouseenter [data-behavior=tab]': 'showTab'
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
                this.$('.tab-pane').hide();
                // We show the first tab OR the first activated tab
                if (this.$('ul li.selected a').length > 0) {
                    this.$('ul li.selected').addClass('active');
                    this.$(this.$('ul li.selected').data('el')).show();
                } else {
                    this.$('ul li:first').addClass('active');
                    this.$(this.$('ul li:first').data('el')).show();
                }
            }
            this.activateButtons(this.current_subject_slug);
        },

        showTab: function showTab (event) {
            this.$('.tab-pane').hide();
            var $target = $(event.currentTarget);
            this.$('[data-type=tab-li]').removeClass('active');
            $target.closest('li').addClass('active');
            this.$($target.data('el')).show();
        },

        announceSubject: function announceSubject (event) {
            event.stopPropagation();
            var $currentTarget = $(event.currentTarget),
                data           = { subject_name: $currentTarget.text() };
            // If already activated, deactivate
            if ($currentTarget.hasClass(ACTIVE_CLASS)) {
                // if it's a child, deactivate itself but keep parent activated
                if ($currentTarget.data('depth') == '2') {
                    $currentTarget.removeClass(ACTIVE_CLASS);
                    _.extend(data, { root_subject_id: event.currentTarget.dataset.rootSubject,
                                     subject_id: event.currentTarget.dataset.parentSubject });
                } // else deactivate but keep parent activated
                else {
                    this.deactivateButtons();
                    _.extend(data, { root_subject_id: event.currentTarget.dataset.rootSubject,
                                     subject_id: event.currentTarget.dataset.rootSubject });
                }

            } else {
                this.activateButtons(event.currentTarget.dataset.value);
                _.extend(data, { root_subject_id: event.currentTarget.dataset.rootSubject,
                                 parent_subject_id: (event.currentTarget.dataset.parentSubject || event.currentTarget.dataset.value),
                                 subject_id: event.currentTarget.dataset.value });
            }
            this.trigger("filter:subject", data);
            this.current_subject_slug       = data.subject_id;
            this.selected_parent_subject_id = data.parent_subject_id;
            return false;
        },

        deactivateButtons: function deactivateButtons (event) {
            this.$('[data-subject]').removeClass(ACTIVE_CLASS);
            this.$('li.' + ACTIVE_CLASS).removeClass(ACTIVE_CLASS);
        },

        activateButtons: function activateButtons (subject_id) {
            this.$('[data-subject]').removeClass(ACTIVE_CLASS);
            var $currentTarget = this.$('[data-value="' + subject_id + '"]');
            $currentTarget.addClass(ACTIVE_CLASS);
            // Activate associated tab IF not a tab itself
            if ($currentTarget.data('behavior') != 'tab') {
                var tab_pane_id = $currentTarget.closest('.tab-pane').attr('id');
                this.$('[data-el="#' + tab_pane_id + '"]').addClass(ACTIVE_CLASS);
            }
        },


        /*
         * Here we set the flags of links we want to show in the HTML.
         * If we are filtered on "Danse", we won't put links to subject that root is not "Danse"
         * So on and so forth
         * We also check if the subject has more than 5 results (we know this info from Solr facets)
         */
        setShowHrefFlag: function setShowHrefFlag (subjects) {
            if (subjects.slug == window.coursavenue.bootstrap.selected_subject.root) {
                subjects.show_href = this.hasMoreThanFiveResults(subjects.slug);
                _.each(subjects.children, function(child_depth_1) {
                    if (window.coursavenue.bootstrap.selected_subject.depth == 0) {
                        child_depth_1.show_href = this.hasMoreThanFiveResults(child_depth_1.slug);
                        _.each(child_depth_1.children, function(child_depth_2) {
                            child_depth_2.show_href = this.hasMoreThanFiveResults(child_depth_2.slug);
                        }.bind(this));
                    } else if (window.coursavenue.bootstrap.selected_subject.depth == 1 &&
                                window.coursavenue.bootstrap.selected_subject.slug == child_depth_1.slug) {
                        child_depth_1.show_href = this.hasMoreThanFiveResults(child_depth_1.slug);
                        _.each(child_depth_1.children, function(child_depth_2) {
                            child_depth_2.show_href = this.hasMoreThanFiveResults(child_depth_2.slug);
                        }.bind(this));
                    }
                }.bind(this));
                return subjects;
            } else {
                return subjects;
            }
        },

        hasMoreThanFiveResults: function hasMoreThanFiveResults (subject_slug) {
            return (window.coursavenue.bootstrap.subject_slugs_with_more_than_five_results.indexOf(subject_slug) != -1)
        },

        serializeData: function serializeData () {
            var data = this.model.toJSON();
            this.setShowHrefFlag(data);
            return _.extend(data, {
                city_id                   : window.coursavenue.bootstrap.city_id,
                selected_slug             : this.current_subject_slug,
                selected_parent_subject_id: this.selected_parent_subject_id
            });
        }
    });
});
