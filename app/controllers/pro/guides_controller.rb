class Pro::GuidesController < Pro::ProController
  before_action :authenticate_pro_super_admin!

  def index
    @guides = Guide.all
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

  def create
    @guide = Guide.new(guide_params)

    if @guide.save
      redirect_to edit_subjects_pro_guide_path(@guide)
    else
      render :new
    end
  end

  def edit
    @guide = Guide.includes(questions: [:answers]).find(params[:id])
    3.times { q = @guide.questions.build }

    @guide.questions.each do |q|
      (4 - q.answers.count).times { q.answers.build }
    end
  end

  def update
    @guide = Guide.find(params[:id])

    if @guide.update_attributes(guide_params)
      redirect_to edit_subjects_pro_guide_path(@guide)
    else
      render :edit
    end
  end

  def destroy
    @guide = Guide.find(params[:id])

    if @guide.destroy
      redirect_to pro_guides_path, notice: 'Guide supprimé'
    else
      redirect_to pro_guides_path, error: 'Une erreur est survenue, veuillez rééssayer'
    end
  end

  def edit_subjects
    @guide    = Guide.find(params[:id])
    @subjects = @guide.subjects
  end

  def update_subjects
    @guide = Guide.find(params[:id])

    if @guide.update_attributes(subjects_params)
      redirect_to pro_guides_path
    else
      render :edit_subjects
    end
  end

  private

  def guide_params
    params.require(:guide).permit(
      :title,
      :description,
      :call_to_action,
      :questions_attributes => [
        :id, :content, :ponderation,
        :answers_attributes => [:id, :content, :remote_image_url, :subject_ids => []]
      ]
    )
  end

  def subjects_params
    params.require(:guide).permit(
      :subjects_attributes => [:id, :guide_description]
    )
  end
end
