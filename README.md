# WeeklySurvey

```
ADMIN_CREDENTIALS="admin::password||admin2::pass" PORT=4005 mix phx.server
```

## TODO

- [x] Allow removal of a vote
- [x] Disallow double vote on same survey
- [x] When loading from localstorage, refresh the page so that voting is back
- [x] usable prettiness
- [ ] prettier
- [ ] Admin section
- [ ] - Add a new Survey
- [ ] - Repeat a survey every week, start / stop on particular time
- [ ] - View tally of votes

## ENV

* ADMIN_CREDENTIALS: Multiple pairs of logins for the system. This allows for credentials
                     to be given to a single user without complex user management. The credentials
                     are in the form `user::pass||user::pass||etc`
