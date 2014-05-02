class AddAdminMdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :admin_md, :boolean, default: false
  end
end
