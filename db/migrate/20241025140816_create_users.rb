class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :uuid, null: false
      t.string :hs_contact_id
      t.string :pl_client_id

      t.timestamps
    end

    add_index :users, :uuid, unique: true
    add_index :users, :hs_contact_id, unique: true
    add_index :users, :pl_client_id, unique: true
  end
end
