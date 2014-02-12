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
//  - [_namespace_]: an optional identifier used to namespace events. The namespace
//    should be unique, but this is nowhere enforced.
//
// **usage**
//
// in `controllers/structures_controller.rb#show`
//```ruby
//@structure_tabs_manager = {
//  component: "tab-manager",
//  tabs: ['courses.calendar', 'comments', 'teachers.group', '']
//}
//```
//
// in `views/structures/show.html.haml`
//```
//#structure-tabs{ data: @structure_tab_manager }
//```
StructureProfile.module('TabManager', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.addInitializer(function () {
        $("[data-component=tab-manager]").each(function (index, element) {
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
        template: Module.templateDirname() + 'structure/relational_tab_layout',
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

// Tab Contents
// -----------
//
// Tab Contents attaches the following behaviors to the given element:
//
// **data API**
//  - _component_: tab-contents
//  - _for_: the name of the tab whose contents are contained in this
//    tab.
//
// **usage**
//
//```
//.tab{ data: { component: "TabContents", for: "courses" } }
//```
StructureProfile.module('TabContents', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.addInitializer(function () {
        $("[data-component=TabContents]").each(function (index, element) {
            var $element     = $(element),
                tab_name     = $element.data("for"),
                event        = _.capitalize(tab_name) + "TabClicked";

            StructureProfile.Behaviors.activateOn.attachTo({ element: element, event: event });
            StructureProfile.Behaviors.showWhenActive.attachTo({ element: element });
            StructureProfile.Behaviors.deactivateSiblings.attachTo({ element: element });

            consumeData($element);
        });
    });

    var consumeData = function consumeData ($element) {
        $element.removeAttr("data-component");
        $element.removeAttr("data-for");
    };

}, undefined);


// Behaviours
// ----------
//
// The Behaviors module is a collection of functions that each take an element and attach
// some event handlers to it, or to the document. Each behavior is meant to be stateless,
// general, and as simple as possible. By combining behaviors on an object, we can easily
// create more complicated DOM interactions, without the need to instantiate a full-fledged
// Marionette view.
//
// **data API**
//
// _behaviors_: a name of a behavior the element is to implement, or an array of such names.
//
// **submodules**
//
// [WIP] Submodules that implement a match function will be passed the given behavior name,
// and the first one that matches will be attached to the element.
//
// **usage**
//
// ```
// .tab.hidden{ data: { behaviors: ['showWhenActive', 'activateOnCoursesTabClicked', 'deactivateSiblings'] }}
// ```
StructureProfile.module('Behaviors', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.addInitializer(function () {
        $("[data-behaviors]").each(function (index, element) {
            var $element  = $(element),
                behaviors = $element.data("behaviors");

            if (!_.isArray(behaviors)) {
                behaviors = [behaviors];
            }

            _.each(behaviors, function (behavior_name) {
                var behavior = behavior_name;

                if (Module[behavior] != undefined) {
                    Module[behavior].attachTo({ element: element, event: event });
                } else {
                    var match = behavior.match(/(.*?On)(.*)/).slice(1); // slice off the full match
                    var event = match[1];
                    behavior  = match[0];

                    if (Module[behavior] != undefined) {
                        Module[behavior].attachTo({ element: element, event: event });
                    }
                }
            });
        });
    });

}, undefined);

// Behaviors.showWhenActive
// -----------------------
//
// Any time this element becomes active, it is shown. It is hidden when
// it is deactivate, and by default we expect it to be hidden, but this
// is not enforced. This behavior is agnostic
// as to how the element became active, and needs to be either combined with
// `activateOn`, or used together with a view that will activate the element.
//
// **usage**
// ```
// .tab.hidden{ data: { behaviors: 'showWhenActive' }}
// ```
StructureProfile.module('Behaviors.showWhenActive', function(Module, App, Backbone, Marionette, $, _, undefined) {
    this.startWithParent = false;

    Module.attachTo = function (options) {
        Module.start();

        var $element = $(options.element);

        $element.on("activate", function showTabContents (e) {
            $(this).show();
        });

        $element.on("deactivate", function hideTabContents (e) {
            $(this).hide();
        });
    };

}, undefined);

// Behaviors.deactivateSiblings
// -----------------------
//
// Any time the element becomes active, it triggers 'deactivate' on all of the sibling
// elements. Any sibling element that has implemented some behavior on deactivate will
// do its thing.
//
// **usage**
// ```
// .tab.hidden{ data: { behaviors: 'deactivateSiblings' }}
// ```
StructureProfile.module('Behaviors.deactivateSiblings', function(Module, App, Backbone, Marionette, $, _, undefined) {
    this.startWithParent = false;

    Module.attachTo = function (options) {
        Module.start();

        var $element  = $(options.element),
            $siblings = $element.siblings();

        $element.on("activate", function () {
            $siblings.trigger("deactivate");
        });
    };

}, undefined);

// Behaviors.activateOn
// -----------------------
//
// This behavior defines a global event that will cause this element to emit the "activate"
// event. The behavior name must be followed by the camelized signature of the event that
// will cause this element to activate. For example, attaching the behavior `activateOnCoursesTabClicked`
// will cause this element to activate when `courses:tab:clicked` is triggered somewhere
// in the DOM.
//
// **usage**
// ```
// .tab.hidden{ data: { behaviors: ['activateOnMapMarkerClicked', 'activateOnCoursesTabClicked'] }}
// ```
StructureProfile.module('Behaviors.activateOn', function(Module, App, Backbone, Marionette, $, _, undefined) {
    this.startWithParent = false;

    var _activate = function activate (element, e) {
        var $element = $(element);
        $element.trigger("activate");
    };

    Module.attachTo = function (options) {
        Module.start();

        var $element    = $(options.element),
            activate    = _.partial(_activate, options.element),
            event       = options.event.replace(/([A-Z])/g, ':$1').replace(/^:/, '').toLowerCase(); // from camel to event style

        $(document).on(event, activate);
    };

}, undefined);

// Behaviors.log
// -----------------------
//
// **usage**
// ```
// .tab.hidden{ data: { behaviors: ['logActivate', 'logCousesTabClicked'] }}
// ```
StructureProfile.module('Behaviors.logOn', function(Module, App, Backbone, Marionette, $, _, undefined) {
    this.startWithParent = false;

    Module.attachTo = function (options) {
        Module.start();

        var $element    = $(options.element),
            event       = options.event.replace(/([A-Z])/g, ':$1').replace(/^:/, '').toLowerCase(); // from camel to event style

        $element.on(event, console.log);
    };

}, undefined);
