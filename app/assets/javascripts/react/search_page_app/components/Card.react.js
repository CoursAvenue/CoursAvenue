var Card = React.createClass({
    render: function render () {
        var classes = this.props.classes +
            " search-page-card soft-half palm-one-whole lap-one-third inline-block v-top";

        var children = [this.props.children];
        if (this.props.index) {
            children.unshift(
                <div className="search-page-card__number" key={ children.length }>{ this.props.index }.</div>
            )
        } else {
            children.unshift(
                <div className="search-page-card__number" key={ children.length }>&nbsp;</div>
            )
        }

        children = _.flatten(children);

        return (
            <div onMouseEnter={ this.props.onMouseEnter }
                 onMouseLeave={ this.props.onMouseLeave }
                 onClick={ this.props.onClick }
                 className={ classes }>
                { children }
            </div>
        );
    },
});

module.exports = Card;
