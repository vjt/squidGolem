delimiter ;

CREATE TABLE users (
  id   INT(8) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255)
);

CREATE TABLE hosts (
  id   INT(8)  UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  host BIT(32), -- Yes, IPv4-only for now, won't be an headache to add IPv6 suport
  mask TINYINT UNSIGNED
);

CREATE TABLE destinations (
  id   INT(8) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  type VARCHAR(255) NOT NULL,
  data VARCHAR(255) NOT NULL
);

ALTER TABLE destinations ADD KEY (type);

CREATE TABLE acls (
  id             INT(8) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  description    VARCHAR(255) NULL,
  host_id        INT(8) NOT NULL, -- TODO Add Foreign Keys
  user_id        INT(8) NULL,
  destination_id INT(8) NULL,
  weekday        INT(8) NULL,
  start_at       TIME   NULL,
  end_at         TIME   NULL,
  rewrite_url    VARCHAR(255) NULL,
  position       INT(4) NOT NULL
);

ALTER TABLE acls ADD UNIQUE KEY acls_source_destination (host_id, user_id, destination_id);
ALTER TABLE acls ADD KEY        acls_weekday_and_dates  (weekday, start_at, end_at);
ALTER TABLE acls ADD UNIQUE KEY acls_position           (position);

delimiter GO

  -- Yields a recordset containing the current valid ACLs,
  -- that is, the ones that have no date/time constraints
  -- or those that match with the current date/time.
  DROP VIEW IF EXISTS current_acls
  GO
  CREATE VIEW current_acls AS
  SELECT users.name        AS user,
         hosts.host & ~((1<<32-hosts.mask)-1) AS host,
         hosts.mask        AS mask,

         destinations.type AS destination_type,
         destinations.data AS destination,

         acls.rewrite_url  AS rewrite_url,
         acls.position     AS position
  FROM acls
  INNER JOIN      hosts        ON hosts.id        = acls.host_id
  LEFT OUTER JOIN users        ON users.id        = acls.user_id
  LEFT OUTER JOIN destinations ON destinations.id = acls.destination_id
  WHERE (weekday IS NULL OR weekday = WEEKDAY(NOW())) AND
        (start_at IS NULL AND end_at IS NULL OR (
          TIME(NOW()) BETWEEN start_at AND end_at
        ))
  GO

  -- Checks the current_acls view for one that matches the
  -- given destination type, data, user and host. Returns
  -- the eventual rewrite url if found, NULL otherwise.
  DROP FUNCTION IF EXISTS sp_check
  GO
  CREATE FUNCTION sp_check(
    _dest_type varchar(8),
    _dest_data varchar(255),
    _user      varchar(255),
    _host      bit(32)
  ) RETURNS varchar(255)
  BEGIN
    SET @rewrite_url = NULL;

    SELECT rewrite_url FROM current_acls
    WHERE host & ~((1<<32-mask)-1) = _host AND
          (user IS NULL OR user = _user)   AND
          (destination_type IS NULL OR
           destination_type = _dest_type AND
           destination      = _dest_data)
    ORDER BY position
    LIMIT 1
    INTO @rewrite_url;

    RETURN @rewrite_url;
  END
  GO

  -- Checks for an ACL matching the given domain, user
  -- and host using sp_check().
  DROP FUNCTION IF EXISTS sp_check_domain
  GO
  CREATE FUNCTION sp_check_domain(
    _domain varchar(255),
    _user   varchar(255),
    _host   bit(32)
  ) RETURNS varchar(255)
  BEGIN
    SELECT sp_check('domain', _domain, _user, _host) INTO @rewrite_url;
    RETURN @rewrite_url;
  END
  GO

  -- Checks for an ACL matching the given URL, user
  -- and host using sp_check().
  DROP FUNCTION IF EXISTS sp_check_url
  GO
  CREATE FUNCTION sp_check_url(
    _url    varchar(255),
    _user   varchar(255),
    _host   bit(32)
  ) RETURNS varchar(255)
  BEGIN
    SELECT sp_check('url', _url, _user, _host) INTO @rewrite_url;
    RETURN @rewrite_url;
  END
  GO
