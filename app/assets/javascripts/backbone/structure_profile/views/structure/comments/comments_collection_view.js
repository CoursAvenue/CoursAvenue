
StructureProfile.module('Views.Structure.Comments', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.CommentsCollectionView = CoursAvenue.Views.PaginatedCollectionView.extend({
        itemView: Module.CommentView,
        template: Module.templateDirname() + 'comments_collection_view',
        itemViewContainer: '[data-type=container]',

        initialize: function() {
            if (this.collection.length == 0) {
                this.$('[data-empty-comments]').show();
            }
            pagination_bottom = new CoursAvenue.Views.PaginationToolView({});
            pagination_top    = new CoursAvenue.Views.PaginationToolView({});
            pagination_bottom.on('pagination:next', this.nextPage.bind(this));
            pagination_bottom.on('pagination:prev', this.prevPage.bind(this));
            pagination_bottom.on('pagination:page', this.goToPage.bind(this));
            pagination_top.on('pagination:next', this.nextPage.bind(this));
            pagination_top.on('pagination:prev', this.prevPage.bind(this));
            pagination_top.on('pagination:page', this.goToPage.bind(this));
        },

        onRender: function onRender () {
            this.$('[data-type="bottom-pagination-tool"]').append(pagination_bottom.el);
            this.$('[data-type="top-pagination-tool"]').append(pagination_top.el);
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
            pagination_bottom.reset(data)
            pagination_top.reset(data)
        }
    });
});
