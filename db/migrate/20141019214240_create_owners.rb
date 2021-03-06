class CreateOwners < ActiveRecord::Migration
  def change
    create_table :owners do |t|
      t.string :username
      t.string :password_salt
      t.string :password_hash
      t.string :email
      t.string :company
      t.integer :usertype

      t.timestamps
    end
  end
end
