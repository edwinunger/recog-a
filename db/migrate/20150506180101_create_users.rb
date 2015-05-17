class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string  :first_name
      t.string  :last_name
      t.string  :email
      t.string  :password_hash
      t.date    :birth_date
      t.date    :diagnosed_date

      t.timestamps
    end
  end
end
