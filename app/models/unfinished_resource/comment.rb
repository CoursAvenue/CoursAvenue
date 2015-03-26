class UnfinishedResource::Comment < UnfinishedResource

  belongs_to      :visitor
  attr_accessible :ip_address
  store_accessor  :fields, :private_message, :from, :subject

  # returns a Comment initialize with the data from this
  # unfinished comment
  #
  # @return a Comment
  def to_c
    comment = ::Comment::Review.new
    comment.assign_attributes(comment_attributes, without_protection: true)
    comment
  end

  # emulates the method Comment#commentable by returning the commentable
  # to which this unfinished comment may have referred
  #
  # @return an instance of Commentable (probably structure)
  def commentable
    klass = Object.const_get(commentable_type)

    klass.where(id: commentable_id).first
  end

  # store_accessor for comment[email]
  # @return a String
  def email
    self.fields["comment[email]"]
  end

  # store_accessor for comment[title]
  # @return a String
  def title
    self.fields["comment[title]"]
  end

  # store_accessor for comment[content]
  # @return a String
  def content
    self.fields["comment[content]"]
  end

  # store_accessor for comment[author_name]
  # @return a String
  def author_name
    self.fields["comment[author_name]"]
  end

  # store_accessor for comment[course_name]
  # @return a String
  def course_name
    self.fields["comment[course_name]"]
  end

  # store_accessor for comment[commentable_id]
  # @return an Integer
  def commentable_id
    self.fields["comment[commentable_id]"]
  end

  # store_accessor for comment[commentable_type]
  # @return a String
  def commentable_type
    self.fields["comment[commentable_type]"]
  end

  def submitted?
    self.fields["submitted"] == "true"
  end

  def highlighted?
    self.commentable.highlighted_comment_id == self.id
  end

  private

  def comment_attributes
    {
      content: self.content,
      author_name: self.author_name,
      email: self.email,
      commentable_id: commentable_id,
      commentable_type: commentable_type,
      created_at: self.created_at,
      updated_at: self.updated_at,
      title: self.title,
      user_id: nil,
      course_name: self.course_name,
      status: "accepted"
    }
  end
end
