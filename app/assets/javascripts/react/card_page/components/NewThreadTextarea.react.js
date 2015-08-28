var Thread                  = require("./Thread"),
    MessageActionCreators   = require("../actions/MessageActionCreators"),
    StructureActionCreators = require("../actions/StructureActionCreators"),
    MessageThreadStore      = require('../stores/MessageThreadStore');

var MessageThreadList = React.createClass({

    mixins: [ FluxBoneMixin('thread_store') ],

    getInitialState: function getInitialState() {
        return { thread_store: MessageThreadStore };
    },

    componentDidMount: function componentDidMount() {
        var $textarea = $(this.getDOMNode()).find('textarea');
        $textarea.textareaResizer();
        if (this.props.structure) {
            StructureActionCreators.setStructure(this.props.structure);
        }
    },

    submitThread: function submitThread () {
        var $textarea = $(this.getDOMNode()).find('textarea');
        if ($textarea.val().length == 0) { return; }
        if (CoursAvenue.currentUser().isLogged()) {
            MessageActionCreators.submitThread({ message: $textarea.val(), indexable_card_id: this.props.indexable_card_id });
            $textarea.val('');
            $.magnificPopup.close();
            $.scrollTo($('#messages-publics'), { duration: 300, offset: { top: -55} });
        } else {
            CoursAvenue.signUp({
                title: 'Vous devez vous enregistrer pour envoyer votre message',
                success: this.submitThread,
                dismiss: function dismiss() {}
            });
        }
    },

    render: function render () {
        var button_content = 'Poser ma question'
        if (this.state.thread_store.loading) {
            button_content = (<div className="spinner">
                                  <div className="double-bounce1"></div>
                                  <div className="double-bounce2"></div>
                                  <div className="double-bounce3"></div>
                              </div>);
        }
        this.props.button_class = this.props.button_class || "nowrap btn palm-one-whole palm-push--top btn--white";
        return (<div>
                    <div className="input flush">
                        <textarea name="community_message_thread[message]"
                                  className="one-whole input--large"
                                  data-behavior='autoresize'
                                  placeholder='Posez vos questions ici.' />
                    </div>
                    <div className="soft-half--top">
                        <button type="submit"
                                className={this.props.button_class}
                                data-disable-with="Message en cours d'envoi..."
                                onClick={this.submitThread}>
                            { button_content }
                        </button>
                    </div>
                </div>
        );
    }
});

module.exports = MessageThreadList;
