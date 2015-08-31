class IndexableCard::Creator
  attr_accessor :structure

  def initialize(structure)
    @structure = structure
  end

  # Create the Indexable Cards for the structure.
  #
  # @return the cards.
  def create_cards
    courses   = @structure.courses.includes(:subjects)
    places    = (@structure.places - courses.flat_map(&:places).uniq).compact

    # We loop on each course and create a card from there.
    courses.each do |course|
      @structure.indexable_cards.delay.create_from_course(course)
    end

    # If the Structure doesn't have any courses ( / is not active), we create "placeholder" cards
    # combining places and subjects.
    if courses.empty?
      places.each do |place|
        @structure.indexable_cards.delay.create_from_place(place)
      end
    end
  end

  # Update the existing cards if still relevant, and create new ones if needed.
  #
  # @return the cards.
  def update_cards
    return create_cards if @structure.indexable_cards.empty?
    new_cards = []

    # We start by destroying the card with invalid courses.
    to_destroy = []
    @structure.indexable_cards.with_course.each do |card|
      course = Course.where(id: card.course_id).first
      to_destroy << card if course.nil?
    end
    to_destroy.each(&:destroy)

    # If structure did not have courses we delete all cards only associate to subjects
    # If a structure has courses, we want to have cards only for his courses
    if @structure.indexable_cards.with_course.empty? and new_courses.any?
      @structure.indexable_cards.map(&:destroy)
    end

    # We start by updating the existing cards.
    new_cards += @structure.indexable_cards.includes(:course).with_course.map do |card|
      IndexableCard.delay.update_from_course(card.course)
    end

    # We then create the cards from the new courses.
    new_cards += new_courses.map do |course|
      @structure.indexable_cards.delay.create_from_course(course)
    end

    # Finally, if we don't have any courses, we create cards from places.
    if @structure.courses.empty?
      new_cards += new_places.flat_map do |place|
        @structure.indexable_cards.delay.create_from_place(place)
      end
    end

    new_cards
  end

  private

  # The courses not represented in the cards.
  #
  # @return Array of courses
  def new_courses
    (@structure.courses - @structure.indexable_cards.flat_map(&:course).uniq).compact
  end

  # The places not represented in the cards.
  #
  # @return nil or Array of places
  def new_places
    (@structure.places - @structure.indexable_cards.flat_map(&:place).uniq).compact
  end
end
