class CreateChoices < ActiveRecord::Migration
  def change
    create_table :choices do |t|
      t.belongs_to :question
      t.string :choice
      t.boolean :correct, default: false

      t.timestamps
    end
  end
end
