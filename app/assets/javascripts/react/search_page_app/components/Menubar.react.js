var FilterActionCreators  = require('../actions/FilterActionCreators'),
    CardStore             = require("../stores/CardStore"),
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
                <div className='grid'>
                    <div className='grid__item one-half v-middle'>
                        <div className="coursavenue-header-logo-wrapper v-middle">
                            <a className="coursavenue-header-logo" href="/"></a>
                        </div>
                        <div className="soft--left v-middle inline-block drop-down__wrapper search-page__menu-context">
                            <span>{this.selectedTitle()}</span>
                            <i className="fa fa-chevron-down"></i>
                            <div className="drop-down__el">
                                <ul className="drop-down__el-inner-box text--left">
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
                    <div className='grid__item one-half v-middle text--right'>
                    </div>
                </div>
            </div>
        );
    },
});

module.exports = Menubar;
