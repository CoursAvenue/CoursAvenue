Newsletter.module('Views', function(Module, App, Backbone, Marionette, $, _) {
    Module.MailingListView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'mailing_list_view',
        tagName: 'div',
        className: '',

        events: {
            'change [type=radio]': 'selectMailingList',
        },

        initialize: function initialize () {
            _.bindAll(this, 'selectMailingList');
        },

        selectMailingList: function selectMailingList () {
            this.model.set('selected', true);
            this.$el.find('[data-filters-list]').slideDown();

            this.trigger('selected', { model: this.model });
        },
    });
});

