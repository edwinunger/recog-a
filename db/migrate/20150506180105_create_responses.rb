class CreateResponses < ActiveRecord::Migration
  def change
    create_table :responses do |t|
      t.belongs_to :question
      t.string :response
      t.boolean :correct, default: false
      t.timestamps
    end
  end
end
