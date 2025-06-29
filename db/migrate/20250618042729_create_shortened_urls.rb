class CreateShortenedUrls < ActiveRecord::Migration[8.0]
  def change
    create_table :shortened_urls, id: false do |t|
      t.bigint :id, null: false, primary_key: true
      t.string :original_url, null: false, index: { unique: true }
      t.string :short_code, null: false, index: { unique: true }
      t.boolean :is_active, default: true
      t.datetime :expiration
      t.integer :click_count, default: 0

      t.timestamps
    end
  end
end
