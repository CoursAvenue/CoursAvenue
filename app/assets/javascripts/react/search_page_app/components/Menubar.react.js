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

    changeContext: function changeContext (event) {
        var context = event.target.value;
        this.setState({ context: context });
        FilterActionCreators.changeContext(context);
    },

    render: function render () {
        return (
            <div className='bg-white search-page-map__menu-bar'>
                <div className='grid'>
                    <div className='grid__item one-half v-middle'>
                        <div className="coursavenue-header-logo-wrapper v-middle">
                            <a className="coursavenue-header-logo" href="/"></a>
                        </div>
                        <div className="soft--left v-middle inline-block">
                            <select value={ this.state.card_store.context || this.state.context } onChange={ this.changeContext } >
                                <option value="course">Cours</option>
                                <option value="training">Stages</option>
                            </select>
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
