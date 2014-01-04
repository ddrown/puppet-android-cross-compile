define puppetfile($mode = 0644, $owner = "root", $group = "root") {
  file {
    $title: 
      source => "/var/lib/puppet/files/$title",
      mode => $mode,
      owner => $owner,
      group => $group;
  }
}

define gitrepo($url,$directory) {
  exec {
    "/usr/bin/git checkout $url $directory":
      creates => $directory,
      requires => Package["git"];
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
    "/home/admin/droid": ensure => directory, require => User["admin"];
    "/home/admin/droid/lib": ensure => directory, require => File["/home/admin/droid"];
    "/home/admin/droid/include": ensure => directory, require => File["/home/admin/droid"];
    "/home/admin/tmp": ensure => directory, require => User["admin"];
  }
  gitrepo {
    url => "https://github.com/ddrown/android-ports-tools.git",
    directory => "/home/admin/droid/bin",
    require => File["/home/admin/droid"];
  }
# TODO Put the Android NDK under ~/droid/android-ndk
# TODO put ~/droid/bin/ into your path
}
