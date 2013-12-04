
/* this file simply creates a top level Module in which Lib can live */

CoursAvenue = new Backbone.Marionette.Application({ slug: 'coursavenue' });

$(document).ready(function() {
    CoursAvenue.start({});
});
