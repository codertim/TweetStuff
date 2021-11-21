class CreateTweetStyles < ActiveRecord::Migration
  def self.up
    create_table :tweet_styles do |t|
      t.references :user   # one-to-one table relationship/association
      t.string :zone, :limit => 20, :default => 'DEMOCRACY'  # assume this is most popular 'zone' or 'view'
      t.integer :tweets_per_person, :default => 2    # limit tweets show per person
      t.boolean :is_show_picture, :default => true   # show picture of friend?
      t.boolean :is_show_time, :default => true    # show time of every tweet?
      t.timestamps
    end
  end

  def self.down
    drop_table :tweet_styles
  end
end
