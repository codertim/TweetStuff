class CreateTribes < ActiveRecord::Migration
  def self.up
    create_table :tribes do |t|
      t.references :user
      t.string :name
      t.string :description
      t.text :twitter_users

      t.timestamps
    end
  end

  def self.down
    drop_table :tribes
  end
end
