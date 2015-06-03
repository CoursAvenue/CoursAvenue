class IndexableCard::Creator
  attr_accessor :structure

  def initialize(structure)
    @structure = structure
  end

  # Create the Indexable Cards for the structure.
  #
  # @return the cards.
  def create_cards
    plannings = @structure.plannings.includes(:course, :subjects)
    subjects  = (@structure.subjects - plannings.flat_map(&:subjects)).compact
    places    = (@structure.places - plannings.flat_map(&:course).flat_map(&:place)).compact

    plannings.each do |planning|
      @structure.indexable_cards.create_from_planning(planning)
    end

    subjects.each do |subject|
      places.each do |place|
        @structure.indexable_cards.create_from_subject_and_place(subject, place)
      end
    end
  end

  # Update the existing cards if still relevant, and create new ones if needed.
  #
  # @return the card.
  def update_cards
    return create_cards if @structure.indexable_cards.empty?
  end

  private

  # The plannings not represented in the cards.
  #
  # @return Array of plannings
  def new_plannings
    (@structure.plannings - @structure.indexable_cards.flat_map(&:planning)).compact
  end

  # The courses not represented in the cards.
  #
  # @return nil or Array of courses
  def new_courses
    (@structure.courses - @structure.indexable_cards.flat_map(&:course)).compact
  end

  # The subjects not represented in the cards.
  #
  # @return nil or Array of subjects
  def new_subjects
    (@structure.subjects - @structure.indexable_cards.flat_map(&:subjects)).compact
  end
end
