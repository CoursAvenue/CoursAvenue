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
    subjects  = (@structure.subjects.at_depth(2) - plannings.flat_map(&:subjects)).compact
    places    = (@structure.places - plannings.flat_map(&:course).flat_map(&:place)).compact

    # We loop on each plannings and create a card from there.
    plannings.each do |planning|
      @structure.indexable_cards.create_from_planning(planning)
    end
    if plannings.empty?
      # We loop on each subjects and places not in the plannings above and create a card from there.
      subjects.each do |subject|
        places.each do |place|
          @structure.indexable_cards.create_from_subject_and_place(subject, place)
        end
      end
    end
  end

  # Update the existing cards if still relevant, and create new ones if needed.
  #
  # @return the card.
  def update_cards
    return create_cards if @structure.indexable_cards.empty?
    new_cards = []

    # If structure did not have plannings we delete all cards only associate to subjects
    # If a structure has plannings, we want to have cards only for his courses
    if @structure.indexable_cards.with_plannings.empty? and new_plannings.any?
      @structure.indexable_cards.map(&:destroy)
    end
    # We start by creating the cards from plannings since the associated subjects and places will
    # also be in the `new_subjects` and `new_places`.
    new_cards += new_plannings.map do |planning|
      @structure.indexable_cards.create_from_planning(planning)
    end

    if @structure.plannings.empty?
      # We then create the new cards for the places and subjects not associated with a planning.
      new_cards += new_subjects.flat_map do |subject|
        new_places.map do |place|
          @structure.indexable_cards.create_from_subject_and_place(subject, place)
        end
      end
    end

    new_cards
  end

  private

  # The plannings not represented in the cards.
  #
  # @return Array of plannings
  def new_plannings
    (@structure.plannings - @structure.indexable_cards.flat_map(&:planning).uniq).compact
  end

  # The subjects not represented in the cards.
  #
  # @return nil or Array of subjects
  def new_subjects
    (@structure.subjects.at_depth(2) - @structure.indexable_cards.flat_map(&:subjects).uniq).compact
  end

  # The places not represented in the cards.
  #
  # @return nil or Array of places
  def new_places
    (@structure.places - @structure.indexable_cards.flat_map(&:place).uniq).compact
  end
end
