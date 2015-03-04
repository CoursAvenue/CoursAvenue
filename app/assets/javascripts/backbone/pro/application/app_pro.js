AppPro = new Backbone.Marionette.Application({ slug: 'pro' });

AppPro.addRegions({
  mainRegion      : '#main-content',
  topBarRegion    : '#top-bar',
  sideMenuRegion  : '#side-menu'
});

AppPro.addInitializer(function(options) {
  var topBar          = new AppPro.Views.TopBar();
  var sideMenu        = new AppPro.Views.SideMenu();

  this.topBarRegion.show(topBar);
  this.sideMenuRegion.show(sideMenu);

  new AppProRouter();
  Backbone.history.start({ pushState: true, root: window.coursavenue.bootstrap.root_url });

});


$(document).ready(function() {
    if (AppPro.detectRoot()) {
        AppPro.start({});
    }
});
