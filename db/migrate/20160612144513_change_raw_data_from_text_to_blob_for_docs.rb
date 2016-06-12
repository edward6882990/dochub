class ChangeRawDataFromTextToBlobForDocs < ActiveRecord::Migration
  def change
    change_column :docs, :raw_data, :blob, :limit => 16.megabyte
  end
end
