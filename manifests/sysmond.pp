class newrelic::sysmond ($license, $labels='')
{
  include newrelic::repo

  $newrelic_license = $license
  if $newrelic_license == undef{ fail('$newrelic_license not defined') }

  package { 'newrelic-sysmond':
      ensure  => latest,
      notify  => Service['newrelic-sysmond'],
      require => Class['newrelic::repo'];
  }

  file{
    '/etc/newrelic/nrsysmond.cfg':
      ensure  => present, 
      owner   => 'newrelic',
      group   => 'newrelic',
      mode    => '0640',
      require => Package['newrelic-sysmond'],
      notify  => Service['newrelic-sysmond'],
      content => template('newrelic/nrsysmond.cfg.erb');
  }

  service { 'newrelic-sysmond':
    enable     => true,
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['newrelic-sysmond'];
  }
}
