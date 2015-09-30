# encoding: utf-8
class Pro::Blog::SubscribersController < Pro::PublicController

  def create
    respond_to do |format|
      if ::Blog::Subscriber::ProSubscriber.where(email: params[:blog_subscriber][:email]).first_or_create.persisted?
        format.html { redirect_to((request.referer || pro_blog_articles_path),
                                  notice: 'Vous êtes inscrit à notre newsletter !') }
      else
        format.html { redirect_to((request.referer || pro_blog_articles_path),
                                  alert: 'Votre e-mail est incorrect.') }
      end
    end
  end
end
