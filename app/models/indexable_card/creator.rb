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

    # We loop on each plannings and create a card from there.
    plannings.each do |planning|
      @structure.indexable_cards.create_from_planning(planning)
    end

    # We loop on each subjects and places not in the plannings above and create a card from there.
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
    new_cards = []

    # We start by creating the cards from plannings since the associated subjects and places will
    # also be in the `new_subjects` and `new_places`.
    new_cards += new_plannings.map do |planning|
      @structure.indexable_cards.create_from_planning(planning)
    end

    # We then get the new subjects and places but remove any of them if it is already in one of the
    # newly created card.
    _new_subjects = new_subjects - new_cards.map(&:planning).uniq
    _new_places   = new_places - new_cards.map(&:place).uniq

    new_cards += _new_subjects.flat_map do |subject|
      _new_places.map do |place|
        @structure.indexable_cards.create_from_subject_and_place(subject, place)
      end
    end

    new_cards
  end

  private

  # The plannings not represented in the cards.
  #
  # @return Array of plannings
  def new_plannings
    (@structure.plannings - @structure.indexable_cards.flat_map(&:planning)).compact
  end

  # The subjects not represented in the cards.
  #
  # @return nil or Array of subjects
  def new_subjects
    (@structure.subjects - @structure.indexable_cards.flat_map(&:subjects)).compact
  end

  # The places not represented in the cards.
  #
  # @return nil or Array of places
  def new_places
    (@structure.places - @structure.indexable_cards.flat_map(&:place)).compact
  end
end
