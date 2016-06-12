class CreateDocs < ActiveRecord::Migration
  def change
    create_table :docs do |t|
      t.string :name, null: false, unique: true

      t.text :description
      t.text :content
      t.text :raw_data

      t.string :classification
    end

    add_index :docs, :classification
  end
end
