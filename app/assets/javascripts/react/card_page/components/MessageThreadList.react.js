var Thread                  = require("./Thread"),
    MessageActionCreators   = require("../actions/MessageActionCreators"),
    StructureActionCreators = require("../actions/StructureActionCreators"),
    MessageThreadStore      = require('../stores/MessageThreadStore');

var MessageThreadList = React.createClass({

    mixins: [ FluxBoneMixin('thread_store') ],

    componentDidMount: function componentDidMount() {
        StructureActionCreators.setStructure(this.props.structure);
    },

    getInitialState: function getInitialState() {
        return { thread_store: MessageThreadStore };
    },

    submitThread: function submitThread () {
        if (CoursAvenue.currentUser().isLogged()) {
            var $textarea = $(this.getDOMNode()).find('textarea');
            MessageActionCreators.submitThread({ message: $textarea.val() });
            $textarea.val('');
        } else {
            CoursAvenue.signUp({
                title: 'Vous devez vous enregistrer pour envoyer votre message',
                success: this.submitThread,
                dismiss: function dismiss() {}
            });
        }
    },

    scrollToTop: function scrollToTop () {
        $.scrollTo(0, { duration: 250 });
    },

    render: function render () {
        var spinner, threads;
        if (this.state.thread_store.loading) {
            var spinner = (<div className="spinner">
                              <div className="double-bounce1"></div>
                              <div className="double-bounce2"></div>
                              <div className="double-bounce3"></div>
                          </div>);
        }
        threads = this.state.thread_store.map(function(thread, index) {
            var hr;
            if (index > 0) { hr = (<hr className="push--ends nine-twelfths margin-left-auto" />); }
            return (<div>
                        {hr}
                        <Thread thread={thread} key={thread.get('id')}/>
                    </div>);
        });
        return (
            <div id="message-thread-list">
                <div className="push-half--bottom">
                    <div>
                        <h3 className="v-middle flush inline-block">
                            Posez une question publique ({ this.state.thread_store.length })
                        </h3>
                        <i className="v-middle delta fa-question-circle" data-toggle="popover" data-content="<div className='f-size-normal'>Questions et témoignages recueillis auprès de la communauté d'élèves.</div>" data-html="true"></i>
                    </div>
                    <div className='epsilon soft-half--ends'>
                        {"Vous pouvez poser vos questions à l'association et à ses pratiquants avant de vous inscrire :"}
                    </div>
                </div>
                <div className='gray-box'>
                    <div className="input flush soft">
                        <textarea name="community_message_thread[message]"
                                  className="one-whole input--large"
                                  data-behavior='autoresize'
                                  placeholder='Posez vos questions ou réponses ici.' />
                    </div>
                    <div className='flexbox soft hard--top'>
                        <div className='flexbox__item one-whole soft--right'>
                            Inutile de poser une question sur les coordonnées de contact&nbsp;:&nbsp;
                            <a href="javascript:void(0)"
                               onClick={this.scrollToTop}>
                               accéder au téléphone et au site Internet
                            </a>
                        </div>
                        <div className='flexbox__item'>
                            <button type="submit"
                                    className="nowrap btn btn--green"
                                    data-disable-with="Message en cours d'envoi..."
                                    onClick={this.submitThread}>
                                Poser ma question
                            </button>
                        </div>
                    </div>
                </div>
                <article className="soft--ends">
                    { spinner }
                    { threads }
                </article>
            </div>
        );
    }
});

module.exports = MessageThreadList;
