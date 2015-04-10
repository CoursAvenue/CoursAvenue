FilteredSearch.module('Views.Map', function(Module, App, Backbone, Marionette, $, _) {

    Module.InfoBoxView = CoursAvenue.Views.Map.GoogleMap.InfoBoxView.extend({
        template: FilteredSearch.Views.StructuresCollection.Structure.templateDirname() + 'structure_view',

        onRender: function onRender (){
            this.$('a').removeClass('bordered--bottom soft-half--ends');
            this.$('[data-content]').addClass('soft-half--left');
            this.$('.rslides img').each(function(){
                var $this = $(this);
                $this.closest('.media__item').hide();
                $this.closest('li').css('background-image', 'url("' + $this.attr('src') + '")');
            });

        }
    });
});
