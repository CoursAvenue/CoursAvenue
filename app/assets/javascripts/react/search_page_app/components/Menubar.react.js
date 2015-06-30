var FilterActionCreators = require('../actions/FilterActionCreators');

var Menubar = React.createClass({
    getInitialState: function getInitialState () {
        return { context: 'course' };
    },

    changeContext: function changeContext (event) {
        var context = event.target.value;
        this.setState({ context: context });
        FilterActionCreators.changeContext(context);
    },

    render: function render () {
        return (
            <div className='bg-white'>
                <div className='grid'>
                    <div className='grid__item one-half v-middle'>
                        <div className="coursavenue-header-logo-wrapper v-middle">
                            <a className="coursavenue-header-logo" href="/"></a>
                        </div>
                        <div className="soft--left v-middle inline-block">
                            <select value={ this.state.context } onChange={ this.changeContext } >
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
