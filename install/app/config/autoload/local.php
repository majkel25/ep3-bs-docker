<?php
/**
 * Local application configuration
 *
 * Insert your local database credentials here,
 * mail configuration, and Twilio WhatsApp notification settings.
 */

return array(

    // ---------------------------------------------------------
    // DATABASE CONFIGURATION
    // ---------------------------------------------------------
    'db' => array(
        'database' => $_ENV["MYSQL_DATABASE"],
        'username' => $_ENV["MYSQL_USER"],
        'password' => $_ENV["MYSQL_PASSWORD"],

        'hostname' => $_ENV["DATABASE_URL"],
        'port'     => $_ENV["DATABASE_PORT"],

        'driver_options' => array(
            PDO::MYSQL_ATTR_SSL_CA                   => '/etc/ssl/certs/ca-certificates.crt',
            PDO::MYSQL_ATTR_SSL_VERIFY_SERVER_CERT   => false,
        ),
    ),


    // ---------------------------------------------------------
    // MAIL CONFIGURATION
    // ---------------------------------------------------------
    // MAIL_TYPE may be: 'sendmail', 'smtp', or 'smtp-tls'
    'mail' => array(
        'type'    => $_ENV["MAIL_TYPE"],
        'address' => $_ENV["MAIL_ADDRESS"],

        // SMTP settings (only used if MAIL_TYPE = smtp or smtp-tls)
        'host' => $_ENV["MAIL_SMTP_HOST"],
        'user' => $_ENV["MAIL_SMTP_USER"],
        'pw'   => $_ENV["MAIL_SMTP_PW"],

        'port' => $_ENV["MAIL_SMTP_PORT"],
        'auth' => $_ENV["MAIL_SMTP_AUTH"], // often 'login'
    ),


    // ---------------------------------------------------------
    // WHATSAPP / TWILIO CONFIGURATION
    // ---------------------------------------------------------
    'whatsapp' => array(
        'enabled' => true,
        'provider' => 'twilio',

        // Twilio credentials – REQUIRED
        'account_sid' => $_ENV["TWILIO_ACCOUNT_SID"],   // ACxxxxxxxxxxxx
        'auth_token'  => $_ENV["TWILIO_AUTH_TOKEN"],    // your Twilio Auth Token

        // Twilio Messaging Service SID (recommended for WhatsApp)
        'messaging_service_sid' => $_ENV["TWILIO_MESSAGING_SERVICE_SID"], // MGxxxxxxxxxxx

        // Fallback sender (only used if Messaging Service is not applied)
        'from' => $_ENV["TWILIO_WHATSAPP_FROM"], // e.g. "whatsapp:+14155238886"

        // WhatsApp group = list of numbers to broadcast to
        'group_enabled' => true,
        'group_numbers' => array(
            // Add as many numbers as you want, format must be:
            // "whatsapp:+447000000000"
            $_ENV["TWILIO_GROUP_NUMBER_1"] ?? null,
            $_ENV["TWILIO_GROUP_NUMBER_2"] ?? null,
            // Add more as needed
        ),

        'timeout' => 5,
    ),


    // ---------------------------------------------------------
    // INTERNATIONALISATION & CURRENCY
    // ---------------------------------------------------------
    'i18n' => array(
        'choice' => array(
            'en-GB' => 'English',
            // More optional languages:
            // 'fr-FR' => 'Français',
            // 'hu-HU' => 'Magyar',
        ),

        'currency' => 'GBP',

        // Fallback locale
        'locale' => 'en-GB',
    ),
);
