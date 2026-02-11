# Admin API quick reference

Base URL: `/api/admin`

All routes require Bearer token and admin role.

- `GET /users`
- `DELETE /users/:id`

Notes:
- Admin cannot delete own account.
- Deleting user also deletes their listings.
- If deleted user had reservations on other listings, those reservations are cleared.
