class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.string :title
      t.string :src
      t.references :photographer, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
