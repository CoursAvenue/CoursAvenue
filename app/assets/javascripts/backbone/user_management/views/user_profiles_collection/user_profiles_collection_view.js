/* a view for presenting a backbone.paginator collection, and for presenting and handling
 * its pagination UI element */

UserManagement.module('Views.UserProfilesCollection', function(Module, App, Backbone, Marionette, $, _) {

    Module.UserProfilesCollectionView = CoursAvenue.Views.PaginatedCollectionView.extend({
        template: Module.templateDirname() + 'user_profiles_collection_view',
        itemView: Module.UserProfile.UserProfileView,
        itemViewContainer: '[data-type=container]',
        className: 'relative',

        initialize: function () {
            this.groups = {
                selected: {} /* map by model id */,
            }

            this.poller = Backbone.Poller.get(this.collection, { delay: 5000 });
            this.poller.on('success', _.bind(function (collection) {
                if (collection.jobs !== "false") { return; }

                this.poller.stop();
            }, this));

            this.on("click:outside", this.flashUnfinishedEdits);
            this.currently_editing = []; // a FIFO list of rows

            $(window).scroll(this.stickyControls);
            this.sticky_home = -1;
        },

        /* TODO also, why does it sometimes stop docking? Reproduce this. */
        stickyControls: function () {
            var $control = $("[data-behavior=sticky-controls]");

            var scroll_top = $(window).scrollTop();
            var control_top = $control.offset().top;
            var fixed = $control.hasClass("sticky");

            if (!fixed && scroll_top >= control_top) {
                // we have scrolled past the controls

                var old_width = $control.width();
                var $placeholder = $control.clone()
                                      .css({ visibility: "hidden" })
                                      .attr("data-placeholder", "")
                                      .attr("data-behavior", "");

                // $placehold stays behind to hold the place
                $control.parent().prepend($placeholder);

                this.sticky_home = control_top;
                $control.addClass("sticky");
                $control.css({ width: old_width });
            } else if ( fixed && scroll_top < this.sticky_home) {
                // we have now scrolled back up, and are replacing the controls

                this.$("[data-placeholder]").remove();
                $control.removeClass("sticky");
                $control.css({ width: "" });
                this.sticky_home = -1;
            }
        },


        ui: {
            '$commit_buttons' : '[data-behavior=commit-buttons]',
            '$cancel'         : '[data-behavior=cancel]',
            '$commit'         : '[data-behavior=commit]',
            '$select_all'     : '[data-behavior=select-all]',
            '$details'        : '[data-behavior=details]',
            '$add_tags'       : '[data-behavior=add-tags]'
        },

        onRender: function () {

            var sort = this.collection.server_api.sort;
            var $pivot = this.$('[data-sort=' + sort + ']');
            $pivot.append("<span class='soft-half--left fa fa-chevron-down' data-type='order'></span>");
            $pivot.addClass("active");
        },

        /* when we click on a header: */
        /* find the current sorting pivot and remove a class from it
         *  add that class to the new one. Ensure that the disclosure triangle
         *  has the correct orientation. Then trigger filter:summary */
        filter: function (e) {
            e.preventDefault();

            var $target = $(e.currentTarget);
            var $headers = $('[data-sort]');

            var sort = e.currentTarget.getAttribute('data-sort');
            var order = "desc";

            if (sort === this.collection.server_api.sort) {
                var order = this.collection.server_api.order;
                order = (order === "desc")? "asc" : "desc";
            }

            $headers.removeClass("active");
            $target.addClass("active");

            var chevron = (order === "desc" ? "soft-half--left fa fa-chevron-down" : "soft-half--left fa fa-chevron-up");
            var $triangle = $headers.find("[data-type=order]").remove();

            $triangle.removeClass();
            $triangle.addClass(chevron);
            $target.append($triangle);

            this.trigger('filter:summary', { sort: sort, order: order });

            return false;
        },

        /* When we click outside, we want the row to change colour, to indicate
         * pending edits */
        flashUnfinishedEdits: function () {
            if (!this.getCurrentlyEditing()) {
                return;
            }

            // no edits? no problem!
            if (_.isEmpty(this.getCurrentlyEditing().edits)) {
                this.getCurrentlyEditing().finishEditing({ restore: false });
            } else {
                // there are pending edits, so mark the row unfinished
                this.getCurrentlyEditing().$el.addClass("unfinished");
            }
        },

        /* if we are clicking back inside an unfinished field
        * we should mark it as no longer unfinished. */
        onItemviewEditableClicked: function (row) {
            if (row.$el.hasClass("unfinished")) {
                row.$el.removeClass("unfinished");
            }
        },

        /* this method observes the value of "is_editing" on the
        * children views. If any child's is_editing property changes
        * this method will be called and:
        *   1. If the edit is ending, we shift off the currently editing view
        *   2. If the edit is starting, and there was already a currently editing view,
        *      we send the signal to finish the old edit, and we push on the
        *      new currently editing view
        *
        * In the second case, we have two kinds of "finishing" to do:
        *  1. We undo any changes that were made by the collection
        *  2. We allow the itemview a chance to finalize anything it needs to */
        onItemviewChangedEditing: function (itemview) {
            var previous_itemview = this.getCurrentlyEditing();
            var is_editing        = itemview.is_editing;

            // close any active view to make room for the new view
            if (is_editing && previous_itemview) {
                previous_itemview.$el.removeClass("unfinished"); // see note above
                previous_itemview.finishEditing({ restore: false });
            }

            // currently_editing editing is a FIFO list
            if (is_editing) {
                this.currently_editing.push(itemview);
            } else {
                this.currently_editing.shift(itemview);
            }
        },

        /* currently_editing may have more than one view. We are only
         * concerned with the top one. */
        getCurrentlyEditing: function () {
            return _.first(this.currently_editing);
        },

        bulkAddTags: function () {
            if (this.getCurrentlyEditing()) {
                this.getCurrentlyEditing().finishEditing({ restore: false, source: "button" });
            }

            var tags = this.ui.$details.find("[data-value=tag-names]").val();

            /* just set the new tag for now, replacing old tags */
            /* TODO we should really see tags as a set, and merge in the new elements */
            /* but right now tags is just a string */
            var models = _.inject(this.groups.selected, function (memo, view) {
                var model = view.model;
                memo.push(model);

                return memo;
            }, []);

            /* TODO of course, when we are done we should stop the timeout from being set */
            var self = this;

            /* TODO move this code into the collection itself, possibly
            *  by overriding the sync method */
            /* TODO the important difference here is that, this represents
            *  updating the whole collection, where normally a backbone collection
            *  would fire many requests to update itself... we want to do this in
            *  one bulk action */
            /* TODO the bulk index action should just act on _all_ the dudes,
            *  unless given an array of ids. */
            $.ajax({
                type: "POST",
                url: this.collection.url.basename + '/bulk.json',
                data: {
                    ids: (this.groups.uber) ? "all" : _.pluck(models, 'id'),
                    tags: tags
                }
            });

            this.poller.start();
        },

        newUserProfile: function () {
            var attributes = { first_name: "", email: "", last_name: "", tags: "", "new": true };
            this.collection.add(attributes, { at: 0 });
        },

        /* we should use this opportunity to create the next editable
        * profile if this was a create action, and to unset our
        * currently_editing view */
        onItemviewUpdateSuccess: function (itemView, response) {
            var action = response.action;

            if (action === "create") {
                this.newUserProfile();
            }

            /* TODO there is a deep evil lurking here:
            *  we are setting currently_editing to undefined,
            *  but there is no guarantee that the value of
            *  currently_editing at this moment is indeed
            *  the view that just updated. If it isn't, then
            *  we are invalidating the state of the app */
            /* TODO currently_editing should change when:
            *   - we hit ENTER or CANCEL to commit or rollback
            *   - we click another row
            *
            *  It needs to be independent of the events fired
            *  by the children */
        },

        onAfterItemAdded: function (itemView) {
            if (itemView.model.get("new")) {
                itemView.$(".editable-text").first().click();

                var table_top  = this.$el.offset().top;
                var scroll_top = $(window).scrollTop();

                if (scroll_top > table_top) {
                    $(window).scrollTo(table_top, "slow");
                }
            }
        },

        /* prompt the user to make sure they know how many user profiles they
        * are about to destroy */
        destroySelected: function () {
            if (this.getCurrentlyEditing()) {
                this.getCurrentlyEditing().finishEditing({ restore: false, source: "button" });
            }

            var models = _.inject(this.groups.selected, function (memo, view) {
                var model = view.model;
                memo.push(model);

                return memo;
            }, []);

            var self = this;
            _.each(models, function (model) {
                var id = model.get("id");

                model.destroy({
                    success: function (model) {
                        delete self.groups.selected[id];
                    }
                });
            });
        },

        /* TODO needs QA attention -- this needs to be part of a
         * DetailsControlView that we need to factor out of this class */
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
            if (!this.getCurrentlyEditing()) {
                return;
            }

            this.getCurrentlyEditing().finishEditing({ restore: false, source: "button" });
        },

        itemviewCommit: function () {
            if (!this.getCurrentlyEditing()) {
                return;
            }

            this.getCurrentlyEditing().finishEditing({ restore: false, source: "button" });
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
            if (this.getCurrentlyEditing()) {
                this.getCurrentlyEditing().finishEditing({ restore: false, source: "button" });
            }

            this.showDetails("select-all");

            var self = this;
            var deselect = this.ui.$select_all.data().deselect;

            this.children.each(function (view) {
                var id = view.model.get("id");

                if (deselect) {
                    self.groups.uber = false;

                    /* TODO we should set the checkbox value directly, rather
                    *  than clicking on the checkboxes. This is noticeably slower */
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

        deepSelect: function ( ){
            if (this.getCurrentlyEditing()) {
                this.getCurrentlyEditing().finishEditing({ restore: false, source: "button" });
            }

            this.showDetails("select-all");
            this.groups.uber = true;
        },

        onItemviewAddToSelected: function (view) {
            var id = view.model.get("id");

            if (this.groups.selected[id]) {
                delete this.groups.selected[id];
            } else {
                this.groups.selected[id] = view; // because we need the model TODO so why not just store the model?
            }
        },

        /* animate the controls and commit changes to the
         * currently_editing row */
        /* we are trying to close the old row because a new row has started editing */
        onItemviewStartEditing: function (view, data) {
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
                tags_url: tags_url,
                events: {
                    "tagbar:click"                : "startEditing",
                    "text:click"                  : "startEditing",
                    "field:click"                 : "announceEditableClicked",
                    "field:key:down"              : "finishEditing",
                    "field:edits"                 : "collectEdits",
                }
            };
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
        },

        manageTags: function () {
            if (this.getCurrentlyEditing()) {
                this.getCurrentlyEditing().finishEditing({ restore: false, source: "button" });
            }
            this.showDetails("manage-tags");
        },

        /* OVERRIDE */
        /* We are implementing appendHTML here so that we can both
        * append (normal) and prepend (when using "new") to the
        * table */
        appendHtml: function(compositeView, itemView, index){
            if (compositeView.isBuffering) {
                compositeView.elBuffer.appendChild(itemView.el);
            } else {
                // If we've already rendered the main collection, just
                // append the new items directly into the element.
                var $container = this.getItemViewContainer(compositeView);

                // prepend if this is the first model in the collection
                if (index === 0 ) {
                    itemView.$el.prependTo($container);
                } else {
                    $container.append(itemView.el);
                }
            }
        },
    });
});

