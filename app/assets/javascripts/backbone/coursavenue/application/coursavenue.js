
/* this file simply creates a top level Module in which Lib can live */

CoursAvenue = (function (){
    var self = new Backbone.Marionette.Application({
        slug: 'coursavenue'
    });

    return self;
}());

$(document).ready(function() {
    CoursAvenue.start({});
});
