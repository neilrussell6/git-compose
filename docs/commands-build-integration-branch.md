Build Integration Branch Script
---

> builds an Integration branch from multiple Isolation branches

eg. to create an Integration branch from the following Isolation branches:
 - ``iso__devops__circleci``
 - ``iso__redux__selectors``
 - ``iso__redux__middleware__epics``

run the following command:
```
npm run git:branch:integration:build -- "int__devops__circlci--redux__selectors--redux__middleware__epics"
```

**NOTE**: you do no have to include the Isolation branch prefixes (``iso__``) ^ in the Integration branch name, this is assumed.
