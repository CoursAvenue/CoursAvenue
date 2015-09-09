var cx                      = require('classnames/dedupe'),
    CourseStore             = require('../stores/CourseStore'),
    FluxBoneMixin           = require('../../mixins/FluxBoneMixin'),
    StructureStore          = require('../stores/StructureStore'),
    CourseActionCreators    = require('../actions/CourseActionCreators'),
    StructureActionCreators = require('../actions/StructureActionCreators');

var Favorite = React.createClass({
    mixins: [
        FluxBoneMixin(['course_store', 'structure_store'])
    ],

    // Bootstrap.
    componentWillMount: function componentWillMount () {
        if (!this.props.favorited) { return ; }

        if (this.props.type == 'indexable_card') {
            CourseStore.first().set('favorited', true);
        } else {
            StructureStore.set('favorited', true);
        }
    },

    isFavorited: function isFavorited () {
        if (this.props.type == 'indexable_card') {
            return CourseStore.first() && CourseStore.first().get('favorited');
        } else {
            return StructureStore.get('favorited');
        }
    },

    getInitialState: function getInitialState () {
        return {
            logged_in:       this.props.logged_in,
            course_store:    CourseStore,
            structure_store: StructureStore,
        };
    },

    toggleFavorite: function toggleFavorite () {
        if (!this.state.logged_in) {
            return this.logIn();
        }

        var creator = (this.props.type == 'indexable_card' ? CourseActionCreators : StructureActionCreators);

        var course_id = CourseStore.first() ? CourseStore.first().get('id') : null;
        if (this.isFavorited()) {
            creator.removeFromFavorites(StructureStore.get('id'), course_id);
        } else {
            creator.addToFavorites(StructureStore.get('id'), course_id);
        }
    },

    logIn: function logIn () {
        CoursAvenue.signIn({
            success: function success () { location.reload(); }
        });
    },

    favText: function favText () {
        return (this.isFavorited() ? 'Retirer des favoris' : 'Ajouter aux favoris');
    },

    render: function render () {
        var iconClasses = cx('fa push-half--right', {
            'red':        this.isFavorited(),
            'fa-heart':   this.isFavorited(),
            'fa-heart-o': !this.isFavorited(),
        });

        var page_type = (this.props.type == 'indexable_card' ? 'ce cours' : 'cette page');

        return (
            <a href='javascript:void(0)' className='btn btn--white btn--full push--bottom' onClick={ this.toggleFavorite }>
                <i className={ iconClasses + ' line-height-normal epsilon v-middle' }></i>
                <span className="v-middle">{this.favText()}</span>
            </a>
        );
    }
});

module.exports = Favorite;
