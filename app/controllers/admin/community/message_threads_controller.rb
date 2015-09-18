class Admin::Community::MessageThreadsController < ApplicationController
  before_action :authenticate_pro_super_admin!

  layout 'admin'

  def index
    @message_threads = ::Community::MessageThread.includes(:conversation).order('created_at DESC').
      page(params[:page] || 1)
  end

  def approve
    @message_thread = ::Community::MessageThread.find(params[:id])
    @message_thread.approve!

    redirect_to admin_community_message_threads_path, notice: 'Question approuvé avec succés.'
  end

  def privatize
    @message_thread = ::Community::MessageThread.
      includes(:community, :conversation).find(params[:id])
    @message_thread.privatize!

    # TODO: Send email to teacher.
    MailboxerMessageMailer.delay(queue: 'mailers').new_message_email_to_admin(
      @message_thread.messages.first, @message_thread.community.structure.admin)

    redirect_to admin_community_message_threads_path, notice: 'Question envoyée avec succés.'
  end

  def destroy
    @message_thread = ::Community::MessageThread.find(params[:id])

    respond_to do |format|
      if @message_thread.destroy
        format.html { redirect_to admin_community_message_threads_path,
                      notice: 'Question supprimée avec succés.' }
      else
        format.html { redirect_to admin_community_message_threads_path,
                      error: 'Une erreur est survenue, veuillez rééssayer.' }
      end
    end
  end
end
