class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :uuid, unique: true
      t.string :hs_contact_id, unique: true
      t.string :pl_client_id, unique: true

      t.timestamps
    end
  end
end
