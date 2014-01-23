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
                 /* map by model id */
                 /* we map by model id so that we can still affect models that
                  * are not on the current page */
                selected: {},
            }

            this.poller = Backbone.Poller.get(this.collection, { delay: 5000 });
            this.poller.on('success', _.bind(function (collection) {
                if (collection.jobs !== "false") { return; }

                this.poller.stop();
            }, this));

            this.on("click:outside", this.onClickOutside);
            this.currently_editing = []; // a FIFO list of rows

        },

        ui: {
            '$commit_buttons' : '[data-behavior=commit-buttons]',
            '$cancel'         : '[data-behavior=cancel]',
            '$commit'         : '[data-behavior=commit]',
            '$select_all'     : '[data-behavior=select-all]',
            '$details'        : '[data-behavior=details]',
            '$add_tags'       : '[data-behavior=add-tags]',
        },

        /* Controls for canceling/committing edits */
        Cancel: function (e) {
            this.getCurrentlyEditing().finishEditing({ restore: true, source: "button" });
        },

        Commit: function () {
            this.getCurrentlyEditing().finishEditing({ restore: false, source: "button" });
        },

        selectAll: function () {
            this.collection.selectAll();
        },

        deselectAll: function () {
            this.collection.deselectAll();
        },

        deepSelect: function () {
            this.collection.deepSelect();
        },

        addTags: function (tags) {
            this.collection.bulkAddTags(tags);

            this.poller.start();
        },

        /* currently_editing may have more than one view. We are only
         * concerned with the top one. */
        getCurrentlyEditing: function () {
            var itemview = _.first(this.currently_editing);

            return (itemview)? itemview : { finishEditing: function () { /* NOOP */ } } ;
        },

        onRender: function () {

            // set the chevron for the pivot column
            var sort = this.collection.server_api.sort;
            var $pivot = this.$('[data-sort=' + sort + ']');
            $pivot.append("<span class='soft-half--left fa fa-chevron-down' data-type='order'></span>");
            $pivot.addClass("active");
        },

        onClickOutside: function () {
            this.getCurrentlyEditing().finishEditing({ restore: false });
        },

        /* when we click on a header: */
        /* find the current sorting pivot and remove a class from it
         *  add that class to the new one. Ensure that the disclosure triangle
         *  has the correct orientation. Then trigger filter:summary */
        /* TODO pull the chevron code out of here */
        /* TODO change the function name to something like "sortByColumn" */
        filter: function (e) {
            e.preventDefault();

            var $target = $(e.currentTarget);
            var $headers = $('[data-sort]');

            var sort = e.currentTarget.getAttribute('data-sort');
            var order = "desc";

            // if we are already sorting by this column, change the order
            if (sort === this.collection.server_api.sort) {
                var order = this.collection.server_api.order;
                order = (order === "desc")? "asc" : "desc";
            }

            // toggle the active header
            $headers.removeClass("active");
            $target.addClass("active");

            // remove the chevron from the active header
            var $triangle = $headers.find("[data-type=order]").remove();

            // change the direction of the chevron if necessary
            $triangle.removeClass();
            var chevron = (order === "desc" ? "soft-half--left fa fa-chevron-down" : "soft-half--left fa fa-chevron-up");
            $triangle.addClass(chevron);

            // add the chevron to the active header
            $target.append($triangle);

            this.trigger('filter:summary', { sort: sort, order: order });

            return false;
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
            if (is_editing && previous_itemview.$el !== undefined) {
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

        /* we should use this opportunity to create the next editable
        * profile if this was a create action, and to unset our
        * currently_editing view */
        onItemviewUpdateSuccess: function (itemView, response) {
            var action = response.action;

            if (action === "create") {
                this.newUserProfile();
            }
        },

        /* an item has been checked or unchecked */
        onItemviewAddToSelected: function (itemview) {
            var id = itemview.model.get("id");

            if (this.groups.selected[id]) {
                delete this.groups.selected[id];
            } else {
                this.groups.selected[id] = itemview.model;
            }
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

        /* when rendering each collection item, we might want to
         * pass in some info from the paginator_ui or something
         * if do we would do it here */
        /* remember that itemViews are constructed and destroyed more often
        * than the corresponding models */
        itemViewOptions: function(model, index) {
            var id = model.get("id");
            var tags_url = this.collection.url.basename + '/tags.json';

            /* we pass in the hash of layout events the view will respond to */
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

