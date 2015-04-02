FilteredSearch.module('Views.Map', function(Module, App, Backbone, Marionette, $, _) {

    Module.InfoBoxView = CoursAvenue.Views.Map.GoogleMap.InfoBoxView.extend({
        template: FilteredSearch.Views.StructuresCollection.Structure.templateDirname() + 'structure_view',

        onRender: function onRender (){
            this.$('a').removeClass('bordered--bottom soft-half--ends');
            this.$('[data-content]').addClass('soft-half--left');
            var self = this;
            setTimeout(function(){
                // Start slideshow
                // Removing images and adding the image url to background image in order to have the image being covered
                self.$('.rslides img').each(function(){
                    var $this = $(this);
                    $this.closest('.media__item').hide();
                    $this.closest('li').css('background-image', 'url("' + $this.attr('src') + '")');
                });
                self.$(".rslides").responsiveSlides({
                    auto: false,
                    nav: true,
                    prevText: '<i class="alpha fa fa-chevron-left"></i>',
                    nextText: '<i class="alpha fa fa-chevron-right"></i>'
                });
                COURSAVENUE.initialize_fancy(self.$('.rslides-wrapper [data-behavior="fancy"]'));
            });

        }
    });
});
