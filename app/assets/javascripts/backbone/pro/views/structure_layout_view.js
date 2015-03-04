AppPro.module('Views', function(Module, App, Backbone, Marionette, $, _) {

  Module.StructureLayoutView = Backbone.Marionette.LayoutView.extend({

    template: Module.templateDirname() + 'structure_layout_view',

    initialize: function initialize () {

    }

  });

  Module.TopBar = Backbone.Marionette.LayoutView.extend({

    template: Module.templateDirname() + 'top_bar',

    initialize: function initialize () {

    }

  });

  Module.SideMenu = Backbone.Marionette.LayoutView.extend({

    template: Module.templateDirname() + 'side_menu',

    serializeData: function serializeData () {

      console.log('Routes', Routes);

      var data = {
          dashboard_user_path: window.coursavenue.bootstrap.root_url
      };

      return data;
    },

    initialize: function initialize () {
      console.log('init sidemenu');
    }

  });

});
