class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.belongs_to :quiz
      t.string :question
      t.string :image_url

      t.timestamps
    end
  end
end
