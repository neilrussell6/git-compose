Package Branches
---

> Isolation, muliple Isolation and/or Integration Branches on their own or composed to create a foundation upon which a reusable package (eg. NPM package) is built

### Includes

 - everything required for the resuable `package

### Naming

 - prefix with ``pkg__``
 - and use double underscores ``__`` to indicate hierarchy

eg.
The following branches:
 - ``pkg__crypto_wallet``
 - ``pkg__crypto_wallet__transactions``
 - ``pkg__crypto_wallet__transactions__history``
 - ``pkg__crypto_wallet__user_list``
create the corresponding hierarchy:
```
master
+-- pkg__crypto_wallet
|   +-- pkg__crypto_wallet__transactions
|   |   +-- pkg__crypto_wallet__transactions__history
|   +-- pkg__crypto_wallet__user_list
```

### Creating

To create a Package branch simply check it out from a parent
eg.
to create ``pkg__crypto_wallet__hardware_signing`` from ``pkg__crypto_wallet``
```
git checkout pkg__crypto_wallet
git checkout -b pkg__crypto_wallet__hardware_signing
git remote add pkg__crypto_wallet__hardware_signing <url>
git push pkg__crypto_wallet__hardware_signing
```

### Merging

[Auto-Merging](commands-cascade-merge.md) scripts will use the naming conventions above
to automatically merge parents into children eg.
 - merge ``ROOT_BRANCH`` into ``pkg__crypto_wallet``
 - merge ``pkg__crypto_wallet`` into ``pkg__crypto_wallet__transactions``
 - merge ``pkg__crypto_wallet__transactions`` into ``pkg__crypto_wallet__transactions__history``
 - merge ``pkg__crypto_wallet`` into ``pkg__crypto_wallet__user_list``

**IMPORTANT**: Children MUST NEVER be merged into parents

**IMPORANT**: Package branches MUST NEVER be merged into Isolation branches (including ``ROOT_BRANCH``) or Integration branches
