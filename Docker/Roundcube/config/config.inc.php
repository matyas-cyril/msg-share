<?php
    $config['plugins'] = [
        'archive',
        'zipdownload',
    ];
    $config['log_driver'] = 'stdout';
    $config['zipdownload_selection'] = true;
    $config['des_key'] = 'IMs6J7SQwCzOFcOvV9AngNKr';
    $config['enable_spellcheck'] = true;
    $config['spellcheck_engine'] = 'pspell';
    $config['imap_vendor'] = 'cyrus';
    //$config['use_https'] = true

    // Pour voir les fails au niveau OAuth
    $config['debug_level'] = 1;
    $config['oauth_provider'] = 'generic';
    $config['oauth_provider_name'] = 'Keycloak';
    $config['oauth_client_id'] = 'roundcube';
    $config['oauth_client_secret'] = 'S9CC8kyju55sUvIv6g1zaa30eNPyjx0k';
    $config['oauth_redirect_uri'] = 'http://roundcube.example.com:20080/?_task=login&_action=oauth_callback';
    $config['oauth_post_logout_redirect'] = 'http://roundcube.example.com:20080/';
    $config['oauth_auth_uri'] = 'https://keycloak.example.com:8443/realms/example.com/protocol/openid-connect/auth';
    $config['oauth_token_uri'] = 'https://keycloak.example.com:8443/realms/example.com/protocol/openid-connect/token';
    $config['oauth_identity_uri'] = 'https://keycloak.example.com:8443/realms/example.com/protocol/openid-connect/userinfo';
    $config['oauth_scope'] = 'openid profile email';
    $config['oauth_identity_fields'] = ['email'];  
    
    // $config['oauth_login_redirect'] = true;
    // Permet de rediriger directement vers la page de login OAuth

    include(__DIR__ . '/config.docker.inc.php');
