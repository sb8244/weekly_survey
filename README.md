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
- [x] - Add a new Survey
- [ ] - Add with active_until stat
- [ ] - Update existing survey (question, active_until)
- [x] - View tally of votes
- [hold] - Repeat a survey every week, start / stop on particular time

## ENV

* ADMIN_CREDENTIALS: Multiple pairs of logins for the system. This allows for credentials
                     to be given to a single user without complex user management. The credentials
                     are in the form `user::pass||user::pass||etc`
