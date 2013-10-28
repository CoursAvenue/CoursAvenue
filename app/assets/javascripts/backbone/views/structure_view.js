/* just a basic marionette view */
FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {

    /* views here temporarily to get this all all started */
    Views.CommentView = Backbone.Marionette.ItemView.extend({
        tagName: "tr",
        template: "backbone/templates/comment_view"
    });

    Views.CommentsCollectionView = Backbone.Marionette.CompositeView.extend({
        template: 'backbone/templates/comments_collection_view',
        tagName: 'table',

        itemView: Views.CommentView,
    });

    Views.SubjectView = Backbone.Marionette.ItemView.extend({
        tagName: "tr",
        template: "backbone/templates/subject_view"
    });

    Views.SubjectsCollectionView = Backbone.Marionette.CompositeView.extend({
        template: 'backbone/templates/subjects_collection_view',
        tagName: 'table',

        itemView: Views.SubjectView,
    });

    Views.StructureView = Views.AccordionItemView.extend({
        template: 'backbone/templates/structure_view',
        tagName: 'li',
        className: 'one-whole course-element',
        attributes: {
            'data-type': 'structure-element'
        },

        initialize: function(options) {
            this.$el.data('url', options.model.get('data_url'));
        },

        events: {
            'click button[data-type=accordion-control]': 'accordionControl',
            'mouseenter': 'highlightStructure',
            'mouseleave': 'unhighlightStructure'
        },

        /* When a button is clicked, accordionControl arranges for a
        *  relation with the given name to be displayed, either by
        *  switching between tabs on the current structure_view or by
        *  deferring to the "accordionOpen" method on super */
        /* in order for accordionControl to work, you need:
        *   - a model with a relation, such as "widgets"
        *   - a backend that returns the right stuff: of course
        *   - a button in templates/structure_view, like this:
        *       <button data-type="accordion-control" data-value="widgets">Whoa!</button>
        *   - two templates: widget_view and a widgets_collection_view
        *
        *   The actual view classes and collection are generated below */
        accordionControl: function (e) {
            e.preventDefault();

            var value = $(e.currentTarget).data('value'),
                self = this;

            /* if no region exists on the structure view, then we need to
            *  fetch the relation, and create a region for it */
            if (this.regions[value] === undefined) {
                /* wait for asynchronous fetch of models before adding region */
                this.model.fetchRelated(value, {}, true)[0].then(function () {
                    self.createRegionFor(value);
                    self.accordionShow(value);
                });
            } else {
                this.accordionShow(value);
            }

            return false;
        },

        /* either switch between tabs on the structure, or defer to
        *  the accordion action */
        accordionShow: function (value) {
            /* replace the existing active region */
            if (this.active_region && this.active_region !== value) {
                this[this.active_region].$el.find('[data-type=accordion-data]').hide();
                this[this.active_region].currentView.$el.attr('data-type', '');
                this[value].currentView.$el.attr('data-type', 'accordion-data');
            }

            /* we tried to switch between regions */
            if (this.accordionOpen() === false) {
                this[value].$el.find('[data-type=accordion-data]').show();
            }

            this.active_region = value;
        },

        /* given a string, find the relation on the model with that name
        *  and create a region, and a view. Attach the view to the region */
        createRegionFor: function (value) {
            this.addRegion(value, "#" + value);
            this.regions[value] = '#' + value;
            this.$el.append('<div id="' + value + '">');

            collection = new Backbone.Collection(this.model.get(value).models);

            /* an anonymous compositeView/itemView is all we need */
            ItemViewClass = Backbone.Marionette.ItemView.extend({
                tagName: "tr",
                template: "backbone/templates/" + value.slice(0, -1) + "_view" // singular name for the view
            });

            ViewClass = Backbone.Marionette.CompositeView.extend({
                template: 'backbone/templates/' + value + '_collection_view',
                tagName: 'table',

                itemView: ItemViewClass,
            });

            view = new ViewClass({
                collection: collection,
                attributes: {
                    'data-type': 'accordion-data',
                    'style': 'display:none'
                }
            });

            this[value].show(view);
        },

        /* return toJSON for the places relation */
        placesToJSON: function () {
            return this.model.getRelation('places').related.models.map(function (model) {
                return _.extend(model.toJSON(), { cid: model.cid });
            });
        },

        /* a structure was selected, so return the places JSON
        * TODO would it be nicer is this just returned the whole model's
        * json, including the places relation? */
        highlightStructure: function (e) {
            this.trigger('highlighted', this.placesToJSON());
        },

        unhighlightStructure: function (e) {
            this.trigger('unhighlighted', this.placesToJSON());
        },

        resolveClick: function (event) {
            if (event.target.nodeName !== 'A') {
                if (event.metaKey || event.ctrlKey) {
                    window.open(this.model.get('data_url'));
                } else {
                    window.location = this.model.get('data_url');
                }
                return false;
            }
        }

    });
});
