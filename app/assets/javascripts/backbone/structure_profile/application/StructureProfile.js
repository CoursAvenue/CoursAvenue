StructureProfile = new Backbone.Marionette.Application({ slug: 'structure-profile'});

$(document).ready(function() {
    StructureProfile.start({});
});

// Tab Manager
// -----------
//
// A tab manager provides a bunch of buttons, which when clicked will control
// the visibility of elements somewhere else on the page.
//
// **data API**
//  - _component_: tab-manager
//  - _tabs_: a list of tab names. The tab manager will emit events whenever its
//    tabs are clicked, so that the corresponding content will be shown. Each
//    tab name may include a period (.), followed by a fa-icon to be used next
//    to its name. Blank tabs are be skipped
//  - _id_: an identifier used to namespace events. The id should be unique, but
//    this is nowhere enforced.
StructureProfile.module('TabManager', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.addInitializer(function () {
        $("[data-component=tab-manager]").each(function (index, element) {
            var $element     = $(element),
                tabs         = buildTabs($element.data("tabs")),
                id           = $element.data("id"),
                view         = new Module.TabManager({ tabs: tabs, id: id }),
                region_name  = 'TabManager' + _.capitalize(view.cid),
                regions      = {};

            regions[region_name] = "#" + view.cid;
            $(element).append("<div id=" + view.cid + ">");

            App.addRegions(regions);
            App[region_name].show(view);

            consumeData($element);
        });
    });

    Module.TabManager = Marionette.ItemView.extend({
        template: Module.templateDirname() + 'structure/relational_tab_layout',

        initialize: function initialize (options) {
            if (options  && !options.id) throw new Error();
            if (!options || !options.tabs) {
                this.options.tabs = {};
            }

        },

        ui: {
            $tabs: '[data-tabs]'
        },

        events: {
            'click @ui.$tabs': 'tabClickHandler'
        },

        tabClickHandler: function tabClickHandler (e) {
            this.trigger(this.options.id + );
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

