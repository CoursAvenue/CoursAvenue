class Pro::Structures::ParticipationRequestsController < Pro::ProController

  load_resource :structure, find_by: :slug
  before_action :load_structure

  # GET pro/etablissements/:structure_id/suivi-inscriptions
  def index
    @participation_requests = @structure.
      participation_requests.includes(:course, :planning, user: [:city], participants: [:price])

    deleted_associations = Proc.new { |pr| pr.user.nil? || pr.course.nil? }
    @not_treated = @participation_requests.upcoming.pending.reject(&deleted_associations)
    @treated     = @participation_requests.upcoming.treated.reject(&deleted_associations)
  end

  # GET pro/etablissements/:structure_id/suivi-inscriptions/a-venir
  def upcoming
    @participation_requests = @structure.participation_requests.
      includes(:course, :planning, user: [:city], participants: [:price]).
      upcoming.accepted.reject { |pr| pr.user.nil? || pr.course.nil? }
  end

  # GET pro/etablissements/:structure_id/suivi-inscriptions/deja-passe
  def past
    @participation_requests = @structure.participation_requests.
      includes(:course, :planning, user: [:city], participants: [:price]).
      past.reject { |pr| pr.user.nil? || pr.course.nil? }
  end

  def paid_requests
    raise 'To remimplement in the future.'
  end

  private

  def load_structure
    @structure = Structure.includes(:participation_requests).
      friendly.find(params[:structure_id])
  end
end
