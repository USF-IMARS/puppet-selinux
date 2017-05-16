# define: selinux_thias::dircontext
#
# Change SELinux file security context recursively in a directory.
#
# See filecontext.pp
#
define selinux_thias::dircontext (
  $seltype,
  $object = $title,
  $copy   = false,
) {

  selinux_thias::filecontext { $title:
    seltype => $seltype,
    recurse => true,
    copy    => $copy,
  }

}
