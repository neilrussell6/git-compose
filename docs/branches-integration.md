Integration Branch
===

> Integration between multiple technologies

eg. ``develop`` is an Integration Branch that integrates all core/essential technologies

### Includes

 - essential dependencies
 - minimal example

### Naming

 - prefix with ``int__``
 - and use double dashes ``--`` to separate Isolation branches used to compose the Integration branch

eg.
```
int__devops__circlci--redux__nav--redux__middleware__epics
```

### Creating

To create an Integration branch, use the [Build-Integration-Branch Script](git-build-integration-branch.md)

eg. to create an Integration branch from the following Isolation branches:
 - ``iso__devops__circleci``
 - ``iso__redux__selectors``
 - ``iso__redux__middleware__epics``

run the following command:
```
npm run git:branch:integration:build -- "int__devops__circlci--redux__selectors--redux__middleware__epics"
```

**NOTE**: you do no have to include the Isolation branch prefixes (``iso__``) ^ in the Integration branch name, this is assumed.

### Merging

[Auto-Merging](git-cascade-merge.md) scripts will use the naming conventions above
to automatically merge composed Isolation branches into Integration branch

eg.

for ``int__devops__circlci--redux__selectors--redux__middleware__epics``
 - merge ``devops__circlci`` into ``int__devops__circlci--redux__selectors--redux__middleware__epics``
 - merge ``redux__selectors`` into ``int__devops__circlci--redux__selectors--redux__middleware__epics``
 - merge ``redux__middleware__epics`` into ``int__devops__circlci--redux__selectors--redux__middleware__epics``

and for ``int__crypto__bitcoin--redux``
 - merge ``crypto__bitcoin`` into ``int__crypto__bitcoin``
 - merge ``redux`` into ``int__crypto__bitcoin``

**IMPORTANT**: Integration branches MUST NEVER be merged into Isolation branches (including ``master``)
