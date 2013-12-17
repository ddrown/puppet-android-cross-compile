define puppetfile($mode = 0644, $owner = "root", $group = "root") {
  file {
    $title: 
      source => "/var/lib/puppet/files/$title",
      mode => $mode,
      owner => $owner,
      group => $group;
  }
}

node default {
  package {
    "vim-enhanced": ensure => present;
  }
  puppetfile {
    "/etc/hosttype": ;
  }
}
