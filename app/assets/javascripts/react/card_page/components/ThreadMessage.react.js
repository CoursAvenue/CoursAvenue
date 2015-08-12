var _                     = require('lodash'),
    MessageActionCreators = require("../actions/MessageActionCreators"),
    ThreadMessage         = require("./ThreadMessage");

var ThreadMessage = React.createClass({

    getInitialState: function getInitialState() {
        return { show_reply_form: false };
    },

    submitReplyToThread: function submitReplyToThread () {
        if (CoursAvenue.currentUser().isLogged()) {
            var $textarea = $(this.getDOMNode()).find('textarea');
            MessageActionCreators.replyToThread({ id: this.props.message.thread_id, message: $textarea.val() });
            $textarea.parent().slideUp();
        } else {
            CoursAvenue.signUp({
                title: 'Vous devez vous enregistrer pour envoyer votre message',
                success: this.submitReplyToThread,
                dismiss: function dismiss() {}
            });
        }
    },

    showReplyForm: function showReplyForm () {
        this.setState({ show_reply_form: true });
    },

    render: function render () {
        var answer_section, answers, avatar, reply_form, reply_link,
            avatar_size = '60',
            content_class = '';
        // To be sure this is not an "answer"
        if (this.props.answers) {
            content_class = 'delta line-height-1-3';
            avatar_size   = '80';
            answers = _.map(this.props.answers, function(message) {
                return (<ThreadMessage message={message} />);
            });
            if (this.state.show_reply_form == false) {
                reply_link = (<a onClick={this.showReplyForm} className="btn btn--small btn--white">
                                 Répondre à {this.props.message.author_name}
                              </a>);
            }
            if (answers.length > 0) {
                answers = (<div>
                                <div className="epsilon push-half--bottom">
                                    <strong>
                                        Réponses ({this.props.answers.length})
                                    </strong>
                                </div>
                                {answers}
                           </div>);
            }
            answer_section = (<div>
                                  {answers}
                                  {reply_link}
                              </div>)
        }
        if (this.state.show_reply_form) {
            reply_form = (<div>
                              <textarea className="one-whole input--large"
                                        placeholder={'Répondez à ' + this.props.message.author_name} />
                              <div className="text--right very-soft--top">
                                  <a onClick={this.submitReplyToThread} className="btn btn--small btn--blue-green">
                                     Publier ma réponse
                                  </a>
                              </div>
                          </div>);
        }
        if (this.props.message.has_avatar) {
            avatar = (<img src={this.props.message.avatar_url}
                           className="center-block push-half--bottom rounded--circle"
                           height={avatar_size} width={avatar_size} />);
        } else {
            avatar = (<div className={"push-half--bottom comment-avatar-" + avatar_size}></div>)
        }
        return (
            <article className="grid push--bottom " itemProp='review' itemScope={true} itemType='http://schema.org/Comment'>
                <div className="grid__item palm-one-whole text--center palm-text--left three-twelfths">
                    <div className="visuallyhidden--palm">
                        { avatar }
                    </div>
                    <div className="line-height-1-5">
                        <strong>{this.props.message.author_name}</strong>
                    </div>

                </div>
                <div className="grid__item palm-one-whole nine-twelfths soft-half--top">
                    <div className={content_class}
                         dangerouslySetInnerHTML={{__html: this.props.message.content }}></div>
                    { answer_section }
                    { reply_form }
                </div>
            </article>
        );
    }
});

module.exports = ThreadMessage;
