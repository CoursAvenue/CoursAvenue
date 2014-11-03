# encoding: utf-8
class Pro::ConversationsController < Pro::ProController
  before_action :authenticate_pro_admin!

  layout 'admin'

  def index
    if params[:info]
      @conversations = Mailboxer::Conversation.where(Mailboxer::Conversation.arel_table[:mailboxer_label_id].eq_any([Mailboxer::Label::REQUEST.id, Mailboxer::Label::INFORMATION.id])).order('updated_at DESC')
    else
      @conversations = Mailboxer::Conversation.order('updated_at DESC')
    end
    @conversations = Kaminari.paginate_array(@conversations).page(params[:page] || 1).per(20)
  end
end
