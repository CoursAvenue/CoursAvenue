# encoding: utf-8
class Admin::ConversationsController < Admin::AdminController
  def index
    if params[:info]
      @conversations = Mailboxer::Conversation.
        where(mailboxer_label_id: [Mailboxer::Label::REQUEST.id, Mailboxer::Label::INFORMATION.id]).
        order('created_at DESC')
    else
      @conversations = Mailboxer::Conversation.order('created_at DESC')
    end
    @conversations = Kaminari.paginate_array(@conversations).page(params[:page] || 1).per(20)
  end
end
