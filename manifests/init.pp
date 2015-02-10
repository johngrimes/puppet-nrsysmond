class nrsysmond($new_relic_license_key) {
  include apt

  apt::key { 'newrelic':
    key        => '548C16BF',
    key_source => 'https://download.newrelic.com/548C16BF.gpg',
  }

  apt::source { 'newrelic':
    location    => 'http://apt.newrelic.com/debian/',
    release     => 'newrelic',
    repos       => 'non-free',
    include_src => false,
    require     => Apt::Key['newrelic']
  }

  package { 'newrelic-sysmond':
    ensure  => 'present',
    require => Apt::Source['newrelic'],
    notify  => Exec['nrsysmond-config']
  }

  exec { 'nrsysmond-config':
    command     => "/usr/sbin/nrsysmond-config --set license_key=${new_relic_license_key}",
    refreshonly => true,
    require     => Package['newrelic-sysmond']
  }

  service { 'newrelic-sysmond':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => [
      Package['newrelic-sysmond'],
      Exec['nrsysmond-config']
    ]
  }
}
