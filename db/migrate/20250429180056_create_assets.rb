class CreateAssets < ActiveRecord::Migration[8.0]
  def change
    create_table :assets do |t|
      t.references :creator, null: false, foreign_key: { to_table: :users }
      t.string :title, null: false
      t.text :description
      t.string :file_url, null: false
      t.decimal :price, precision: 10, scale: 2, null: false

      t.timestamps
    end
  end
end