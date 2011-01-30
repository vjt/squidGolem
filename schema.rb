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

create_view :view_acl, %[
  SELECT sources.type AS source_type, source.data AS source,
         destinations.type AS destination_type, destinations.data AS destination,
         acl.rewrite_url AS rewrite_url
  FROM acl
  INNER JOIN sources      ON sources.id = acl.source_id
  INNER JOIN destinations ON destinations.id = acl.destination_id
  WHERE weekday = EXTRACT(weekday FROM GETDATE()) AND
        EXTRACT(time FROM GETDATE()) BETWEEN start_at AND end_at
]

sql %[
  CREATE FUNCTION sp_check_domain(
    _domain varchar(255),
    _user   varchar(255),
    _host   varchar(15)
  ) RETURNS varchar(255)
  SQL SECURITY INVOKER
  NOT DETERMINISTIC
  READS SQL DATA
  BEGIN

    SELECT acls.rewrite_url FROM view_acl
    WHERE (destinations.type = 'domain' AND destinations.data = _domain) AND
          ((sources.type = 'user' AND sources.data = _user) OR
           (sources.type = 'host' AND sources.type = _host))
    INTO @rewrite_url;

    RETURN @rewrite_url;

  END
]
