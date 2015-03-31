
StructureProfile.module('Views.Structure.Comments', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.CommentsCollectionView = CoursAvenue.Views.PaginatedCollectionView.extend({
        childView: Module.CommentView,
        template: Module.templateDirname() + 'comments_collection_view',
        childViewContainer: '[data-type=container]',

        ui: {
            '$comments_count': '[data-type=comments-count]'
        },

        initialize: function initialize (options) {
            _.bindAll(this, 'announcePaginatorUpdated');
            this.about = options.about;
            this.pagination_bottom = new CoursAvenue.Views.PaginationToolView({});
            this.pagination_bottom.on('pagination:next', this.nextPage.bind(this));
            this.pagination_bottom.on('pagination:prev', this.prevPage.bind(this));
            this.pagination_bottom.on('pagination:page', this.goToPage.bind(this));
            this.collection.on('comments:updated', this.announcePaginatorUpdated)
        },

        onRender: function onRender () {
            this.$('[data-type="bottom-pagination-tool"]').append(this.pagination_bottom.el);
        },

        announcePaginatorUpdated: function announcePaginatorUpdated () {
            this.ui.$comments_count.text(this.collection.state.grandTotal);
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
            if (this.collection.state.grandTotal == 0) {
                this.$('[data-empty-comments]').removeClass('hidden');
                this.$('[data-not-empty-comments]').hide();
            } else {
                this.$('[data-empty-comments]').addClass('hidden');
                this.$('[data-not-empty-comments]').show();
            }
        },

        childViewOptions: function childViewOptions () {
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
