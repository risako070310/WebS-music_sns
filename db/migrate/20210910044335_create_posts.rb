class CreatePosts < ActiveRecord::Migration[6.1]
  def change
    create_table :posts do |t|
      t.string :artist
      t.string :album
      t.string :song
      t.string :jacket
      t.string :sample
      t.string :comment
      t.integer :user_id
      t.timestamps null: false
    end
  end
end
