delimiter ;

CREATE TABLE sources (
  id   INT(8) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  type VARCHAR(255),
  data VARCHAR(255)
);

ALTER TABLE sources ADD KEY(type);

CREATE TABLE destinations (
  id   INT(8) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  type VARCHAR(255) NOT NULL,
  data VARCHAR(255) NOT NULL
);

ALTER TABLE destinations ADD KEY(type);

CREATE TABLE acls (
  id             INT(8) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  description    VARCHAR(255) NULL,
  source_id      INT(8) NOT NULL,
  destination_id INT(8) NOT NULL,
  weekday        INT(8) NULL,
  start_at       TIME   NULL,
  end_at         TIME   NULL,
  rewrite_url    VARCHAR(255) NULL
);

delimiter GO

  -- Yields a recordset containing the current valid ACLs,
  -- that is, the ones that have no date/time constraints
  -- or those that match with the current date/time.
  delimiter GO
  CREATE VIEW current_acls AS
  SELECT sources.type AS source_type, source.data AS source,
         destinations.type AS destination_type, destinations.data AS destination,
         acl.rewrite_url AS rewrite_url
  FROM acl
  INNER JOIN sources      ON sources.id = acl.source_id
  INNER JOIN destinations ON destinations.id = acl.destination_id
  WHERE (weekday IS NULL OR (weekday = EXTRACT(weekday FROM GETDATE())) AND
        (start_at IS NULL AND end_at IS NULL OR (
          EXTRACT(time FROM GETDATE()) BETWEEN start_at AND end_at
        ))
  GO

  -- Checks the current_acls view for one that matches the
  -- given destination type, data, user and host. Returns
  -- the eventual rewrite url if found, NULL otherwise.
  delimiter GO
  CREATE FUNCTION sp_check(
    _dest_type varchar(8),
    _dest_data varchar(255),
    _user      varchar(255),
    _host      varchar(15)
  ) RETURNS varchar(255)

    SELECT rewrite_url FROM current_acls
    WHERE (destinations_type = _dest_type AND destinations_data = _dest_data) AND
          ((sources_type = 'user' AND sources_data = _user) OR
           (sources_type = 'host' AND sources_type = _host))
    INTO @rewrite_url;

    RETURN @rewrite_url;
  GO

  -- Checks for an ACL matching the given domain, user
  -- and host using sp_check().
  delimiter GO
  CREATE FUNCTION sp_check_domain(
    _domain varchar(255),
    _user   varchar(255),
    _host   varchar(15)
  ) RETURNS varchar(255)
  BEGIN
    RETURN sp_check('domain', _domain, _user, _host);
  END
  GO

  -- Checks for an ACL matching the given URL, user
  -- and host using sp_check().
  delimiter GO
  CREATE FUNCTION sp_check_url(
    _url    varchar(255),
    _user   varchar(255),
    _host   varchar(15)
  )
  BEGIN
    RETURN sp_check('url', _url, _user, _host);
  END
  GO
