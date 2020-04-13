Feature Branches
---

> One or more Isolation and/or Integration Branches composed to create a foundation upon which a feature is built

eg. ``devops--redux__epics--redux__nav`` + ``crypto`` as a basis for a crypto wallet app, resulting in a Feature Branch called ``crypto_wallet``

### Includes

 - essential dependencies
 - minimal example

### Naming

 - prefix with ``feat__``
 - and use double underscores ``__`` to indicate hierarchy

eg.
The following branches:
 - ``feat__crypto_wallet``
 - ``feat__crypto_wallet__transactions``
 - ``feat__crypto_wallet__transactions__history``
 - ``feat__crypto_wallet__user_list``
create the corresponding hierarchy:
```
master
+-- feat__crypto_wallet
|   +-- feat__crypto_wallet__transactions
|   |   +-- feat__crypto_wallet__transactions__history
|   +-- feat__crypto_wallet__user_list
```

### Creating

To create a Feature branch simply check it out from a parent
eg.
to create ``feat__crypto_wallet__hardware_signing`` from ``feat__crypto_wallet``
```
git checkout feat__crypto_wallet
git checkout -b feat__crypto_wallet__hardware_signing
git remote add feat__crypto_wallet__hardware_signing <url>
git push feat__crypto_wallet__hardware_signing
```

### Merging

[Auto-Merging](commands-cascade-merge.md) scripts will use the naming conventions above
to automatically merge parents into children eg.
 - merge ``master`` into ``feat__crypto_wallet``
 - merge ``feat__crypto_wallet`` into ``feat__crypto_wallet__transactions``
 - merge ``feat__crypto_wallet__transactions`` into ``feat__crypto_wallet__transactions__history``
 - merge ``feat__crypto_wallet`` into ``feat__crypto_wallet__user_list``

**IMPORTANT**: Children MUST NEVER be merged into parents

**IMPORANT**: Feature branches MUST NEVER be merged into Isolation branches (including ``master``) or Integration branches
