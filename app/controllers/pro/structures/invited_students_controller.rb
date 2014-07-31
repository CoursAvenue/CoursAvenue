# encoding: utf-8
class ::Pro::Structures::InvitedStudentsController < Pro::ProController
  before_action :authenticate_pro_admin!
  load_and_authorize_resource :structure, find_by: :slug

  def index
    @structure        = Structure.friendly.find params[:structure_id]
    @invited_teachers = @structure.invited_students
  end

  def new
  end

  def jpo
    @invited_users = @structure.invited_students.for_jpo
  end

  def jpo_new
    @invited_users = @structure.invited_students.for_jpo
  end

  def bulk_create_jpo
    params[:emails] ||= ''
    regexp = Regexp.new(/\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\b/)
    emails = params[:emails].scan(regexp).uniq
    text = '<div class="p">' + params[:text].gsub(/\r\n\r\n/, '</div><div class="p">').gsub(/\r\n/, '<br>') + '</div>' if params[:text].present?

    emails.each do |_email|
      invited_user = ::InvitedUser::Student.where(invitation_for: 'jpo', email: _email, referrer_id: @structure.id, referrer_type: 'Structure', email_text: text).first_or_create
      invited_user.structure_id = @structure.id
      invited_user.save
      InvitedUserMailer.delay.recommand_friends(invited_user)
    end
    respond_to do |format|
      if emails.empty?
        format.html { redirect_to jpo_new_pro_structure_invited_students_path(@structure), error: "Les emails que vous avez renseignés sont mal formattés." }
      else
        format.html { redirect_to jpo_pro_structure_invited_students_path(@structure), notice: (params[:emails].present? ? 'Vos élèves ont bien été notifiés.' : nil) }
      end
    end
  end

  def bulk_create
    params[:emails] ||= ''
    regexp = Regexp.new(/\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\b/)
    emails = params[:emails].scan(regexp).uniq
    text = '<div class="p">' + params[:text].gsub(/\r\n\r\n/, '</div><div class="p">').gsub(/\r\n/, '<br>') + '</div>' if params[:text].present?

    emails.each do |_email|
      invited_user = ::InvitedUser::Student.where(email: _email, referrer_id: @structure.id, referrer_type: 'Structure', email_text: text).first_or_create
      InvitedUserMailer.delay.recommand_friends(invited_user)
    end

    respond_to do |format|
      format.html { redirect_to new_pro_structure_invited_student_path(@structure), notice: (params[:emails].present? ? 'Vos élèves ont bien été notifiés.' : nil) }
    end
  end

  def destroy
    @structure       = Structure.friendly.find params[:structure_id]
    @invited_student = @structure.invited_students.find params[:id]
    @invited_student.destroy
    respond_to do |format|
      format.html { redirect_to jpo_pro_structure_invited_students_path(@structure) }
    end
  end
end
