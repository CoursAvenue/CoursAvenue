
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
StructureProfile.module('Components.TabContents', function(Module, App, Backbone, Marionette, $, _, undefined) {

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

