
/* just a basic marionette view */
StructurePlanning.module('Views.Structure', function(Module, App, Backbone, Marionette, $, _) {

    Module.StructureView = StructureProfile.Views.Structure.StructureView.extend({
        template: Module.templateDirname() + 'structure_view',

        initialize: function initialize () {
            var $structure_profile_menu = $('#structure-profile-menu');
            this.menu_scrolled_down = false;
            $(window).scroll(function() {
                if (!this.menu_scrolled_down && $(window).scrollTop() > 50 && parseInt($structure_profile_menu.css('top')) != 0 ) {
                    $structure_profile_menu.animate({ 'top': '0' });
                    this.menu_scrolled_down = true;
                } else if ($(window).scrollTop() < 50 && parseInt($structure_profile_menu.css('top')) == 0 ) {
                    $structure_profile_menu.animate({ 'top': '-100px' });
                    this.menu_scrolled_down = false;
                }
            }.bind(this));
            this.initializeContactLink();
        },

    });
});
