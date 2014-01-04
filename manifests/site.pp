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

  # settings - NDK version and gcc version
  $ndk_version = "r9c"
  $gcc_version = "4.6"

  exec {
    "download-android-ndk":
# TODO url = http://dl.google.com/android/ndk/android-ndk-$ndk_version-linux-x86_64.tar.bz2",
      command => "/usr/bin/wget http://sandfish.lan/abob/android/android-ndk-$ndk_version-linux-x86_64.tar.bz2",
      cwd => "/home/admin/droid",
      creates => "/home/admin/droid/android-ndk-$ndk_version-linux-x86_64.tar.bz2",
      require => File["/home/admin/droid"];
    "extract-android-ndk":
      command => "/bin/tar jxf /home/admin/droid/android-ndk-$ndk_version-linux-x86_64.tar.bz2",
      cwd => "/home/admin/droid",
      creates => "/home/admin/droid/android-ndk-$ndk_version",
      require => Exec["download-android-ndk"];
  }
  file {
    "/home/admin/droid/android-ndk":
      ensure => "/home/admin/droid/android-ndk-$ndk_version",
      require => Exec["extract-android-ndk"];
    "/home/admin/droid/android-ndk/default-toolchain":
      ensure => "toolchains/arm-linux-androideabi-$gcc_version/prebuilt/linux-x86_64/",
      require => File["/home/admin/droid/android-ndk"];
    "/home/admin/droid/lib/libgcc.a":
      ensure => "../android-ndk/default-toolchain/lib/gcc/arm-linux-androideabi/$gcc_version/libgcc.a",
      require => [File["/home/admin/droid/android-ndk/default-toolchain"],File["/home/admin/droid/lib"]];
    "/home/admin/droid/lib/libstdc++":
      ensure => "../android-ndk/sources/cxx-stl/gnu-libstdc++/$gcc_version/",
      require => [File["/home/admin/droid/android-ndk/default-toolchain"],File["/home/admin/droid/lib"]];
  }
  puppetfile {
    "/home/admin/shell":
      mode => 0755;
  }
}
