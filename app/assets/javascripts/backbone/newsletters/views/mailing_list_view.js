Newsletter.module('Views', function(Module, App, Backbone, Marionette, $, _) {
    Module.MailingListView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'mailing_list_view',
        tagName: 'div',
        className: '',

        events: {
            // 'click [data-mailing-list]': 'selectMailingList'
            'change [type=radio]': 'showFilters'
        },

        initialize: function initialize () {
            _.bindAll(this, 'selectMailingList', 'showFilters');
        },

        selectMailingList: function selectMailingList () {
            this.trigger('selected', { model: this.model });
        },

        showFilters: function showFilters () {
            this.$el.find('[data-filters-list]').slideDown();
        },

    });
});

