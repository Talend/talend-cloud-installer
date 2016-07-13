#
# Finalizes concat resources for puppetProfile and puppetRole files
#
class profile::common::concat {

  concat { '/etc/sysconfig/puppetProfile':
    owner => 'root',
    group => 'root',
    mode  => '0644',
    force => true,
  }

  concat { '/etc/sysconfig/puppetRole':
    owner => 'root',
    group => 'root',
    mode  => '0644',
    force => true,
  }

}
