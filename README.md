# puppet-selinux

## Overview

Transparently create SELinux modules based on AVC denial messages, to easily
allow otherwise denied system operations, and set file and directory security contexts

* `selinux` : Main class which makes sure the basics are set up correctly.
* `selinux::audit2allow` : Definition for allowing based on avc denial messages.
* `selinux::filecontext` : Manage SELinux file context.
* `selinux::dircontext` : Manage SELinux file context recursively (directories).

Note : For SELinux booleans, use the Puppet built-in `selboolean` type.


## selinux

Main SELinux class to be included on all nodes. If SELinux isn't available,
it does nothing anyway.

### Parameters:
* `concat`: Boolean that concatenates every audit2allow SELinux module and creates
a unique file ready to be compiled. This is a really useful param if you use the
audit2allow definition in differents manifests because SELinux will compile a single
module from a single file instead of compile every audit2allow module file.


## selinux::audit2allow

Local SELinux modules, created from avc denial messages to be allowed.

The SELinux modules created and loaded are automatically prefixed with "local"
in order to never conflict with modules from the currently loaded policy.
You can get a list of existing loaded modules with : `semodule -l`

Example :

```puppet
selinux::audit2allow { 'mydaemon':
  source => "puppet:///modules/${module_name}/selinux/messages.mydaemon",
}
```

The content of the above files is based on kernel/audit avc denial messages,
typically found in `/var/log/audit/audit.log`.
See the included `messages.nrpe` file for an example.


## selinux::filecontext and selinux::dircontext

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
selinux::dircontext { '/data/www':
  seltype => 'httpd_sys_content_t',
}
```

To set the context for just a file, without recursing :

```puppet
selinux::filecontext { '/srv/foo.txt':
  seltype => 'public_content_t',
}
```

To copy the context from another file, set copy to true and 'seltype' to the source file:

```puppet
selinux::filecontext { '/export/home':
  seltype => '/home',
  copy    => true,
}
```
