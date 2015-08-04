class Guide::Importer

  # Create a gist and import like this:
  # require 'open-uri'
  # data = open(GIST_RAW_JSON).read
  # Guide::Importer.new(data).import
  def initialize(data)
    @raw_guide = JSON.parse(data)
  end

  # Data is a serialized guide.
  def import
    create_guide
    create_questions_and_answers
    set_subject_metadatas
  end

  private

  def create_guide
    @guide = Guide.create(
      title:            @raw_guide['title'],
      description:      @raw_guide['description'],
      age_dependant:    @raw_guide['age_dependant'],
      call_to_action:   @raw_guide['call_to_action'],
      remote_image_url: @raw_guide['image'],
    )
  end

  def create_questions_and_answers
    raw_questions = @raw_guide['questions']

    Guide::Question.transaction do
      raw_questions.each do |raw_question|
        question = @guide.questions.create(
          ponderation: raw_question['ponderation'],
          content: raw_question['content'],
          position: raw_question['position'],
          color: raw_question['color'],
        )

        raw_question['answers'].each do |raw_answer|
          answer = question.answers.create(
            content: raw_answer['content'],
            position: raw_answer['position'],
            subject_ids: raw_answer['subjects'].map { |s| s['id'] },
            remote_image_url: raw_answer['image'],
          )
        end
      end
    end
  end

  def set_subject_metadatas
    raw_subjects = @raw_guide['subjects']

    raw_subjects.each do |raw_subject|
      subject = Subject.where(slug: raw_subject['slug']).first
      next if subject.nil?

      subject.guide_description          = raw_subject['guide_description']
      subject.age_advice_younger_than_5  = raw_subject['advices'][0]['content']
      subject.age_advice_between_5_and_9 = raw_subject['advices'][1]['content']
      subject.age_advice_older_than_10   = raw_subject['advices'][2]['content']
      subject.save
    end
  end
end
