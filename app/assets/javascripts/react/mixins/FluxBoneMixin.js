module.exports = function (prop_name) {
    return {
        componentDidMount: function componentDidMount () {
            this.props[prop_name].on('all', function() {
                this.forceUpdate();
            }.bind(this));
        },
        componentWillUnmount: function componentWillUnmount () {
            this.props[prop_name].off('all', function() {
                this.forceUpdate();
            }.bind(this))
        }
    };
};
