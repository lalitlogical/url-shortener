class CreateClicks < ActiveRecord::Migration[8.0]
  def change
    create_table :clicks do |t|
      t.references :shortened_url, null: false, foreign_key: true
      t.string :ip_address
      t.string :referer
      t.string :user_agent

      t.timestamps
    end
  end
end
