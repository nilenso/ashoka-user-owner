class CreateTermsOfServices < ActiveRecord::Migration
  def change
    create_table :terms_of_services do |t|
      t.string :document
      t.timestamps
    end
  end
end
