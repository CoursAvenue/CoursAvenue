
StructureProfile.module('Views.TabManager', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.TabManager = Marionette.ItemView.extend({
        template: Module.templateDirname().slice(0, -1),
        tagName: 'ul',
        className: 'tabs',

        initialize: function initialize (options) {
            if (!options || !options.tabs) {
                this.options.tabs = {};
            }
        },

        ui: {
            $tabs: '[data-toggle=tab]'
        },

        events: {
            'click @ui.$tabs': 'tabClickHandler'
        },

        tabClickHandler: function tabClickHandler (e) {
            this.showTabContents(e);
        },

        showTabContents: function showTabContents (e) {
            var tab_name = this.$(e.target).data("relation");
            this.$el.trigger(tab_name + ":tab:clicked", e);
        },

        serializeData: function serializeData () {
            return {
                tabs: this.options.tabs
            };
        }
    });
}, undefined);

StructureProfile.module('Views.TabManager.Flavors.Relational', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.TabManager = StructureProfile.Views.TabManager.TabManager.extend({
        template: Module.templateDirname().slice(0, -1)
    });
}, undefined);
