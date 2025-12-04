<?php

/* Local configuration for Roundcube Webmail */

// ----------------------------------
// SQL DATABASE
// ----------------------------------
// Database connection string (DSN) for read+write operations
// Format (compatible with PEAR MDB2): db_provider://user:password@host/database
// Currently supported db_providers: mysql, pgsql, sqlite, mssql, sqlsrv, oracle
// For examples see https://pear.php.net/manual/en/package.database.mdb2.intro-dsn.php
// Note: for SQLite use absolute path (Linux): 'sqlite:////full/path/to/sqlite.db?mode=0646'
//       or (Windows): 'sqlite:///C:/full/path/to/sqlite.db'
// Note: Various drivers support various additional arguments for connection,
//       for Mysql: key, cipher, cert, capath, ca, verify_server_cert,
//       for Postgres: application_name, sslmode, sslcert, sslkey, sslrootcert, sslcrl, sslcompression, service.
//       e.g. 'mysql://roundcube:@localhost/roundcubemail?verify_server_cert=false'
$config['db_dsnw'] = 'pgsql://messageries_root:PasswordBdd@posgres:5432/roundcube';

// ----------------------------------
// LOGGING/DEBUGGING
// ----------------------------------
// log driver:  'syslog', 'stdout' or 'file'.
$config['log_driver'] = 'stdout';

// ----------------------------------
// IMAP
// ----------------------------------
// The IMAP host (and optionally port number) chosen to perform the log-in.
// Leave blank to show a textbox at login, give a list of hosts
// to display a pulldown menu or set one host as string.
// Enter hostname with prefix ssl:// to use Implicit TLS, or use
// prefix tls:// to use STARTTLS.
// If port number is omitted it will be set to 993 (for ssl://) or 143 otherwise.
// Supported replacement variables:
// %n - hostname ($_SERVER['SERVER_NAME'])
// %t - hostname without the first part
// %d - domain (http hostname $_SERVER['HTTP_HOST'] without the first part)
// %s - domain name after the '@' from e-mail address provided at login screen
// For example %n = mail.domain.tld, %t = domain.tld
// WARNING: After hostname change update of mail_host column in users table is
//          required to match old user data records with the new host.
$config['imap_host'] = 'proxy-dovecot01:143';

// If you know your imap's folder vendor, you can specify it here.
// Otherwise it will be determined automatically. Use lower-case
// identifiers, e.g. 'dovecot', 'cyrus', 'gimap', 'hmail', 'uw-imap'.
$config['imap_vendor'] = 'cyrus';

// ----------------------------------
// SMTP
// ----------------------------------
// SMTP server host (and optional port number) for sending mails.
// Enter hostname with prefix ssl:// to use Implicit TLS, or use
// prefix tls:// to use STARTTLS.
// If port number is omitted it will be set to 465 (for ssl://) or 587 otherwise.
// Supported replacement variables:
// %h - user's IMAP hostname
// %n - hostname ($_SERVER['SERVER_NAME'])
// %t - hostname without the first part
// %d - domain (http hostname $_SERVER['HTTP_HOST'] without the first part)
// %z - IMAP domain (IMAP hostname without the first part)
// For example %n = mail.domain.tld, %t = domain.tld
// To specify different SMTP servers for different IMAP hosts provide an array
// of IMAP host (no prefix or port) and SMTP server e.g. ['imap.example.com' => 'smtp.example.net']
$config['smtp_host'] = 'cyrus:25';

// ----------------------------------
// OAuth
// ----------------------------------
// Enable OAuth2 by defining a provider. Use 'generic' here
$config['oauth_provider'] = 'generic';

// Provider name to be displayed on the login button
$config['oauth_provider_name'] = 'Keycloak';

// Mandatory: OAuth client ID for your Roundcube installation
$config['oauth_client_id'] = 'roundcube';

// Mandatory: OAuth client secret
$config['oauth_client_secret'] = 'kt2V6lVxVG49HVXQVXC2o1Mqjp5uplTA';

// Mandatory: URI for OAuth user authentication (redirect)
$config['oauth_auth_uri'] = 'https://keycloak.localhost:38443/realms/example.com/protocol/openid-connect/auth';

// Mandatory: Endpoint for OAuth authentication requests (server-to-server)
$config['oauth_token_uri'] = 'https://keycloak.localhost:38443/realms/example.com/protocol/openid-connect/token';

// Optional: Endpoint to query user identity if not provided in auth response
$config['oauth_identity_uri'] = 'https://keycloak.localhost:38443/realms/example.com/protocol/openid-connect/userinfo';

// Mandatory: OAuth scopes to request (space-separated string)
$config['oauth_scope'] = 'openid profile email';

// Optional: array of field names used to resolve the username within the identity information
$config['oauth_identity_fields'] = ['uid'];

// provide an URL where a user can get support for this Roundcube installation
// PLEASE DO NOT LINK TO THE ROUNDCUBE.NET WEBSITE HERE!
$config['support_url'] = '';

// Location of temporary saved files such as attachments and cache files
// must be writeable for the user who runs PHP process (Apache user if mod_php is being used)
$config['temp_dir'] = '/tmp/roundcube-temp';

// This key is used for encrypting purposes, like storing of imap password
// in the session. For historical reasons it's called DES_key, but it's used
// with any configured cipher_method (see below).
// For the default cipher_method a required key length is 24 characters.
$config['des_key'] = 'IMs6J7SQwCzOFcOvV9AngNKr';

// Specifies the full path of the original HTTP request, either as a real path or
// $_SERVER field name. This might be useful when Roundcube runs behind a reverse
// proxy using a subpath. This is a path part of the URL, not the full URL!
// The reverse proxy config can specify a custom header (e.g. X-Forwarded-Path) containing
// the path under which Roundcube is exposed to the outside world (e.g. /rcube/).
// This header value is then available in PHP with $_SERVER['HTTP_X_FORWARDED_PATH'].
// By default the path comes from  'REDIRECT_SCRIPT_URL', 'SCRIPT_NAME' or 'REQUEST_URI',
// whichever is set (in this order).
$config['request_path'] = '/';

// ----------------------------------
// PLUGINS
// ----------------------------------
// List of active plugins (in plugins/ directory)
$config['plugins'] = ['archive', 'zipdownload'];

// Make use of the built-in spell checker.
$config['enable_spellcheck'] = true;

// Set the spell checking engine. Possible values:
// - 'googie'  - the default (also used for connecting to Nox Spell Server, see 'spellcheck_uri' setting)
// - 'pspell'  - requires the PHP Pspell module and aspell installed
// - 'enchant' - requires the PHP Enchant module
// - 'atd'     - install your own After the Deadline server or check with the people at https://www.afterthedeadline.com before using their API
// Since Google shut down their public spell checking service, the default settings
// connect to https://spell.roundcube.net which is a hosted service provided by Roundcube.
// You can connect to any other googie-compliant service by setting 'spellcheck_uri' accordingly.
$config['spellcheck_engine'] = 'pspell';

$config['zipdownload_selection'] = true;

$config['oauth_redirect_uri'] = 'http://roundcube.localhost:20080/?_task=login&_action=oauth_callback';

$config['oauth_post_logout_redirect'] = 'http://roundcube.localhost:20080/';

include(__DIR__ . '/config.docker.inc.php');
