<?php
    $config['plugins'] = [
        'archive',
        'zipdownload',
    ];
    $config['log_driver'] = 'stdout';
    $config['debug_level'] = 1;
  
    $config['zipdownload_selection'] = true;
    $config['des_key'] = 'IMs6J7SQwCzOFcOvV9AngNKr';
    $config['enable_spellcheck'] = true;
    $config['spellcheck_engine'] = 'pspell';
    $config['imap_vendor'] = 'cyrus';

    $config['oauth_provider'] = 'generic';
    $config['oauth_provider_name'] = 'Keycloak';

    $config['oauth_client_id'] = 'roundcube';
    $config['oauth_client_secret'] = '3Dm80pM0se3xPMFjTVNBUfzbHqztOqaq';

    $config['oauth_redirect_uri'] = 'http://roundcube.example.com:20080/?_task=login&_action=oauth_callback';
    $config['oauth_post_logout_redirect'] = 'http://roundcube.example.com:20080/';

    $config['oauth_auth_uri'] = 'https://keycloak.example.com:8443/realms/example.com/protocol/openid-connect/auth';
    $config['oauth_token_uri'] = 'https://keycloak.example.com:8443/realms/example.com/protocol/openid-connect/token';
    $config['oauth_identity_uri'] = 'https://keycloak.example.com:8443/realms/example.com/protocol/openid-connect/userinfo';
    $config['oauth_scope'] = 'openid profile email';
    $config['oauth_identity_fields'] = ['email'];  
    
    // $config['oauth_login_redirect'] = true;
   
    include(__DIR__ . '/config.docker.inc.php');


// ----------------------------------
// OAuth
// ----------------------------------

// // Enable OAuth2 by defining a provider. Use 'generic' here
// $config['oauth_provider'] = null;

// // Provider name to be displayed on the login button
// $config['oauth_provider_name'] = 'Google';

// // Mandatory: OAuth client ID for your Roundcube installation
// $config['oauth_client_id'] = null;

// // Mandatory: OAuth client secret
// $config['oauth_client_secret'] = null;

// // Mandatory: URI for OAuth user authentication (redirect)
// $config['oauth_auth_uri'] = null;

// // Mandatory: Endpoint for OAuth authentication requests (server-to-server)
// $config['oauth_token_uri'] = null;

// // Optional: Endpoint to query user identity if not provided in auth response
// $config['oauth_identity_uri'] = null;

// // Optional: disable SSL certificate check on HTTP requests to OAuth server
// // See https://docs.guzzlephp.org/en/stable/request-options.html#verify for possible values
// $config['oauth_verify_peer'] = true;

// // Mandatory: OAuth scopes to request (space-separated string)
// $config['oauth_scope'] = null;

// // Optional: additional query parameters to send with login request (hash array)
// $config['oauth_auth_parameters'] = [];

// // Optional: array of field names used to resolve the username within the identity information
// $config['oauth_identity_fields'] = null;

// // Boolean: automatically redirect to OAuth login when opening Roundcube without a valid session
// $config['oauth_login_redirect'] = false;

// // Optional: For backends that don't support XOAUTH2/OAUTHBEARER method we can still use
// // OpenIDC protocol to get a short-living password (claim) for the user to log into IMAP/SMTP.
// // That password have to have (at least) the same expiration time as the token, and will be
// // renewed on token refresh.
// // Note: The claim have to be added to 'oauth_scope' above.
// $config['oauth_password_claim'] = null;