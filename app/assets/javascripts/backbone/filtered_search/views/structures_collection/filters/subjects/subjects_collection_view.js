FilteredSearch.module('Views.StructuresCollection.Filters.Subjects', function(Module, App, Backbone, Marionette, $, _) {

    var ACTIVE_CLASS = 'btn--blue-green subject-active';

    Module.SubjectsCollectionView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'subjects_collection_view',

        childView: Module.SubjectChildrenView,
        childViewContainer: '[data-type="subject-children-view"]',
        breadcrumb_template: Handlebars.compile('<li><a data-depth="{{depth}}" data-root-subject-slug="{{root_subject_slug}}" data-type="breadcrumb" class="cursor-pointer" data-value="{{slug}}" href="{{href}}">{{name}}</a></li>'),

        initialize: function initialize () {
            this.menu_items = {};
            this.collection.each(function(model) {
                var menu_item = new this.childView({ model: model });
                this.menu_items[model.get('slug')] =  menu_item;
                menu_item.on('filter:subject', function(data) {
                    this.announceSubject(data);
                    this.activateButton(data.root_subject_id);
                }.bind(this));
            }, this);
            _.bindAll(this, 'showSubjectBreadcrumb');
        },

        setup: function setup (data) {
            this.activateButton(data.root_subject_id);
            this.current_subject_slug                                        = data.subject_id;
            this.menu_items[data.root_subject_id].current_subject_slug       = data.subject_id;
            this.menu_items[data.root_subject_id].selected_parent_subject_id = data.parent_subject_id;
            // Re render to select slug because the menu is render before the setup happens
            this.menu_items[data.root_subject_id].render();
            var root_subject = this.collection.where({slug: data.root_subject_id})[0];
            this.showSubjectBreadcrumb(data);
            if (root_subject) {
                this.updateSubjectGrandChildren(root_subject, this.showSubjectBreadcrumb, data)
            }
        },

        ui: {
            '$buttons'            : '[data-type=button]',
            '$buttons_wrapper'    : '[data-type=button-wrapper]',
            '$menu'               : '[data-type=menu]',
            '$subjects_breadcrumb': '[data-type=subjects-breadcrumb]'
        },

        events: {
            'mouseenter @ui.$buttons_wrapper': 'showMenu',
            'mouseleave @ui.$buttons_wrapper': 'hideMenu',
            'click [data-type=button]'       : 'announce',
            'click [data-type=breadcrumb]'   : 'announceBreadcrumb'
        },

        onRender: function onRender () {
            _.each(this.menu_items, function(menu_item, subject_slug) {
                this.$(this.childViewContainer).append(menu_item.render().el);
            }, this);
        },

        announceBreadcrumb: function announceBreadcrumb (event) {
            if (window.history.pushState) { window.history.pushState('', '', event.currentTarget.pathname) };
            var clicked_subject_slug, root_subject, root_subject_slug, depth, clicked_model;
            clicked_subject_slug                = event.currentTarget.dataset.value;
            root_subject_slug                   = event.currentTarget.dataset.rootSubjectSlug;
            depth                               = event.currentTarget.dataset.depth;
            if (this.current_subject_slug == clicked_subject_slug) { return; }
            this.current_subject_slug = clicked_subject_slug;
            root_subject = this.collection.where({slug: (root_subject_slug || clicked_subject_slug)})[0];
            // If it's a clicked slug is root, announce it
            if (depth == '0') {
                this.announceSubject({ subject_id: root_subject.get('slug'), root_subject_id: root_subject.get('slug')})
            // Else if it's a parent - depth 1
            } else {
                clicked_model = _.select(root_subject.get('children'), function(children) { return children.slug == clicked_subject_slug })[0];
                this.announceSubject({ subject_id: clicked_model.slug,
                                       root_subject_id: root_subject.get('slug'),
                                       parent_subject_id: clicked_model.slug })
            }
            return false;
        },

        /* When a user clicks on one of the icons, if the icon is not currently
         * "irrelevant", then we will activate that icon and try to fetch grand_children
         * for the relevant subject.
         */
        announce: function announce (event) {
            event.stopPropagation();
            if (window.history.pushState) { window.history.pushState('', '', event.currentTarget.pathname) };
            this.hideMenu();
            if (event) {
                var subject_slug = event.currentTarget.dataset.value;
            } else {
                var subject_slug = this.$('.' + ACTIVE_CLASS + '[data-type="button"]').data('value');
            }

            if (subject_slug && this.$('[data-value=' + subject_slug + ']').hasClass(ACTIVE_CLASS)) {
                this.current_subject_slug = null;
                this.disabledButton(subject_slug);
                this.announceSubject();
            } else {
                this.current_subject_slug = subject_slug;
                this.activateButton(subject_slug);
                this.announceSubject();
            }
            return false;
        },

        announceSubject: function announceSubject (data) {
            data = data || { subject_id: this.current_subject_slug, root_subject_id: this.current_subject_slug };
            var menu_item = this.menu_items[data.root_subject_id];
            menu_item.current_subject_slug       = data.subject_id;
            menu_item.selected_parent_subject_id = data.parent_subject_id;
            menu_item.render();
            this.trigger("filter:subject", data);
            this.showSubjectBreadcrumb(data);
        }.debounce(GLOBAL.DEBOUNCE_DELAY),

        /*
         * @args data: {
         *          subject_id: 'danses-du-monde',
         *          root_subject_id: 'danse',
         *          parent_subject_id: 'danses-orientales'
         *       }
         */
        showSubjectBreadcrumb: function showSubjectBreadcrumb (data) {
            var parent_subject, child_subject;
            this.ui.$subjects_breadcrumb.empty();
            this.ui.$subjects_breadcrumb.show();
            if (_.isEmpty(data.subject_id)) { this.ui.$subjects_breadcrumb.hide(); return; }
            current_model = this.collection.where({slug: data.root_subject_id || data.subject_id})[0];
            if (!current_model) { return; }
            this.ui.$subjects_breadcrumb.append($(this.breadcrumb_template(_.extend(current_model.toJSON(), { depth: '0', href: Routes.root_search_page_path(current_model.get('slug'), window.coursavenue.bootstrap.city_id) }))));

            // Return if selected subject is root or subject_id is nil
            if (data.root_subject_id == data.subject_id) { return; }
            // parent_subject = _.select(current_model.get('children'), function(children) { return children.slug == data.parent_subject_id })[0] || {};
            parent_subject = _.select(current_model.get('children'), function(children) { return (children.slug == data.subject_id) || (children.slug == data.parent_subject_id) })[0];
            _.extend(parent_subject, { depth: '1', root_subject_slug: current_model.get('slug'), href: Routes.search_page_path(current_model.get('slug'), parent_subject.slug, window.coursavenue.bootstrap.city_id) });
            var to_append = $(this.breadcrumb_template(parent_subject));
            this.ui.$subjects_breadcrumb.append(to_append);

            if (data.parent_subject_id == data.subject_id) { return; }
            child_subject = _.select(parent_subject.children, function(children) { return children.slug == data.subject_id })[0];
            this.ui.$subjects_breadcrumb.append($(this.breadcrumb_template(_.extend(child_subject, { href: Routes.search_page_path(current_model.get('slug'), child_subject.slug, window.coursavenue.bootstrap.city_id) }))));
        },

        updateSubjectGrandChildren: function updateSubjectGrandChildren (model, callback, callback_data) {
            if (!model.get('children')) {
                model.fetch( { success: function(model, response, options){
                                   this.menu_item.trigger('fetch:done');
                                   if (callback) { callback(callback_data); }
                               }.bind(this)
                            } );

            }
        },

        hideMenu: function hideMenu (event) {
            this.ui.$menu.hide();
            _.each(this.menu_items, function(menu_item) {
                menu_item.$el.hide();
            });
        },

        showMenu: function showMenu (event) {
            var $currentTarget = $(event.currentTarget);
            current_model = this.collection.where({slug: $currentTarget.data('value')})[0];
            this.updateSubjectGrandChildren(current_model);
            // Show menu only if changing subject
            this.menu_items[current_model.get('slug')].$el.show();
            $currentTarget.append(this.ui.$menu);
            this.ui.$menu.show();
            // TODO here
            if (document.body.offsetWidth - $currentTarget.offset().left < this.ui.$menu.width()) {
                this.ui.$menu.css({right: 0, left: 'auto'});
            } else {
                var offset_left = $currentTarget.offset().left - $('[data-value="dessin-peinture-arts-plastiques"]').first().closest('[data-type=subjects-collection]').offset().left + 1;
                this.ui.$menu.css({left: offset_left, right: 'auto'});
            }
        },

        // Clears all the given filters
        clear: function clear () {
            this.previous_searched_name = null;
            this.announce();
        },

        disabledButton: function disabledButton (subject_slug) {
            if (subject_slug) {
                this.$('[data-value=' + subject_slug + ']').removeClass(ACTIVE_CLASS);
            }
        },

        activateButton: function activateButton (subject_slug) {
            this.$('[data-type="button"]').removeClass(ACTIVE_CLASS);
            if (subject_slug) {
                this.$('[data-type="button"][data-value=' + subject_slug + ']').addClass(ACTIVE_CLASS);
            }
        },
        serializeData: function serializeData () {
            return { city_id: window.coursavenue.bootstrap.city_id };
        }
    });
});
