
StructureProfile.module('Views.Structure.Comments', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.CommentsCollectionView = CoursAvenue.Views.PaginatedCollectionView.extend({
        itemView: Module.CommentView,
        template: Module.templateDirname() + 'comments_collection_view',
        itemViewContainer: '[data-type=container]',

        initialize: function() {
            if (this.collection.length == 0) {
                this.$('[data-empty-comments]').show();
            }
            this.pagination_bottom = new CoursAvenue.Views.PaginationToolView({});
            this.pagination_top    = new CoursAvenue.Views.PaginationToolView({});
            this.pagination_bottom.on('pagination:next', this.nextPage.bind(this));
            this.pagination_bottom.on('pagination:prev', this.prevPage.bind(this));
            this.pagination_bottom.on('pagination:page', this.goToPage.bind(this));
            this.pagination_top.on('pagination:next', this.nextPage.bind(this));
            this.pagination_top.on('pagination:prev', this.prevPage.bind(this));
            this.pagination_top.on('pagination:page', this.goToPage.bind(this));
            this.announcePaginatorUpdated();
        },

        onAfterShow: function onAfterShow () {
            if (this.collection.length == 0) {
                this.$('[data-empty-comments]').show();
            } else {
                this.$('[data-empty-comments]').hide();
            }
        },

        onRender: function onRender () {
            this.$('[data-type="bottom-pagination-tool"]').append(this.pagination_bottom.el);
            this.$('[data-type="top-pagination-tool"]').append(this.pagination_top.el);
        },

        announcePaginatorUpdated: function announcePaginatorUpdated () {
            if (this.collection.paginator_ui) { this.collection.paginator_ui.currentPage = this.collection.currentPage; }
            var data = {
                current_page:        this.collection.paginator_ui.currentPage,
                queryOptions:       '',
                last_page:           this.collection.paginator_ui.totalPages,
                radius:              3,
                query_strings:       '',
                previous_page_query: this.collection.previousQuery(),
                next_page_query:     this.collection.nextQuery()
            };
            this.pagination_bottom.reset(data);
            this.pagination_top.reset(data);
        },

        itemViewOptions: function itemViewOptions () {
            return {
                structure_name: this.collection.structure.get('name')
            }
        },

        serializeData: function serializeData () {
            return {
                new_comments_path: Routes.new_structure_comment_path(this.collection.structure.get('slug'))
            }
        }
    });
});
