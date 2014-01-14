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
            /* TODO this is uuuuugly */
            this.$el.on('click', '[data-behavior=cancel]', _.bind(function () {
                this.itemviewCancel();
            }, this));

            this.$el.on('click', '[data-behavior=commit]', _.bind(function () {
                this.itemviewCommit();
            }, this));

            this.$el.on('click', '[data-behavior=select-all]', _.bind(function () {
                if (this.currently_editing) {
                    this.currently_editing.finishEditing({ restore: true, source: "button" });
                }
                this.showDetails("select-all");
                this.selectAll();
            }, this));

            this.$el.on('click', '[data-behavior=rotate]', _.bind(function () {
                if (this.currently_editing) {
                    this.currently_editing.finishEditing({ restore: true, source: "button" });
                }
                this.rotateSelected();
            }, this));

            this.$el.on('click', '[data-behavior=manage-tags]', _.bind(function () {
                if (this.currently_editing) {
                    this.currently_editing.finishEditing({ restore: true, source: "button" });
                }
                this.showDetails("manage-tags");
            }, this));

            this.$el.on('click', '[data-behavior=add-tags]', _.bind(function () {
                if (this.currently_editing) {
                    this.currently_editing.finishEditing({ restore: true, source: "button" });
                }
                this.commitAddTags();
            }, this));

            this.$el.on('click', '[data-behavior=uber-select]', _.bind(function () {
                if (this.currently_editing) {
                    this.currently_editing.finishEditing({ restore: true, source: "button" });
                }

                this.showDetails("select-all");
                this.groups.uber = true;

            }, this));

            this.groups = {
                selected: {} /* map by model id */,
            }

            this.poller = Backbone.Poller.get(this.collection, { delay: 5000 });
            this.poller.on('success', _.bind(function (model) {
                if (model.jobs !== "false") { return; }

                this.poller.stop();
            }, this));

        },

        ui: {
            '$commit_buttons': '.additional-actions',
            '$cancel'        : '[data-behavior=cancel]',
            '$commit'        : '[data-behavior=commit]',
            '$select_all'    : '[data-behavior=select-all]',
            '$rotate'        : '[data-behavior=rotate]',
            '$details'       : '[data-behavior=details]',
            '$add_tags'      : '[data-behavior=add-tags]'
        },

        commitAddTags: function () {
            var tags = this.ui.$details.find("[data-value=tag-names]").val();

            /* just set the new tag for now, replacing old tags */
            /* TODO we should really see tags as a set, and merge in the new elements */
            /* but right now tags is just a string */
            var models = _.inject(this.groups.selected, function (memo, view) {
                var model = view.model;
                // model.set({ tags: tags });
                memo.push(model);

                return memo;
            }, []);

            /* TODO of course, when we are done we should stop the timeout from being set */
            var self = this;
            var kontinue = true;

            /* TODO move this code into the collection itself, possibly
            *  by overriding the sync method */
            /* TODO the important difference here is that, this represents
            *  updating the whole collection, where normally a backbone collection
            *  would fire many requests to update itself... we want to do this in
            *  one bulk action */
            $.ajax({
                type: "POST",
                url: this.collection.url.basename + '/bulk.json',
                data: {
                    ids: (this.groups.uber) ? "all" : _.pluck(models, 'id'),
                    tags: tags
                }
            });

            /* TODO we want this to be idempotent: I should be able to start many times
            * without problem */
            this.poller.start();
        },

        showDetails: function (target) {
            var $manage_tags = this.$('[data-behavior=' + target + ']');
            var $details = this.$('[data-target=' + target + ']');

            $manage_tags.toggleClass("active");

            if ($manage_tags.hasClass("active")) {
                $details.slideDown();
            } else {
                $details.slideUp();
            }
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

        /* TODO select all is a little tricky.
         *
         * when I click select all, I mark child views by adding
         * them to or removing them from my array "groups.selected"
         *
         * when I arrive on a new page of results, I need to show
         * whether or not the results are selected by comparing
         * the current rows to groups.selected
         *
        * */
        selectAll: function (options) {
            var self = this;
            var deselect = this.ui.$select_all.data().deselect;

            this.children.each(function (view) {
                var id = view.model.get("id");

                if (deselect) {
                    self.groups.uber = false;

                    if (self.groups.selected[id]) {
                        view.ui.$checkbox.click();
                    }
                } else {
                    if (!self.groups.selected[id]) {
                        view.ui.$checkbox.click();
                    }
                }
            });

            this.ui.$select_all.find('i').toggleClass('fa-check fa-times');
            this.ui.$select_all.data('deselect', !deselect);
        },

        onItemviewAddToSelected: function (view) {
            var id = view.model.get("id");

            if (this.groups.selected[id]) {
                delete this.groups.selected[id];
            } else {
                this.groups.selected[id] = view; // <-- TODO why are we keeping the view? Why not a bool?
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
            var id = model.get("id");
            var tags_url = this.collection.url.basename + '/tags.json';

            return {
                checked: this.groups.selected[id]? true : false,
                tags_url: tags_url
            };
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

