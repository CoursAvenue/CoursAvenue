var Thread                = require("./Thread"),
    MessageActionCreators = require("../actions/MessageActionCreators"),
    MessageThreadStore    = require('../stores/MessageThreadStore');

var MessageThreadList = React.createClass({

    mixins: [
        FluxBoneMixin('thread_store')
    ],

    componentDidMount: function componentDidMount() {
        MessageActionCreators.setStructureSlug(this.props.structure_slug)
    },

    getInitialState: function getInitialState() {
        return { thread_store: MessageThreadStore };
    },

    render: function render () {
        var spinner, threads, no_threads;
        if (this.state.thread_store.loading) {
            var spinner = (<div className="spinner">
                              <div className="double-bounce1"></div>
                              <div className="double-bounce2"></div>
                              <div className="double-bounce3"></div>
                          </div>);
        } else {
            comment_title = this.state.thread_store.total + ' avis';
            threads = this.state.thread_store.map(function(thread) {
                return (<Thread thread={thread} key={thread.get('id')}/>);
            });
        }
        return (
            <div>
                { spinner }
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
                <form action="{ Routes.structure_community_message_threads_path(this.state.thread_store.structure_id); }"
                      method='POST'>
                    <div className='gray-box'>
                        <div className="input flush soft">
                            <textarea name="community_message_thread[message]"
                                      className="one-whole input--large"
                                      data-behavior='autoresize'
                                      placeholder='Posez vos questions ou réponses ici.'>
                             </textarea>
                        </div>
                        <div className='flexbox soft'>
                            <div className='flexbox__item one-whole soft--right'>
                                Inutile de poser une question sur les coordonnées de contact : <a href=''>accéder au téléphone et au site Internet</a>
                            </div>
                            <div className='flexbox__item'>
                                <button type="submit" className="nowrap btn btn--green" data-disable-with="Message en cours d'envoi...">
                                    Poser une question
                                </button>
                            </div>
                        </div>
                    </div>
                </form>
                <article className="soft--sides">
                    { no_threads }
                    { threads }
                </article>
            </div>
        );
    }
});

module.exports = MessageThreadList;
