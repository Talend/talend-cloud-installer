class profile::amazon_ses_smtp (

  $domain                 = undef,
  $smtp_accces_key_id     = undef,
  $smtp_secret_access_key = undef,

) {

  class { 'amazon_ses':
    domain        => $domain,
    smtp_username => $smtp_accces_key_id,
    smtp_password => amazon_ses_smtp_password($smtp_secret_access_key),
    smtp_port     => 25,
  }

}
