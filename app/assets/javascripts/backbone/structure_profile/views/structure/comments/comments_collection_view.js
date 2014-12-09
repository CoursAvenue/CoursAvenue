
StructureProfile.module('Views.Structure.Comments', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.CommentsCollectionView = CoursAvenue.Views.PaginatedCollectionView.extend({
        itemView: Module.CommentView,
        template: Module.templateDirname() + 'comments_collection_view',
        itemViewContainer: '[data-type=container]',

        initialize: function initialize (options) {
            this.about = options.about;
            this.pagination_bottom = new CoursAvenue.Views.PaginationToolView({});
            this.pagination_bottom.on('pagination:next', this.nextPage.bind(this));
            this.pagination_bottom.on('pagination:prev', this.prevPage.bind(this));
            this.pagination_bottom.on('pagination:page', this.goToPage.bind(this));
        },

        onRender: function onRender () {
            this.$('[data-type="bottom-pagination-tool"]').append(this.pagination_bottom.el);
            this.$('[data-behavior="lazy-load"]').lazyload();
        },

        announcePaginatorUpdated: function announcePaginatorUpdated () {
            var data = {
                current_page:        this.collection.state.currentPage,
                queryOptions:       '',
                last_page:           this.collection.state.totalPages,
                radius:              3,
                query_strings:       '',
                is_last_page:        this.collection.isLastPage(),
                is_first_page:       this.collection.isFirstPage(),
            };
            this.pagination_bottom.reset(data);
        },

        itemViewOptions: function itemViewOptions () {
            return {
                structure_name: this.collection.structure.get('name')
            }
        },

        serializeData: function serializeData () {
            return {
                new_comments_path: Routes.new_structure_comment_path(this.collection.structure.get('slug')),
                about            : this.about,
                has_comments     : this.collection.structure.get('has_comments')
            }
        }
    });
});
