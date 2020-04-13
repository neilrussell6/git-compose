Isolation Branch
===

> A single technology in isolation

eg. ``iso__redux`` or ``iso__redux__middleware__epics`` or ``iso__devops__circleci``

### Includes

 - essential dependencies
 - minimal example

### Naming

 - prefix with ``iso__``
 - and use double underscores ``__`` to indicate hierarchy

eg.
The following branches:
 - ``iso__redux``
 - ``iso__redux__middlware``
 - ``iso__redux__middleware__epics``
 - ``iso__redux__middleware__custom``
 - ``iso__redux__selectors``
create the corresponding hierarchy:
```
master
+-- iso__redux
|   +-- iso__redux__middlware
|   |   +-- iso__redux__middleware__epics
|   |   +-- iso__redux__middleware__custom
|   +-- iso__redux__selectors
```

### Creating

To create an Isolation branch simply check it out from a parent
eg.
to create ``iso__redux__middlware`` from ``iso__redux``
```
git checkout iso__redux
git checkout -b iso__redux__middlware
git remote add iso__redux__middlware <url>
git push iso__redux__middlware
```

### Merging

[Auto-Merging](commands-cascade-merge.md) scripts will use the naming conventions above
to automatically merge parents into children eg.
 - merge ``master`` into ``iso__redux``
 - merge ``iso__redux`` into ``iso__redux__middlware``
 - merge ``iso__redux__middlware`` into ``iso__redux__middleware__epics``
 - merge ``iso__redux__middlware`` into ``iso__redux__middleware__custom``

**IMPORTANT**: children MUST NEVER be merged into parents

**NOTE**: ``master`` is the root Isolation branch
