use $(DatabaseName);

CREATE USER _sqlPublisher WITH PASSWORD = '';
ALTER ROLE db_owner ADD MEMBER _sqlPublisher; 