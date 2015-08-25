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
            return this.showConnectionPrompt();
        }

        var creator = (this.props.type == 'indexable_card' ? CourseActionCreators : StructureActionCreators);

        var course_id = CourseStore.first() ? CourseStore.first().get('id') : null;
        if (this.isFavorited()) {
            creator.removeFromFavorites(StructureStore.get('id'), course_id);
        } else {
            creator.addToFavorites(StructureStore.get('id'), course_id);
        }
    },

    showConnectionPrompt: function showConnectionPrompt () {
        $(this.getDOMNode()).find('#connection-prompt').slideDown();
    },

    logIn: function logIn () {
        CoursAvenue.signIn({
            success: function success () { location.reload(); }
        });
    },

    render: function render () {
        var iconClasses = cx('fa push--right', {
            'red':        this.isFavorited(),
            'fa-heart':   this.isFavorited(),
            'fa-heart-o': !this.isFavorited(),
        });

        var page_type = (this.props.type == 'indexable_card' ? 'ce cours' : 'cette page');

        return (
            <div className='bg-white bordered push--bottom soft text--center'>
                <a href='javascript:void(0)' className='delta flush' onClick={ this.toggleFavorite }>
                    <i className={ iconClasses }></i>
                    Ajouter aux favoris
                </a>
                <div id='connection-prompt' className='hidden'>
                    <h4>Veuillez <a href='javascript:void(0)' onClick={ this.logIn } >vous connecter</a> pour ajouter { page_type } en favoris.</h4>
                </div>
            </div>
        );
    }
});

module.exports = Favorite;
