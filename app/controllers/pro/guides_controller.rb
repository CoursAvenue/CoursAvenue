class Pro::GuidesController < Pro::ProController
  before_action :authenticate_pro_super_admin!

  def index
    @guides = Guide.includes(:questions).all
  end

  def new
    @guide = Guide.new
    5.times do
      q = @guide.questions.build
      4.times { q.answers.build }
    end

    if request.xhr?
      render layout: false
    end
  end
end
