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
    "/usr/bin/git clone $url $title":
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

  $ndk_version = "r9c"
  exec {
    "download-android-ndk":
      command => "/usr/bin/env http_proxy=http://sandfish.lan:3128 wget http://dl.google.com/android/ndk/android-ndk-$ndk_version-linux-x86_64.tar.bz2",
      cwd => "/home/admin/droid",
      creates => "/home/admin/droid/android-ndk-$ndk_version-linux-x86_64.tar.bz2",
      require => File["/home/admin/droid"];
    "extract-android-ndk":
      command => "/usr/bin/tar jxf /home/admin/droid/android-ndk-$ndk_verison.tar.bz2",
      cwd => "/home/admin/droid",
      creates => "/home/admin/droid/android-ndk-$ndk_version",
      require => Exec["download-android-ndk"];
  }
# TODO ndk symlink
# TODO put ~/droid/bin/ into your path
}
