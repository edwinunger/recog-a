class CreateResults < ActiveRecord::Migration
  def change
    create_table :results do |t|
      t.belongs_to :quiz
      t.integer :score

      t.timestamps
    end
  end
end
