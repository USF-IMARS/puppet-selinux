# puppet-selinux

## Overview

Transparently create SELinux modules based on AVC denial messages, to easily
allow otherwise denied system operations, and set file and directory security contexts

* `selinux_thias` : Main class which makes sure the basics are set up correctly.
* `selinux_thias::audit2allow` : Definition for allowing based on avc denial messages.
* `selinux_thias::filecontext` : Manage SELinux file context.
* `selinux_thias::dircontext` : Manage SELinux file context recursively (directories).

Note : For SELinux booleans, use the Puppet built-in `selboolean` type.


## selinux

Main SELinux class to be included on all nodes. If SELinux isn't available,
it does nothing anyway.


## selinux_thias::audit2allow

Local SELinux modules, created from avc denial messages to be allowed.

The SELinux modules created and loaded are automatically prefixed with "local"
in order to never conflict with modules from the currently loaded policy.
You can get a list of existing loaded modules with : `semodule -l`

Example :

```puppet
selinux_thias::audit2allow { 'mydaemon':
  source => "puppet:///modules/${module_name}/selinux/messages.mydaemon",
}
```

The content of the above files is based on kernel/audit avc denial messages,
typically found in `/var/log/audit/audit.log`.
See the included `messages.nrpe` file for an example.

When using it multiple times on a single node, the `selinux_thias::concat` parameter
can be switched to `true` in order to create a single SELinux module instead
of one each time it is used. This speeds up Puppet runs a lot.


## selinux_thias::filecontext and selinux::dircontext

Change SELinux file security context persistently using `semanage`.

To see all existing default contexts for file path patterns :

```bash
semanage fcontext -l
```

To see only the custom ones not included in the base policy, set manually or
by this module :

```bash
semanage fcontext -l -C
```

Example to set a new recursive file context entry (for a directory), which
will run the 'semanage' and 'restorecon' tools to apply the SELinux Type to
the specified path both persistently and immediately.

```puppet
selinux_thias::dircontext { '/data/www':
  seltype => 'httpd_sys_content_t',
}
```

To set the context for just a file, without recursing :

```puppet
selinux_thias::filecontext { '/srv/foo.txt':
  seltype => 'public_content_t',
}
```

To copy the context from another file, set 'copy' to `true` and 'seltype' to
the source file or directory :

```puppet
selinux_thias::dircontext { '/export/home':
  seltype => '/home',
  copy    => true,
}
```
