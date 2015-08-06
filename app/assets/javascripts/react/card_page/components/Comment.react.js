var Comment = React.createClass({

    render: function render () {
        var avatar;
        // {this.props.comment.get('certified')}
        if (this.props.comment.get('has_avatar')) {
            avatar = (<img src={this.props.comment.get('avatar_url')} className="center-block push-half--bottom" />);
        } else {
            avatar = (<div className="push-half--bottom"><i className="fa-user-big fa-2x"></i></div>)
        }
        return (
            <div className="grid push--bottom " itemProp='review' itemScope={true} itemType='http://schema.org/Review'>
                <div className="grid__item palm-one-whole one-fifth text--center palm-text--left">
                    <div className="visuallyhidden--palm">
                        { avatar }
                    </div>
                    <div>
                        {this.props.comment.get('author_name')}
                    </div>
                    <div itemProp='datePublished'
                         content={this.props.comment.get('created_at_iso')}
                         className="gray-light">
                        <i>Il y a {this.props.comment.get('distance_of_time')}</i>
                    </div>
                </div>
                <div className="grid__item palm-one-whole four-fifths">
                    <h6 className="push-half--bottom">{this.props.comment.get('title')}</h6>
                    <div dangerouslySetInnerHTML={{__html: this.props.comment.get('simple_format_content') }}>
                    </div>
                    <span title={this.props.comment.get('title')} itemProp='reviewRating' itemScope={true} itemType='http://schema.org/Rating'>
                      <meta itemProp='ratingValue' content={this.props.comment.get('rating') || 5} />
                      <meta itemProp='worstRating' content={1} />
                      <meta itemProp='bestRating' content={5} />
                    </span>
                </div>
            </div>
        );
    }
});

module.exports = Comment;
