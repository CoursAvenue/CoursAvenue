# A Proposal for Generators

### Brief

We want generators for:
 - installing a new event-driven marionette app
 - creating a view with corresponding template
 - creating a model, creating a collection

All generators create or update the relevant manifests.

### Installing an App

At CoursAvenue we treat any new page that needs attractive and dynamic
javascript activity as a new app, which lives in its own subdirectory
and has its own resources. There is a great deal of boilerplate code
and files (such as manifests) that need to be created when initially
installing a new app. These generators are being created to ease that
process.

`$ rails g coursavenue:scaffold MyApp Widgets`

creates the following directory structure,

````
backbone/my_app
backbone/my_app/models
backbone/my_app/models/widget.js
backbone/my_app/models/widgets_collection.js
backbone/my_app/views
backbone/my_app/views/my_app_layout.js <-- inherits from Coursavenue.Lib.EventLayout
backbone/my_app/views/widgets_collection/
backbone/my_app/views/widgets_collection/widgets_collection_view.js
backbone/my_app/views/widgets_collection/widget/
backbone/my_app/views/widgets_collection/widget/widget_view.js
backbone/my_app/templates
backbone/my_app/templates/my_app_layout.jst.hbs
backbone/my_app/templates/widgets_collection/
backbone/my_app/templates/widgets_collection/widgets_collection_view.jst.hbs
backbone/my_app/templates/widgets_collection/widget/
backbone/my_app/templates/widgets_collection/widget/widget_view.jst.hbs
backbone/my_app/applications
backbone/my_app/applications/MyApp.js
````

by invoking other generators. Each directory will have a manifest file,
which will specify load time dependencies between modules.

The MyApp.js file will contain the following boilerplate code:

````
MyApp = (function (){
    var self = new Backbone.Marionette.Application({
        slug: 'my-app',

        /* for use in query strings */
        root:   function() { return self.slug + '-root'; },

        /* methods for returning the relevant jQuery collections */
        $root: function() {
            return $('[data-type=' + self.root() + ']');
        },

        /* An app should only start if it detects
         * an element whose data-type is the same as its
         * root property.
         * @throw the root was found to be non-unique on the page */
        detectRoot: function() {
            var result = self.$root().length;

            if (result > 1) {
                throw {
                    message: 'MyApp->detectRoot: ' + self.root() + ' element should be unique'
                }
            }

            return result > 0;
        },
    });

    return self;
}());

MyApp.addRegions({
    mainRegion: '#' + MyApp.slug
});

MyApp.addInitializer(function(options) {

    // if the generator was called with a model and view the
    // generator will also give us the following
    // otherwise its just empty

    // bootstrap data provided by the surrounding app
    var bootstrap = window.coursavenue.bootstrap;

    // Create an instance of your class and populate with the models of your entire collection
    widgets                 = new MyApp.Models.WidgetsCollection(bootstrap.models, bootstrap.options);
    widgets_collection_view = new MyApp.Views.WidgetsCollection.WidgetsCollectionView({
        collection: widgets,
        events: {
            'widget:go':     'someMethod'
        }
    });

    widgets.bootstrap(); // not sure if this will always be applicable
    window.pfaff = widgets;

    /* set up the layouts */
    layout           = new MyApp.Views.MyAppLayout();

    /* code to demonstrate initializing some submodules to be added to the layout here */
    // var SubModules = MyApp.Views.WidgetsCollection.SubModules;

    // var submodule               = new SubModules.SubModule({});
    // var submodule_with_events   = new SubModules.SubModuleWithEvents({});
    // var submodule_with_selector = new SubModules.SubModuleWithSelector({});

    // MyApp.mainRegion.show(layout);

    /* we can add a widget along with a callback to be used
     * for setup */
    //layout.showWidget(submodule_with_events, {
    //    events: {
    //        'some:event':               'aMethod orTwo',
    //    }
    //});

    //layout.showWidget(submodule);

    //layout.showWidget(submodule_with_selector, {
    //    events: {
    //        'some:event':               'aMethod orTwo',
    //    },
    //    selector: '[data-type=something-weird]'
    //});

    layout.results.show(widgets_collection_view); // shouldn't be "results" should be app specific
});

$(document).ready(function() {
    /* we only want MyApp on the correct page */
    if (MyApp.detectRoot()) {
        MyApp.start({});
    }

});
````

### Layout

CoursAvenue's event-driven take on backbone.marionette requires that every
event group have a layout at its core. The layout, which descends from EventLayout,
is in charge of receiving events from different parts of the app and passing
them, either up to another layout, or back down to another part of the app.
This is best described by a series of diagrams, but we don't have any diagrams.

This invocation,

`$ rails g coursavenue:layout MyApp Space.Ship ShipLayout`

will just create the layout file `backbone/my_app/space/ship/ship_layout.js`.
Specifying no module is also possible, of course, but most apps begin their
life with a layout at the top level of the views directory, so there will
normally be no need for this.

### Models & Collections

For models and collections, we will need to give the generator some
information, which it will use in making the boilerplate. For example,
if we want to add a SpecialWidget model to an existing app called MyApp,
we want to run:

`$ rails g coursavenue:model MyApp SpecialWidget`

This will create `/backbone/my_app/models/special_widget.js`, which will
begin with,

````
MyApp.module('Models', function(Models, App, Backbone, Marionette, $, _) {
    Models.SpecialWidget = Backbone.Model.extend({
        // your implementation here
    });
});

````

The generator `coursavenue:collection` would be similar, but would result
in a file containing,

````
MyApp.module('Models', function(Models, App, Backbone, Marionette, $, _) {
    Models.SpecialWidgetsCollection = Backbone.Collection.extend({
        model: SpecialWidget
        // your implementation here
    });
});
````

And the corresponding model would be created if it didn't already exist (by
an invocation).

### Views & Templates

Views and templates will be built similarly to models and collections, with
the generator for views invoking the generator for templates. In coursavenue
apps, views and templates tend to make much heavier use of nesting. When
invoking the generator for a view for, say, WidgetView in `views/space/ships`,
we invoke the generator with a period delimited list of namespaces:

`$ rails g coursavenue:view:itemview MyApp Space.Ship Widget`

This would create `backbone/my_app/views/space/ship/widget/widget_view.js` and,
`backbone/my_app/templates/space/ship/widget/widget_view.jst.hbs` would be created
as well.

````
FilteredSearch.module('Views.Space.Ship.Widget', function(Module, App, Backbone, Marionette, $, _) {
    Module.WidgetView = Backbone.Marionette.ItemView.extend({
        template: App.templateDirname() + 'widget_view',

        // your implementation here
    });
});
````

Collection views and composite views are naturally more complicated. In the
case of a collection view, a user will invoke:

`$ rails g coursavenue:view:collection MyApp Space.Ship Widget`

This will create `backbone/my_app/space/ship/widgets_collection/widgets_collection_view.js`,
and the corresponding template. It will also attempt to invoke,

`$ rails g coursavenue:view:item MyApp Space.Ship.WidgetsCollection Widget`

which we hope will create `backbone/my_app/space/ship/widgets_collection/widget/widget_view.js`
and the corresponding templates. However, the user will be promted (y/n) before
any additional views are created (we can imagine situations in which multiple collection
views are using the same item view, etc).

Composite views can have a model, in addition to an itemview. This must be specified
as an option, as in,

`$ rails g coursavenue:view:composite --with-model Odometer MyApp Space.Ship Widget`

### Namespace Collisions

We don't allow any duplication of names within a single app. Across apps, duplication
may occur but is not encouraged. As such, if a user invokes a generator like so,

`$ rails g coursavenue:view:item MyApp Space.Ship Widget`

Naturally the operation will fail since Rails won't allow the generated js to overwrite
existing files. More subtly, though, our generator will throw an exception if
a "widget_view.js" exists anywhere else in the app. There can't be two WidgetViews
in one app. If a file by that name is found in another app, a warning will be
printed and the user will have to choose (y/n) to proceed.

*ed: maybe this is too strong a requirement: I mean, why are we using namespaces
at all if we don't allow duplicate leaves?*

It may be the case that there a user invokes,

`$ rails g coursavenue:view:collection MyApp Space.Ship Widget`

before invoking,

`$ rails g coursavenue:view:item MyApp Space.Ship Widget`

In this case, a warning will be generated. The generator will detect that a file
named `widgets_collection_view` already exists, and will suggest that the user
meant to invoke:

`$ rails g coursavenue:view:itemview MyApp Space.Ship.WidgetsCollection Widget`

The user will be prompted (y/n), but will be allowed to create the strange
directory structure if they want.

### Options

The various generators will naturally need to take some opts, so that we don't
waste time removing unnecessary crud.

 - `--no-template`
    generates the view without a template; the option is passed down to
    further generators that may be invoked along the way.

 - `--no-model`
    generates a collection without a model.

### Wants

This is enough for now, but later I would like the js files generated
to begin their life with a bunch of empty methods. A short list of methods
that would be useful:

 - initialize
 - setup
 - reset
 - itemviewOptions
 - tagName, etc for views
