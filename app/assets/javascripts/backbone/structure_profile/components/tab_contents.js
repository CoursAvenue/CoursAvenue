
// Tab Contents
// -----------
//
// Tab Contents attaches the following behaviors to the given element:
//  - _activateOn_: the tab contents become active when TabClicked is
//    fired for the tab specified in the `data-for` attribute, described
//    below.
//  - _showWhenActive_: the tab will be shown or hidden depending on its
//    state.
//  - _deactivateSiblings_: when a tab contents is show, it hides other
//    nearby tab contents
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
Daedalus.module('Components.TabContents', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.addInitializer(function initializeTabContents () {
        $("[data-component=TabContents]").each(function (index, element) {
            var $element     = $(element),
                tab_name     = $element.data("for"),
                event        = _.capitalize(tab_name) + "TabClicked";

            Daedalus.Behaviors.activateOn.attachTo({ event: event }, element);
            Daedalus.Behaviors.showWhenActive.attachTo({}, element);
            Daedalus.Behaviors.deactivateSiblings.attachTo({}, element);

            consumeData($element);
        });
    });

    var consumeData = function consumeData ($element) {
        $element.removeAttr("data-component");
        $element.removeAttr("data-for");
    };

}, undefined);

