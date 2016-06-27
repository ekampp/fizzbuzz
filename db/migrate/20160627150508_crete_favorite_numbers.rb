class CreteFavoriteNumbers < ActiveRecord::Migration
  def change
    create_table :favorite_numbers do |t|
      t.integer :number, index: true, null: false
      t.references :user, index: true, foreign_key: true
    end
  end
end
