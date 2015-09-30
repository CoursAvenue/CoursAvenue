require 'rails_helper'

describe Pro::Blog::SubscribersController do
  describe '#create' do
    context 'when there the user is not subscribed' do
      it 'creates a new blog subscriber' do
        expect { post :create, valid_params }.
          to change { Blog::Subscriber::ProSubscriber.count }.by(1)
      end
    end

    context 'when there the user is subscribed' do
      it 'does not create a subscriber' do
        email = Faker::Internet.email
        _subscriber = Blog::Subscriber::ProSubscriber.create(email: email)
        expect { post :create, valid_params(email) }.
          to_not change { Blog::Subscriber::ProSubscriber.count }
      end
    end

    context 'when there is not referer' do
      it 'redirects to the blog article page' do
        post :create, valid_params

        expect(response).to redirect_to(pro_blog_articles_path)
      end
    end

    context 'when there is a referer' do
      it 'redirects to the referer' do
        referer_url = Faker::Internet.url
        request.env['HTTP_REFERER'] = referer_url
        post :create, valid_params

        expect(response).to redirect_to(referer_url)
      end
    end

  end

  def valid_params(email = Faker::Internet.email)
    { blog_subscriber: { email: email } }
  end
end
