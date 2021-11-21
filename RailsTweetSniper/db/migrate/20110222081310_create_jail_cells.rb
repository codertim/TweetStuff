class CreateJailCells < ActiveRecord::Migration
  def self.up
    create_table :jail_cells do |t|
      t.references :user
      t.string :screen_name, :limit => 80

      t.timestamps
    end
  end

  def self.down
    drop_table :jail_cells
  end
end
