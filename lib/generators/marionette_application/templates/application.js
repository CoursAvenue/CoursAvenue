<%= name %> = new Backbone.Marionette.Application({ slug: '<%= name.underscore.gsub(/_/, "-") %>' });

<%= name %>.addRegions({
    mainRegion: '#' + this.slug
});

<%= name %>.addInitializer(function(options) {

    // if the generator was called with a model and view the
    // generator will also give us the following
    // otherwise its just empty

    // bootstrap data provided by the surrounding app
    var bootstrap = window.coursavenue.bootstrap;

    // Create an instance of your class and populate with the models of your entire collection
    <%= data_source %>                  = new <%= name %>.Models.<%= collection_name(data_source) %>(bootstrap.models, bootstrap.options);
    <%= collection_view_name(data_source).underscore %> = new <%= name %>.Views.<%= collection_name(data_source) %>.<%= collection_view_name(data_source) %>({
        collection: <%= data_source %>,
        events: {
            '<%= data_source %>:go':     'someMethod'
        }
    });

    <%= data_source %>.bootstrap(); // not sure if this will always be applicable
    window.pfaff = <%= data_source %>;

    /* set up the layouts */
    layout           = new <%= name %>.Views.<%= data_source %>Layout();

    /* code to demonstrate initializing some submodules to be added to the layout here */
    // var SubModules = <%= name %>.Views.WidgetsCollection.SubModules;

    // var submodule               = new SubModules.SubModule({});
    // var submodule_with_events   = new SubModules.SubModuleWithEvents({});
    // var submodule_with_selector = new SubModules.SubModuleWithSelector({});

    // <%= name %>.mainRegion.show(layout);

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

    layout.master.show(<%= collection_view_name(data_source).underscore %>); // shouldn't be "results" should be app specific
});

$(document).ready(function() {
    /* we only want <%= name %> on the correct page */
    if (<%= name %>.detectRoot()) {
        <%= name %>.start({});
    }

});
