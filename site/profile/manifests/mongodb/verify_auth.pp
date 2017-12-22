class profile::mongodb::verify_auth (
  $auth_wanted = $::profile::mongodb::mongo_auth_asked,
  $flag_file   = $::profile::mongodb::mongo_auth_flag_path,
) {

  # This class must be used After the configuration but Before the service start.
  # It will verify that auth was enabled and force it if it was the case.
  if $auth_wanted {
    # $auth is asked, but do we were in auth mode before ?
    # if no, we must start first in no-auth, then ::profile::mongodb::auth will restart in auth
    exec { 'Disabling MongoDB auth for first init':
      command => 'sed -i \'s/^\s*security.authorization: .\+$/security.authorization: disabled/\' /etc/mongod.conf',
      path    => '/bin',
      unless  => "test -f ${flag_file}"
    }
    # else, we were in auth, we start in auth, that's OK
  } else {
    #auth is not asked (facter absent cause AMI change ?)
    #Do we were in auth ?
    exec { 'Enabling MongoDB auth by flag file':
      command => 'sed -i \'s#^\s*security.authorization: .\+$#security.authorization: enabled\
\nsecurity.keyFile: /var/lib/mongo/shared_key#\' /etc/mongod.conf',
      path    => '/bin',
      onlyif  => "test -f ${flag_file}"
    }

    exec { 'Enabling MongoDB auth with facter for next time':
      command => 'echo "mongo_replset_auth_enable=true" > /etc/facter/facts.d/auth.txt',
      path    => '/bin',
      onlyif  => "test -f ${flag_file}"
    }
  }
}
