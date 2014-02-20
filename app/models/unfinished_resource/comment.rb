class UnfinishedResource::Comment < UnfinishedResource

  store_accessor :private_message, :from, :subject

  def to_c
    comment = ::Comment.new
    comment.assign_attributes(comment_attributes, without_protection: true)
    comment
  end

  def email
    self.fields["comment[email]"]
  end

  def title
    self.fields["comment[title]"]
  end

  def content
    self.fields["comment[content]"]
  end

  def author_name
    self.fields["comment[author_name]"]
  end

  def course_name
    self.fields["comment[course_name]"]
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
      status: "pending"
    }
  end

  def commentable_id
    self.fields["comment[commentable_id]"]
  end

  def commentable_type
    self.fields["comment[commentable_type]"]
  end
end
