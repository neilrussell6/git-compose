GIT Compose
===

> Compose GIT branches and cascade merge updates

Assumes your project is using the ``IIP™`` branching pattern:

 - Isolation Branches
 - Integration Branches
 - Package Branches

### Isolation Branch

> A single technology in isolation, prefixed with ``iso__``.

[read more ...](docs/branches-isolation.md)

### Integration Branch

> Integration between multiple technologies (ie. composed branches), prefixed with ``int__``.

[read more ...](docs/branches-integration.md)

### Package Branch

> Isolation, muliple Isolation and/or Integration Branches on their own or composed to create a foundation upon which a reusable package (eg. NPM package) is built, prefixed with ``pkg__``.

[read more ...](docs/branches-package.md)

### Other Branches

> All other branches can be named whatever you want so long as they do not start with iso__, int__ or feat__ they will not be touched, by the commands below.

Quick Start
---

 - Install
   ```
   npm i -D git-compose
   ```

 - Make sure your branches follow the ``IIP™`` branch naming conventions.

 - Use the commands below

Commands
---

 - print project branch hierarchy
   ```
   npx git-compose print_heirarchy
   ```
   verbose mode (shows full branch names)
   ```
   npx git-compose print_heirarchy -v
   ```
   fetch remotes
   ```
   npx git-compose print_heirarchy -f
   ```
 - [build an integration branch](docs/commands-build-integration-branch.md)
   ```
   npx git-compose build_integration_branch <branch>
   ```
   name must be prefixed with ``int__`` and must contain existing branches eg. ``int__branch1--branch_sub2--branch_sub2_subsub1``
 - [cascade merge updates through all branches](docs/commands-cascade-merge.md)
   ```
   npx git-compose cascade_merge
   ```

Env file
---

Add an ``.env`` file to your project to configure this script.
eg.
```
ROOT_BRANCH=iso__base
ERROR_LOG_PATH=git-branch-errors.txt
```

Complete Indemnity
---

The ``IIP™`` standard is an experiment, use with discretion.
I take no responsibility for any damage or loss resulting from the use of this package. 
