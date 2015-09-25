class Admin::GuidesController < Admin::AdminController
  def index
    @guides = Guide.all
  end

  def show
    @guide = Guide.find(params[:id])

    respond_to do |format|
      format.html { redirect_to edit_admin_guide_path(@guide) }
      format.json { render json: @guide }
    end
  end

  def new
    @guide = Guide.new
    10.times do
      q = @guide.questions.build
      5.times { q.answers.build }
    end

    if request.xhr?
      render layout: false
    end
  end

  def create
    @guide = Guide.new(guide_params)

    if @guide.save
      redirect_to edit_subjects_admin_guide_path(@guide)
    else
      render :new
    end
  end

  def edit
    @guide = Guide.includes(questions: [:answers]).find(params[:id])
    10.times { q = @guide.questions.build }

    @guide.questions.each do |q|
      (5 - q.answers.count).times { q.answers.build }
    end
  end

  def update
    @guide = Guide.find(params[:id])

    if @guide.update_attributes(guide_params)
      redirect_to edit_subjects_admin_guide_path(@guide)
    else
      render :edit
    end
  end

  def destroy
    @guide = Guide.find(params[:id])

    if @guide.destroy
      redirect_to admin_guides_path, notice: 'Guide supprimé'
    else
      redirect_to admin_guides_path, error: 'Une erreur est survenue, veuillez rééssayer'
    end
  end

  def edit_subjects
    @guide    = Guide.find(params[:id])
    @subjects = @guide.subjects
  end

  def update_subjects
    @guide = Guide.find(params[:id])

    if @guide.update_attributes(subjects_params)
      redirect_to admin_guides_path
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
      :age_dependant,
      :remote_image_url,
      :questions_attributes => [
        :id, :content, :ponderation, :position, :color,
        :answers_attributes => [:id, :content, :remote_image_url, :position, :subject_ids => []]
      ]
    )
  end

  def subjects_params
    params.require(:guide).permit(
      :subjects_attributes => [:id, :guide_description, :age_advice_younger_than_5,
                               :age_advice_between_5_and_9, :age_advice_older_than_10]
    )
  end
end
