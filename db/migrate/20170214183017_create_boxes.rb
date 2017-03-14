class CreateBoxes < ActiveRecord::Migration[5.0]
  def change
    create_table :boxes do |t|
      t.string :filename
      t.string :filepath
      t.string :short_file
      t.datetime :date_of_expiry
      t.timestamps
    end
  end
end
