class CreateWebSources < ActiveRecord::Migration[5.0]
  def change
    create_table :web_sources do |t|
      t.text :url
      t.string :title

      t.timestamps
    end
  end
end
