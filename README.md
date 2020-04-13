GIT Compose
===

> Compose GIT branches and cascade merge updates

Assumes your project is using the ``IIF™`` branching pattern:

 - Isolation Branches
 - Integration Branches
 - Feature Branches

### Isolation Branch

> A single technology in isolation, prefixed with ``iso__``.

[read more ...](docs/branches-isolation.md)

### Integration Branch

> Integration between multiple technologies (ie. composed branches), prefixed with ``int__``.

[read more ...](docs/branches-integration.md)

### Feature Branch

> One or more Isolation and/or Integration Branches composed to create a foundation upon which a feature is built, prefixed with ``feat__``.


[read more ...](docs/branches-feature.md)

### Other Branches

> All other branches can be named whatever you want so long as they do not start with iso__, int__ or feat__ they will not be touched, by the commands below.

Quick Start
---

 - Install
   ```
   npm i -D git-compose
   ```

 - Make sure your branches follow the ``IIF™`` branch naming conventions.

 - Use the commands below

Commands
---

 - print project branch hierarchy
   ```
   npx git-compose print_heirarchy
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

Complete Indemnity
---

The ``IIF™`` standard is an experiment, use with discretion.
I take no responsibility for any damage or loss resulting from the use of this package. 
