var Thread                  = require("./Thread"),
    MessageActionCreators   = require("../actions/MessageActionCreators"),
    StructureActionCreators = require("../actions/StructureActionCreators"),
    StructureStore          = require('../stores/StructureStore'),
    MessageThreadStore      = require('../stores/MessageThreadStore');

var MessageThreadList = React.createClass({

    mixins: [ FluxBoneMixin('thread_store') ],

    componentDidMount: function componentDidMount() {
        var $textarea = $(this.getDOMNode()).find('textarea');
        $textarea.textareaResizer();
        StructureActionCreators.setStructure(this.props.structure);
    },

    getInitialState: function getInitialState() {
        return { thread_store: MessageThreadStore, structure_store: StructureStore };
    },

    submitThread: function submitThread () {
        var $textarea = $(this.getDOMNode()).find('textarea');
        if ($textarea.val().length == 0) { return; }
        if (CoursAvenue.currentUser().isLogged()) {
            MessageActionCreators.submitThread({ message: $textarea.val(), indexable_card_id: this.props.indexable_card_id });
            $textarea.val('');
            $.magnificPopup.close();
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
        var threads, button_content = 'Poser ma question'
        if (this.state.thread_store.loading) {
            button_content = (<div className="spinner">
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
            <div id="messages-publics">
                <h2 className="bg-pink bordered--sides bordered--top border-color-pink-darker soft--sides soft-half--ends white flush">
                    <i className="fa-quotes v-middle"></i>&nbsp;
                    <span className="v-middle">
                        Questions à la communauté ({ this.state.thread_store.length })
                    </span>
                </h2>
                <div className="bg-white bordered--sides bordered--bottom soft--sides soft--bottom">
                    <div className='epsilon soft--ends'>
                        {"Posez ici vos questions concernant " + this.state.structure_store.get('name') + " ou l’activité qui vous intéresse. Le professeur ou d’autres élèves comme vous pourront y répondre."}
                    </div>
                    <div className="input flush">
                        <textarea name="community_message_thread[message]"
                                  className="one-whole input--large"
                                  data-behavior='autoresize'
                                  placeholder='Posez vos questions ou réponses ici.' />
                    </div>
                    <div className="soft-half--top">
                        <button type="submit"
                                className="nowrap btn palm-one-whole palm-push--top btn--white"
                                data-disable-with="Message en cours d'envoi..."
                                onClick={this.submitThread}>
                            { button_content }
                        </button>
                    </div>
                    <article className={(threads.length > 0 ? "soft hard--bottom" : '')}>
                        { threads }
                    </article>
                </div>
            </div>
        );
    }
});

module.exports = MessageThreadList;
