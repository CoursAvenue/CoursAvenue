/* a view for presenting a backbone.paginator collection, and for presenting and handling
 * its pagination UI element */

UserManagement.module('Views.UserProfilesCollection', function(Module, App, Backbone, Marionette, $, _) {

    Module.UserProfilesCollectionView = CoursAvenue.Views.PaginatedCollectionView.extend({
        template: Module.templateDirname() + 'user_profiles_collection_view',
        itemView: Module.UserProfile.UserProfileView,
        itemViewContainer: '[data-type=container]',
        className: 'relative',


        initialize: function () {
            /* myserious forces are preventing me from using the events
            * hash for these, for some strange reason */
            this.$el.on('click', '[data-behavior=cancel]', _.bind(function () {
                this.itemviewCancel();
            }, this));

            this.$el.on('click', '[data-behavior=commit]', _.bind(function () {
                this.itemviewCommit();
            }, this));

            this.$el.on('click', '[data-behavior=select-all]', _.bind(function () {
                this.selectAll();
            }, this));

            this.$el.on('click', '[data-behavior=rotate]', _.bind(function () {
                this.rotateSelected();
            }, this));

            this.groups = {
                selected: {} /* map by view.cid */
            }
        },

        ui: {
            '$commit_buttons': '.additional-actions',
            '$cancel': '[data-behavior=cancel]',
            '$commit': '[data-behavior=commit]',
            '$select_all': '[data-behavior=select-all]',
            '$rotate': '[data-behavior=rotate]'
        },

        itemviewCancel: function (e) {
            if (!this.currently_editing) {
                return;
            }

            this.currently_editing.finishEditing({ restore: true, source: "button" });
        },

        itemviewCommit: function () {
            if (!this.currently_editing) {
                return;
            }

            this.currently_editing.finishEditing({ restore: false, source: "button" });
        },

        selectAll: function () {
            var self = this;
            var deselect = this.ui.$select_all.data().deselect;

            this.children.each(function (view) {
                if (deselect) {
                    if (self.groups.selected[view.cid]) {
                        view.ui.$checkbox.click();
                    }
                } else {
                    if (!self.groups.selected[view.cid]) {
                        view.ui.$checkbox.click();
                    }
                }
            });

            this.ui.$select_all.find('i').toggleClass('fa-check fa-times');
            this.ui.$select_all.data('deselect', !deselect);
        },

        onItemviewAddToSelected: function (view) {
            if (this.groups.selected[view.cid]) {
                delete this.groups.selected[view.cid];
            } else {
                this.groups.selected[view.cid] = view;
            }
        },

        rotateSelected: function () {
            _.each(this.groups.selected, function (view, cid) {
                view.$el.toggleClass("flipped unflipped");
            });
        },

        onItemviewToggleEditing: function (view, data) {
            var origin   = view.$el.position();
            var target   = origin.top + parseInt(view.$el.height() / 2, 10);
            var offset   = parseInt(this.ui.$commit_buttons.height() / 2, 10);
            var right    = parseInt(this.ui.$commit_buttons.width(), 10);

            this.ui.$commit_buttons
                .animate({ 'z-index': -1 }, { duration: 0 }) /* move to back */
                .animate({ right: 0 });                      /* slide closed */

            if (!data || !data.blur) {
                this.ui.$commit_buttons
                    .animate({ top: target - offset }, { duration: 0 }) /* move into position */
                    .animate({ right: -(right + 10) })                  /* slide open */
                    .animate({ 'z-index': 0 }, { duration: 0 });        /* bring to front */
            }

            this.currently_editing = view;
        },

        /* forward events with only the necessary data */
        onItemviewHighlighted: function (view, data) {
            this.trigger('user_profiles:itemview:highlighted', data);
        },

        onItemviewUnhighlighted: function (view, data) {
            this.trigger('user_profiles:itemview:unhighlighted', data);
        },

        onItemviewCourseFocus: function (view, data) {
            this.trigger('user_profiles:itemview:peacock', data);
        },

        /* when rendering each collection item, we might want to
         * pass in some info from the paginator_ui or something
         * if do we would do it here */
        /* remember that itemViews are constructed and destroyed more often
        * than the corresponding models */
        itemViewOptions: function(model, index) {

            return { };
        },

        /* TODO we will need a method like this at some point */
        findItemView: function (data) {
            /* find the first place that has any locations that match the given criteria */

            /* announce the view we found */
            this.trigger('user_profiles:itemview:found', itemview);
            this.scrollToView(itemview);
        },

        /* override inherited method */
        announcePaginatorUpdated: function () {
            if (this.collection.totalPages == undefined || this.collection.totalPages < 1) {
                return;
            }

            var data         = this.collection;

            var first_result = (data.currentPage - 1) * data.perPage + 1;

            this.trigger('user_profiles:updated');

            /* announce the pagination statistics for the current page */
            this.trigger('user_profiles:updated:pagination', {
                current_page:        data.currentPage,
                last_page:           data.totalPages,
                buttons:             this.buildPaginationButtons(data),
                previous_page_query: this.collection.previousQuery(),
                next_page_query:     this.collection.nextQuery(),
                sort:                this.collection.server_api.sort
            });
        }
    });
});

