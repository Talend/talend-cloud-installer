class profile::postgresql::activemq (
  $pg_host     = $::activemq::pg_host,
  $pg_port     = $::activemq::pg_port,
  $pg_db       = $::activemq::pg_db,
  $pg_username = $::activemq::pg_username,
  $pg_password = $::activemq::pg_password
)
{
  require ::activemq
  require ::profile::postgresql::config

  $amq_tuning_dir = '/var/lib/activemq_tuning'

  file { 'activemq_tuning_dir':
    ensure => 'directory',
    path   => $amq_tuning_dir,
    owner  => 'root',
    group  => 'root',
    mode   => '0755'
  }

  file { 'activemq_check_version_upgrade':
    ensure  => 'file',
    path    => "${amq_tuning_dir}/check_version_upgrade.sh",
    backup  => false,
    content => file('profile/var/lib/activemq/check_version_upgrade.sh'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => File['activemq_tuning_dir']
  }

  file { 'activemq_optimizations_table.sql':
    ensure  => 'file',
    path    => "${amq_tuning_dir}/postgresql_optimizations_table.sql",
    backup  => false,
    content => file('profile/var/lib/activemq/postgresql_optimizations_table.sql'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File['activemq_tuning_dir']
  }

  file { 'activemq_optimizations.sql':
    ensure  => 'file',
    path    => "${amq_tuning_dir}/postgresql_optimizations.sql",
    backup  => false,
    content => file('profile/var/lib/activemq/postgresql_optimizations.sql'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File['activemq_tuning_dir']
  }

  $exec_amq_optimizations_table_sql_creation = "psql -q -U ${pg_username} -h ${pg_host} \
    -d ${pg_db} -f ${amq_tuning_dir}/postgresql_optimizations_table.sql \
    && touch ${amq_tuning_dir}/postgresql_optimizations_table.sql.created"
  exec { 'activemq_optimizations_table_sql_creation':
    path        => '/usr/bin:/usr/sbin:/bin',
    environment => "PGPASSWORD=${pg_password}",
    command     => $exec_amq_optimizations_table_sql_creation,
    creates     => "${amq_tuning_dir}/postgresql_optimizations_table.sql.created",
    require     => File['activemq_optimizations_table.sql']
  }

  $exec_get_current_optimizations_versions = "psql -A -t -q -U ${pg_username} \
    -h ${pg_host} -d ${pg_db} \
    -c 'SELECT MAX(version) FROM tmp_activemq_optimizations WHERE filename = \'postgresql_optimizations.sql\' \
    -o ${amq_tuning_dir}/postgresql_optimizations_last_version.txt"
  exec { 'get_current_optimizations_versions':
    path        => '/usr/bin:/usr/sbin:/bin',
    environment => "PGPASSWORD=${pg_password}",
    command     => $exec_get_current_optimizations_versions,
    require     => Exec['activemq_optimizations_table_sql_creation']
  }

  $only_if_version_optimizations_check = "${amq_tuning_dir}/check_version_upgrade.sh \
    ${amq_tuning_dir}/postgresql_optimizations.sql \
    ${amq_tuning_dir}/postgresql_optimizations_last_version.txt"

  exec { 'stopping_activemq':
    path    => '/usr/bin:/usr/sbin:/bin:/sbin',
    command => 'sleep 3m && systemctl stop activemq.service',
    onlyif  => $only_if_version_optimizations_check,
    require => [
      Exec['get_current_optimizations_versions'],
      File['activemq_optimizations.sql']
    ]
  }

  exec {'activemq_optimizations.sql':
    path        => '/usr/bin:/usr/sbin:/bin',
    environment => "PGPASSWORD=${pg_password}",
    command     => "psql -U ${pg_username} -h ${pg_host} -d ${pg_db} -q -f ${amq_tuning_dir}/postgresql_optimizations.sql",
    onlyif      => $only_if_version_optimizations_check,
    require     => [
      Exec['stopping_activemq'],
      Exec['get_current_optimizations_versions'],
      File['activemq_optimizations.sql']
    ]
  }

  exec { 'starting_activemq':
    path    => '/usr/bin:/usr/sbin:/bin:/sbin',
    command => 'systemctl start activemq.service',
    onlyif  => $only_if_version_optimizations_check,
    require => Exec['activemq_optimizations.sql']
  }
}
