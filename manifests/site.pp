define puppetfile($mode = 0644, $owner = "root", $group = "root") {
  file {
    $title: 
      source => "/var/lib/puppet/files/$title",
      mode => $mode,
      owner => $owner,
      group => $group;
  }
}

define gitrepo($url) {
  exec {
    "/usr/bin/git checkout $url $title":
      creates => $title,
      require => Package["git"];
  }
}

node default {
  package {
    "vim-enhanced": ensure => present;
    "git": ensure => present;
  }
  user {
    "admin": ensure => present;
  }
  file {
    "/home/admin": ensure => directory, require => User["admin"], owner => "admin";
    "/home/admin/droid": ensure => directory, require => File["/home/admin"];
    "/home/admin/droid/lib": ensure => directory, require => File["/home/admin/droid"];
    "/home/admin/droid/include": ensure => directory, require => File["/home/admin/droid"];
    "/home/admin/tmp": ensure => directory, require => File["/home/admin"];
  }
  gitrepo {
    "/home/admin/droid/bin":
      url => "https://github.com/ddrown/android-ports-tools.git",
      require => File["/home/admin/droid"];
  }
# TODO Put the Android NDK under ~/droid/android-ndk
# TODO put ~/droid/bin/ into your path
}
