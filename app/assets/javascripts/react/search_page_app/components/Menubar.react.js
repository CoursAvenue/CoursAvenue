var FilterActionCreators = require('../actions/FilterActionCreators');

var Menubar = React.createClass({
    getInitialState: function getInitialState () {
        return { context: 'lesson' };
    },

    changeContext: function changeContext (event) {
        var context = event.target.value;
        this.setState({ context: context });
        debugger
        FilterActionCreators.changeContext(context);
    },

    render: function render () {
        return (
            <div className='text--center soft-half bordered--top bordered--bottom bg-white'>
                <div className='main-container grid'>
                    <div className='grid__item v-middle two-twelfths'>
                        <a href="/">CoursAvenue</a>
                    </div>
                    <div className='grid__item v-middle two-twelfths'>
                        <select value={ this.state.context } onChange={ this.changeContext } >
                            <option value="lesson">Cours</option>
                            <option value="training">Stages</option>
                        </select>
                    </div>
                </div>
            </div>
        );
    },
});

module.exports = Menubar;
