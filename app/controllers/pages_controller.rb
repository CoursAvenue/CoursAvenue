# encoding: utf-8
class PagesController < ApplicationController
  def faq_partners
    redirect_to pro_pages_questions_url(subdomain: 'pro'), status: 301
  end
end
