class Admin::StructuresController < Admin::AdminController
  # GET structures
  def index
    @structures = Structure.includes(:admin).order('structures.created_at DESC').
      page(params[:page] || 1).per(50)
    @importer = StructureImporter.new
  end

  # GET /nouveau-dormant
  def new_sleeping
    @structure  = Structure.new
    5.times { @structure.places        << @structure.places.publics.build }
    5.times { @structure.phone_numbers << @structure.phone_numbers.build }
  end

  # POST structure/import
  def import
    file = import_params[:file].tempfile
    importer = StructureImporter.new(file)
    imported_structures = importer.import!

    respond_to do |format|
      if imported_structures.any?
        format.html { redirect_to pro_structures_path,
                      notice: "Le fichier est en cours d'importation." }
      else
        format.html { redirect_to pro_structures_path,
                      error: "Une erreur est survenue lors de l'import du fichier, veuillez rééssayer." }
      end
    end
  end

  # GET structures/stars
  def stars
    @structures = Structure.order('created_at DESC').
      where(Structure.arel_table[:comments_count].gteq(5))
  end

  # DELETE structures/:id
  def destroy
    CrmSync.delay(queue: 'mailers').destroy(@structure.email) if @structure.is_sleeping
    SuperAdminMailer.delay(queue: 'mailers').has_destroyed(@structure)
    AdminMailer.delay(queue: 'mailers').structure_has_been_destroy(@structure)

    if params[:slug_to_associate].present?
      associate_structure = Structure.find(params[:slug_to_associate])
      friendly_id = FriendlyId::Slug.where(
        slug: @structure.slug, sluggable_type: 'Structure').first_or_create
      friendly_id.update_column :sluggable_id, associate_structure.id
    end

    respond_to do |format|
      if @structure.destroy
        format.html { redirect_to (request.referrer || pro_structures_path),
                                   notice: 'Structure supprimé' }
      else
        format.html { redirect_to pro_admins_path, alert: 'Oups...' }
      end
    end
  end

  # GET structures/:id/ask_for_pro_deletion
  def ask_for_pro_deletion
    @structure = Structure.find(params[:id])
    if request.xhr?
      render layout: false
    end
  end

  # GET structures/duplicates
  def duplicates
    per_page = params[:per_page].present? ? params[:per_page].to_i : 20
    page     = params[:page].present? ? params[:page].to_i : 1
    offset   = (page - 1) * per_page

    @duplicate_lists   = Structure::DuplicateList.includes(:structure).joins(:structure).
      order('structures.created_at DESC').limit(per_page).offset(offset)
    @pagination_scope = OpenStruct.new(
      current_page: page,
      limit_value: per_page,
      total_pages: (Structure::DuplicateList.count / per_page.to_f).ceil
    )
    @last_update = Structure::DuplicateList.pluck(:updated_at).max
  end

  def update_duplicates
    Structure::DuplicateList.delay.save_potential_duplicates
    redirect_to duplicates_pro_structures_path, notice: 'La recherche de doublon est en cours.'
  end


  private

  def import_params
    params.require(:structure_import).permit(:file)
  end
end
