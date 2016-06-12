class AddUserIdToDocs < ActiveRecord::Migration
  def change
    add_column :docs, :user_id, :integer
    add_foreign_key :docs, :users
  end
end
