Newsletter.module('Views', function(Module, App, Backbone, Marionette, $, _) {
    Module.MailingListView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'mailing_list_view',
        tagName: 'div',
        className: '',

        events: {
            'click [data-mailing-list]': 'selectMailingList'
        },

        initialize: function initialize () {
            _.bindAll(this, 'selectMailingList');
        },

        selectMailingList: function selectLayout () {
            this.trigger('selected', { model: this.model });
        },
    });
});

