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

        initialize: function initialize () {
            this.setEditing            = _.debounce(this.setEditing).bind(this);
            this.announceFilterSummary = _.debounce(this.announceFilterSummary, 500).bind(this);

            this.poller = Backbone.Poller.get(this.collection, { delay: 5000 });
            this.poller.on('success', _.bind(function (collection) {
                if (collection.jobs !== "false") { return; }

                this.poller.stop();
            }, this));

            this.on("click:outside", this.onClickOutside);

            this.currently_editing = []; // a FIFO list of rows
            this.current_order     = null; // see announcefiltersummary

            $(document).on('user_profile:updated', function(event, data) {
                var user_profile = this.collection.where({ id: data.id })[0];
                user_profile.set(data, { silent: true });
                user_profile.trigger('render');
            }.bind(this));

        },

        ui: {
            '$headers' : '[data-sort]',
            '$checkbox': '[data-behavior=bulk-select]',
            '$loader'  : '[data-type="loader"]'
        },

        collectionEvents: {
            'selection:counts': 'announceUpdate'
        },

        onRender: function onRender () {
            // set the chevron for the pivot column
	    var sort    = this.collection.queryParams.sort;
	    var order   = (this.collection.queryParams.order === "desc")? "down" : "up";
            var $pivot  = this.$('[data-sort=' + sort + ']');
            var chevron = Backbone.Marionette.Renderer.render(this.chevron, { order: order });

            $pivot.append(chevron);
            $pivot.addClass("active");
        },

        onClickOutside: function onClickOutside () {
            this.getCurrentlyEditing().finishEditing({ restore: false });
        },

        bulkSelect: function bulkSelect (e) {
            var checked = e.currentTarget.checked;

            (checked)? this.selectAll() : this.deselectAll();
        },

        announceUpdate: function announceUpdate (data) {
            this.trigger("user_profiles:update:selected", data);
        },

        selectAll: function selectAll () {
            this.collection.selectAll();
        },

        deselectAll: function deselectAll () {
            this.collection.deselectAll();
        },

        deepSelect: function deepSelect () {
            this.collection.deepSelect();
        },

        clearSelected: function clearSelected () {
            this.collection.clearSelected();
        },

        addTags: function addTags (tags) {
            this.collection.bulkAddTags(tags);

            this.poller.start();
        },

        destroySelected: function destroySelected () {
            this.collection.destroySelected();
            this.refreshPage(); // to fill in the hole
        },

        newUserProfile: function newUserProfile () {
            var attributes = { first_name: "", email: "", last_name: "", tags: "", new: true, structure_id: this.collection.structure_id };
            this.collection.add(attributes, { at: 0 });
        },

        /* currently_editing may have more than one view. We are only
         * concerned with the top one. */
        getCurrentlyEditing: function getCurrentlyEditing () {
            var itemview = _.first(this.currently_editing);

            return (itemview)? itemview : { finishEditing: function finishEditing () { /* NOOP */ } } ;
        },

        /* when we click on a header: */
        /* find the current sorting pivot and remove a class from it
         *  add that class to the new one. Ensure that the disclosure triangle
         *  has the correct orientation. Then trigger filter:summary */
        sort: function sort (e) {
            var sort, order;
            e.preventDefault();

            if (this.current_order === null) {
		this.current_order = this.collection.queryParams.order;
            }

            sort  = e.currentTarget.getAttribute('data-sort');
            order = "desc";

            // if we are already sorting by this column, change the order
	    if (sort === this.collection.queryParams.sort) {
                order = this.current_order;
                order = (order === "desc")? "asc" : "desc";
            }

            this.current_order = order;
            this.toggleChevron(order, e.currentTarget);
            this.announceFilterSummary(sort, order);

            return false;
        },

        announceFilterSummary: function announceFilterSummary (sort, order) {
            // this.current_order is given a value the first time a user clicks
            // a column, and then toggles while the user is still clicking. When
            // the user hasn't clicked for a while, this method is called and that
            // value is nullified. This is because we are debouncing the actual
	    // change in the queryParams order, but not the chevron direction

            this.current_order = null;
            this.trigger('filter:summary', { sort: sort, order: order });
        },

        toggleChevron: function toggleChevron (order, target) {
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
        onItemviewChangedEditing: function onItemviewChangedEditing (itemview) {
            var previous_itemview = this.getCurrentlyEditing();

            var is_new            = itemview.model.get("new"),
                is_editing        = itemview.isEditing();

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
        onItemviewUpdateSuccess: function onItemviewUpdateSuccess (itemView, response) {
            var action = response.action;

            if (action === "create") {
                this.newUserProfile();
            }
        },

        /* if the itemview was new, and its edits didn't get set on the server
         * because of invalid data, we just set the edits on the model so that
         * they don't disappear. */
        onItemviewUpdateError: function onItemviewUpdateError (itemview, response) {
            if (itemview.model.get("new") === true) {
                itemview.model.set(itemview.edits);
            }
        },

        /* an item has been checked or unchecked */
        onItemviewAddToSelected: function onItemviewAddToSelected (itemview) {
            this.collection.toggleSelected(itemview.model);
        },

        onAfterItemAdded: function onAfterItemAdded (itemView) {
            if (itemView.model.get("new")) {
                itemView.$(".editable-text").first().click();

                var table_top  = this.$el.offset().top;
                var scroll_top = $(window).scrollTop();

                if (scroll_top > table_top) {
                    $(window).scrollTo(table_top, "slow");
                }
            }
        },

        setEditing: function setEditing (editing) {
            this.is_editing = editing

            this.trigger("user_profiles:changed:editing", this.is_editing);
        },

        /* when rendering each collection item, we might want to
         * pass in some info from the paginator_ui or something
         * if do we would do it here */
        /* remember that itemViews are constructed and destroyed more often
         * than the corresponding models */
        itemViewOptions: function itemViewOptions(model, index) {
            var id       = model.get("id");
            var tags_url = Routes.pro_structure_tags_path(this.collection.structure_id, { format: 'json' })
            var checked  = this.collection.isChecked(model);

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

        onAfterShow: function onAfterShow () {
            this.announcePaginatorUpdated();

            this.announceInitialFilters();
            if (this.collection.isAdvancedFiltered()) {
                this.announceInitialAdvancedFilters();
            }
        },

        /* override inherited method */
        announcePaginatorUpdated: function announcePaginatorUpdated () {
            this.trigger('paginator:updated');
	    if (this.collection.state.totalPages == undefined || this.collection.state.totalPages < 1) {
                return;
            }

	    var data         = this.collection.state;

            this.trigger('user_profiles:updated');

            /* announce the pagination statistics for the current page */
            this.trigger('user_profiles:updated:pagination', {
                current_page:        data.currentPage,
                last_page:           data.totalPages,
                radius:              data.radius,
                query_strings:       this.buildPageQueriesForRange(data.totalPages),
		is_last_page:        this.collection.isLastPage(),
		is_first_page:       this.collection.isFirstPage(),
		sort:                this.collection.queryParams.sort
            });

            /* set the header checkbox based on the deep select */
            var checked = (this.collection.isDeep() === true)? true : "";
            this.ui.$checkbox.prop("checked", checked);
        },

        announceInitialFilters: function announceInitialFilters () {
            /* the filters have been set up and are ready to be shown */
	    this.trigger('user_profiles:updated:keyword:filters', this.collection.queryParams.name);
        },

        announceInitialAdvancedFilters: function announceInitialAdvancedFilters () {
            this.trigger('user_profiles:updated:filters');
	    this.trigger('user_profiles:updated:tag:filters', this.collection.queryParams["tags[]"]);
        },

        sendMessageToSelected: function sendMessageToSelected () {
            var data = { structure_id: this.collection.structure_id,
                          message: { recipients: this.collection.selected_ids }
                       }
            $.fancybox.open({ href: Routes.new_pro_structure_message_path(data),
                              type    : 'ajax',
                              width   : 800,
                              minWidth: 800,
                              maxWidth: 800
                            });
            // window.open(Routes.new_pro_structure_message_path(data));
        },

        showLoader: function showLoader () {
            this.ui.$loader.show();
        },

        hideLoader: function hideLoader () {
            this.ui.$loader.hide();
        },

        /* OVERRIDE */
        /* We are implementing appendHTML here so that we can both
        * append (normal) and prepend (when using "new") to the
        * table */
        appendHtml: function appendHtml(compositeView, itemView, index){
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

