# Class: amavisd_clamav
#
# centos's amavisd-new package contains clamav files and functionality
# since they are comingled at the package level, they are being kept
# together here as well, to avoid tracking logical dependencies between
# two modules
#
# Requires:
#   class spamassassin
#
class amavisd_clamav(
  $max_servers = 2,
  $enable_dkim_verification = 1,
  $amavisdDomain = $amavisdDomain  # Support legacy global $amavisdDomain
) {

    include spamassassin

    package {
        "amavisd-new":;
        "clamav":;
        "lha":;
        "pax":;
        "ripole":;
        "unrar":;
        "zoo":;
    } # package

    file {
        "/etc/amavisd/amavisd.conf":
            content => template("amavisd_clamav/amavisd.conf.erb"),
            require => Package["amavisd-new"],
            notify  => Service["amavisd"];
        "/etc/freshclam.conf":
            source  => "puppet:///modules/amavisd_clamav/freshclam.conf",
            require => Package["clamav"];
        "/etc/sysconfig/freshclam":
            source  => "puppet:///modules/amavisd_clamav/freshclam.sysconfig",
            require => Package["clamav"];
        "/etc/cron.d/clamav-update":
            mode    => 600,
            source  => "puppet:///modules/amavisd_clamav/cron.d-clamav-update",
            require => Package["clamav"];
        "/var/log/freshclam.log":
            ensure => file,
            owner => 'clam',
            group => 'clam',
            require => Package['clamav'];
    } # file

    service {
        "amavisd":
            ensure  => running,
            enable  => true,
            require => Package["amavisd-new"];
        "clamd.amavisd":
            enable  => true,
            ensure  => running,
            require => Package["amavisd-new"],
            before  => Service["amavisd"];
    } # service

} # class amavisd_clamav
