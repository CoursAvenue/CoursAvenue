# encoding: utf-8
class Pro::FaqsController < Pro::ProController
  before_action :authenticate_pro_super_admin!

  layout :resolve_layout

  def index
    @sections_pro  = ::Faq::Section.pro
    @sections_user = ::Faq::Section.user
  end

  def new
    if params[:type] == 'pro'
      @section = ::Faq::Section.new type: 'Faq::Section::Pro'
    else
      @section = ::Faq::Section.new type: 'Faq::Section::User'
    end

    10.times { @section.questions.build }
  end

  def edit
    @section = ::Faq::Section.find params[:id]

    count = 10 - @section.questions.count
    count.times { @section.questions.build }
  end

  def preview
    @sections = params[:type] == 'user' ? ::Faq::Section.user : ::Faq::Section.pro

    render template: 'pages/faq_users'
  end

  def create
    @section = ::Faq::Section.new params[:faq_section]

    respond_to do |format|
      if @section.save
        format.html { redirect_to pro_faqs_path }
      else
        format.html { render action: :edit }
      end
    end
  end

  def update
    @section = ::Faq::Section.find params[:id]
    respond_to do |format|
      if @section.update_attributes params[:faq_section]
        format.html { redirect_to pro_faqs_path }
      else
        format.html { render action: :new }
      end
    end
  end

  def destroy
    @section = ::Faq::Section.find params[:id]
    @section.destroy
    respond_to do |format|
      format.html { redirect_to pro_faqs_path, notice: 'Supprimé !' }
    end
  end

  private

  def resolve_layout
    action_name == 'preview' ? 'admin_pages' : 'admin'
  end
end
