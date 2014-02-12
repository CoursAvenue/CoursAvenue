// Tab Manager
// -----------
//
// A tab manager provides a bunch of buttons, which when clicked will control
// the visibility of elements somewhere else on the page.
//
// **data API**
//  - _component_: TabManager
//  - _tabs_: a list of tab names. The tab manager will emit events whenever its
//    tabs are clicked, so that the corresponding content will be shown. Each
//    tab name may include a period (.), followed by a fa-icon to be used next
//    to its name. Blank tabs are be skipped
//  - [_namespace_]: an optional identifier used to namespace events. The namespace
//    should be unique, but this is nowhere enforced.
//
// **usage**
//
// in `controllers/structures_controller.rb#show`
//```ruby
//@structure_tabs_manager = {
//  component: "TabManager",
//  tabs: ['courses.calendar', 'comments', 'teachers.group', '']
//}
//```
//
// in `views/structures/show.html.haml`
//```
//#structure-tabs{ data: @structure_tab_manager }
//```
StructureProfile.module('Views.TabManager', function(Module, App, Backbone, Marionette, $, _, undefined) {

    // a function to run when it is determined that this module will be used. Creates
    // a TabManager view object for each element with data-view=TabManager.
    Module.addInitializer(function () {
        $("[data-component=TabManager]").each(function (index, element) {
            var $element     = $(element),
                tabs         = buildTabs($element.data("tabs")),
                namespace    = $element.data("namespace"),
                view         = new Module.TabManager({ tabs: tabs, namespace: namespace }),
                region_name  = 'TabManager' + _.capitalize(view.cid),
                regions      = {};

            regions[region_name] = "#" + view.cid;
            $element.attr("id", view.cid);

            App.addRegions(regions);
            App[region_name].show(view);

            consumeData($element);
        });
    });

    Module.TabManager = Marionette.ItemView.extend({
        template: Module.templateDirname().slice(0, -1), // TODO this might need to change?
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

        hideTabContents: function hideTabContents (e) {
            var tab_name = this.$(e.target).data("relation");
            this.$el.trigger(tab_name + ":click:hide", e);
        },

        serializeData: function serializeData () {
            return {
                tabs: this.options.tabs
            };
        }
    });

    var consumeData = function consumeData ($element) {
        $element.removeAttr("data-component");
        $element.removeAttr("data-tabs");
    };

    var buildTabs = function buildTabs (tabs) {
        return _.reduce(tabs, function (memo, data, index) {
            var data = data.split('.'),
                slug = data[0],
                name = _.capitalize(slug),
                icon, tab, active;

            if (slug === "") return memo;

            icon   = (data.length > 0) ? data[1] : undefined;
            active = (index === 0)     ? "active": undefined;

            tab          = memo[name] = {};
            tab.slug     = slug;
            tab.name     = name;
            tab.icon     = icon;
            tab.active   = active;

            return memo;
        }, {});
    };
}, undefined);


