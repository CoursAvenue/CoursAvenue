/* a view for presenting a backbone.paginator collection, and for presenting and handling
 * its pagination UI element */

UserManagement.module('Views.UserProfilesCollection', function(Module, App, Backbone, Marionette, $, _) {

    var CHEVRON_UP   = "soft-half--left fa fa-chevron-up";
    var CHEVRON_DOWN = "soft-half--left fa fa-chevron-down";

    Module.UserProfilesCollectionView = CoursAvenue.Views.PaginatedCollectionView.extend({
        template: Module.templateDirname() + 'user_profiles_collection_view',
        itemView: Module.UserProfile.UserProfileView,
        itemViewContainer: '[data-type=container]',
        className: 'relative',
        chevron: Handlebars.compile("<span class='soft-half--left fa fa-chevron-{{ order }}' data-type='order'></span>"),

        initialize: function () {
            _.bindAll(this, "announceUpdate");

            this.setEditing = _.debounce(this.setEditing);

            this.poller = Backbone.Poller.get(this.collection, { delay: 5000 });
            this.poller.on('success', _.bind(function (collection) {
                if (collection.jobs !== "false") { return; }

                this.poller.stop();
            }, this));

            this.on("click:outside", this.onClickOutside);

            this.currently_editing = []; // a FIFO list of rows
        },

        ui: {
            '$headers' : '[data-sort]',
            '$checkbox': '[data-behavior=bulk-select]'
        },

        onRender: function () {
            // set the chevron for the pivot column
            var sort    = this.collection.server_api.sort;
            var order   = (this.collection.server_api.order === "desc")? "down" : "up";
            var $pivot  = this.$('[data-sort=' + sort + ']');
            var chevron = Backbone.Marionette.Renderer.render(this.chevron, { order: order });

            $pivot.append(chevron);
            $pivot.addClass("active");
        },

        onClickOutside: function () {
            this.getCurrentlyEditing().finishEditing({ restore: false });
        },

        /* Controls for canceling/committing edits */
        cancel: function (e) {
            this.getCurrentlyEditing().finishEditing({ restore: true });
        },

        commit: function () {
            this.getCurrentlyEditing().finishEditing({ restore: false });
        },

        bulkSelect: function (e) {

            var checked = e.currentTarget.checked;

            (checked)? this.selectAll() : this.deselectAll();
        },

        announceUpdate: function () {
            this.trigger("user_profiles:update:selected", this.getUpdate());
        },

        getUpdate: function () {
            return {
                count: this.collection.getSelectedCount(),
                total: this.collection.getGrandTotal(),
                deep:  this.collection.isDeep()
            };
        },

        selectAll: function () {
            this.collection.selectAll();
            this.announceUpdate();
        },

        deselectAll: function () {
            this.collection.deselectAll();
            this.announceUpdate();
        },

        deepSelect: function () {
            this.collection.deepSelect().then(this.announceUpdate);
        },

        clearSelected: function () {
            this.collection.clearSelected();
            this.announceUpdate();
        },

        addTags: function (tags) {
            this.collection.bulkAddTags(tags);

            this.poller.start();
        },

        destroySelected: function () {
            this.collection.destroySelected();
            this.refreshPage(); // to fill in the hole
        },

        newUserProfile: function () {
            var attributes = { first_name: "", email: "", last_name: "", tags: "", "new": true };
            this.collection.add(attributes, { at: 0 });
        },

        /* currently_editing may have more than one view. We are only
         * concerned with the top one. */
        getCurrentlyEditing: function () {
            var itemview = _.first(this.currently_editing);

            return (itemview)? itemview : { finishEditing: function () { /* NOOP */ } } ;
        },

        /* when we click on a header: */
        /* find the current sorting pivot and remove a class from it
         *  add that class to the new one. Ensure that the disclosure triangle
         *  has the correct orientation. Then trigger filter:summary */
        /* TODO the actual filtering should be debounced so that if the
         * user clicky clicks the chevron many times, it still swaps up and down,
         * but fires only the last sort request */
        sort: function (e) {
            e.preventDefault();

            var sort = e.currentTarget.getAttribute('data-sort');
            var order = "desc";

            // if we are already sorting by this column, change the order
            if (sort === this.collection.server_api.sort) {
                order = this.collection.server_api.order;
                order = (order === "desc")? "asc" : "desc";
            }

            this.toggleChevron(order, e.currentTarget);
            this.trigger('filter:summary', { sort: sort, order: order });

            return false;
        },

        toggleChevron: function (order, target) {
            var $target = $(target);
            var $headers = this.ui.$headers;
            var $triangle = $headers.find("[data-type=order]").remove();
            var chevron = (order === "desc")? CHEVRON_DOWN : CHEVRON_UP;

            // toggle the active header
            $headers.removeClass("active");
            $target.addClass("active");

            // change the direction of the chevron if necessary
            $triangle.removeClass();
            $triangle.addClass(chevron);

            // add the chevron to the active header
            $target.append($triangle);
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

            var is_new            = itemview.model.get("new");
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

            // very special case: if the view we are done with was "new"
            // then we are about to open another new row automatically.
            // So we aren't really "done" editing... and the buttons should not flip
            this.setEditing(is_new || this.currently_editing.length === 1);
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
            this.collection.toggleSelected(itemview.model);
            this.announceUpdate();
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

        setEditing: function (editing) {
            this.is_editing = editing

            this.trigger("user_profiles:changed:editing", this.is_editing);
        },

        /* when rendering each collection item, we might want to
         * pass in some info from the paginator_ui or something
         * if do we would do it here */
        /* remember that itemViews are constructed and destroyed more often
        * than the corresponding models */
        itemViewOptions: function(model, index) {
            var id = model.get("id");
            var tags_url = this.collection.url.basename + '/tags.json';
            var checked = this.collection.isChecked(model);

            /* we pass in the hash of layout events the view will respond to */
            return {
                checked: checked, // TODO check if this is working: the select all seemed to be broken
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

            this.trigger('user_profiles:updated:tag:filters', {
                tags: this.collection.server_api.tags
            });

            /* set the header checkbox based on the deep select */
            var checked = (this.collection.isDeep() === true)? true : "";
            this.ui.$checkbox.prop("checked", checked);
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

