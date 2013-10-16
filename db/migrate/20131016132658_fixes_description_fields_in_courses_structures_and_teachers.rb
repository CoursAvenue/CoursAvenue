class FixesDescriptionFieldsInCoursesStructuresAndTeachers < ActiveRecord::Migration
  def change
    bar = ProgressBar.new Teacher.count + Structure.count + Course.count + Comment.count
    [Teacher, Structure, Course].each do |model_name|
      model_name.where{description != nil}.each do |model|
        bar.increment!
        model.update_column :description, model.description.gsub(/<br>/, "\r\n")
      end
    end
    Comment.distinct.each do |comment|
      bar.increment!
      comment.update_column :content, comment.content.gsub(/<br>/, "\r\n")
    end
  end
end
