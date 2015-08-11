var FilterActionCreators  = require('../actions/FilterActionCreators'),
    CardStore             = require("../stores/CardStore"),
    SubjectSearchInput    = require('./SubjectSearchInput.react'),
    FluxBoneMixin         = require("../../mixins/FluxBoneMixin");

var Menubar = React.createClass({

    mixins: [
        FluxBoneMixin('card_store')
    ],

    getInitialState: function getInitialState () {
        return {
            context: 'course',
            card_store: CardStore
        };
    },

    componentDidMount: function componentDidMount () {
        CoursAvenue.initializeUserNav();
    },

    changeContext: function changeContext () {
        var context = this.newContext();
        this.setState({ context: context });
        FilterActionCreators.changeContext(context);
        return false;
    },

    selectedTitle: function selectedTitle () {
        return ((this.state.card_store.context || this.state.context) == 'course' ? 'Cours' : 'Stages');
    },

    newContext: function newContext () {
        return ((this.state.card_store.context || this.state.context) == 'course' ? 'training' : 'course');
    },

    newContextTitle: function newContextTitle () {
        return ((this.state.card_store.context || this.state.context) == 'course' ? 'Stages' : 'Cours');
    },

    render: function render () {
        var new_context_url = location.pathname + '?type=' + this.newContext();
        return (
            <div className='bg-white search-page-map__menu-bar'>
                <div className='flexbox palm-block'>
                    <div className='flexbox__item palm-block v-middle nowrap'>
                        <div className="coursavenue-header-logo-wrapper v-middle">
                            <a className="coursavenue-header-logo" href="/"></a>
                        </div>
                        <div className="soft--left v-middle inline-block drop-down__wrapper search-page__menu-context">
                            <span>{this.selectedTitle()}</span>
                            <i className="fa fa-chevron-down blue-green"></i>
                            <div className="drop-down__el drop-down__el--appears-on-text">
                                <ul className="drop-down__el-inner-box text--left">
                                    <li className="nowrap">
                                        <a href='javascript:void(0)'>
                                           {this.selectedTitle()}
                                           <i className="fa fa-chevron-down"></i>
                                        </a>
                                    </li>
                                    <li className="nowrap">
                                        <a href={new_context_url} className=""
                                           onClick={this.changeContext}>
                                           {this.newContextTitle()}
                                        </a>
                                    </li>
                                </ul>
                            </div>
                        </div>
                    </div>
                    <div className='flexbox__item palm-block v-middle text--right one-whole soft--right palm-hard palm-text--center'>
                        <SubjectSearchInput key="menu-bar" />
                    </div>
                    <div className='flexbox__item visuallyhidden--palm palm-block v-middle text--right nowrap'>
                        <div id='user-nav'></div>
                    </div>
                </div>
            </div>
        );
    },
});

module.exports = Menubar;
