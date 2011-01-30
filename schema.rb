create_table :sources do |t|
  t.string :type
  t.string :data
end

create_table :destinations do |t|
  t.string :type
  t.string :data
end

create_table :acls do |t|
  t.string  :description
  t.integer :source_id
  t.integer :destination_id
  t.integer :weekday
  t.time    :start_at
  t.time    :end_at
  t.string  :rewrite_url
end
