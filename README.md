user-owner [![Build Status](https://secure.travis-ci.org/c42/user-owner.png?branch=master)](http://travis-ci.org/c42/user-owner)
==========
 
Setup
-----

- Create an admin for user-owner by running:

```bash
$ rake db:admin
```

- You can generate a CSO Admin and a Field agent as well by running:

```bash
$ rake db:users
```

- You will now have the following users set up:

```json
CSO Admin: {email: "cso_admin@admin.com", password: "cso_admin"}
Field Agent: {email: "field_agent@admin.com", password: "field_agent"}
```

- These users belong to **My Organization**