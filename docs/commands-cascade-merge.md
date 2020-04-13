Cascade Merge Script
---

> runs through entire repo and merge parent branches in to child branches for:
>  - Isolation Branches
>  - Integration Branches

**NOTE**: Does not affect Feature branches, which must be manually updated 

### Isolation / Feature Branches

> will use the naming conventions used in Isolation / Feature Branches
> to automatically merge parents into children

eg.

##### For Isolation Branches:
 - merge ``master`` into ``iso__redux``
 - merge ``iso__redux`` into ``iso__redux__middlware``
 - merge ``iso__redux__middlware`` into ``iso__redux__middleware__epics``
 - merge ``iso__redux__middlware`` into ``iso__redux__middleware__custom``

##### Feature Branches:
 - merge ``master`` into ``feat__crypto_wallet``
 - merge ``feat__crypto_wallet`` into ``feat__crypto_wallet__transactions``
 - merge ``feat__crypto_wallet__transactions`` into ``feat__crypto_wallet__transactions__history``
 - merge ``feat__crypto_wallet`` into ``feat__crypto_wallet__user_list``

### Integration Branches

> will use the naming conventions used in Integration Branches
> to automatically merge composed Isolation branches into Integration branch

eg.

for ``int__devops__circlci--redux__selectors--redux__middleware__epics``
 - merge ``devops__circlci`` into ``int__devops__circlci--redux__selectors--redux__middleware__epics``
 - merge ``redux__selectors`` into ``int__devops__circlci--redux__selectors--redux__middleware__epics``
 - merge ``redux__middleware__epics`` into ``int__devops__circlci--redux__selectors--redux__middleware__epics``

and for ``int__crypto__bitcoin--redux``
 - merge ``crypto__bitcoin`` into ``int__crypto__bitcoin``
 - merge ``redux`` into ``int__crypto__bitcoin``

### Push All

Once you're done you can push your updates with:

```
git push origin --all
```
