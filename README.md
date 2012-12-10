user-owner [![Build Status](https://secure.travis-ci.org/c42/user-owner.png?branch=master)](http://travis-ci.org/c42/user-owner)
==========
 
Setup
-----

Setup
=====

Database
--------

- You need to set up a local database. Any of the databases [supported by Rails](http://api.rubyonrails.org/classes/ActiveRecord/Migration.html#label-Database+support) will work, but [PostgreSQL](http://www.postgresql.org/) is recommended.
- Some tutorials are [here](https://help.ubuntu.com/community/PostgreSQL) and [here](http://wiki.postgresql.org/wiki/Detailed_installation_guides). If you're on a mac, use Heroku's [Postgres.app](http://postgresapp.com/)
- Make a copy of the `database.yml.sample` provided (in the `config` directory); name it `database.yml`
- Fill in the details for your database.

For example, the `database.yml` will look something like this if you're using Postgres.app:

```YAML
development:
  adapter: postgresql
  encoding: utf8
  database: survey_web_dev
  pool: 5
  username: 
  password: 
  host: localhost

test:
  adapter: postgresql
  encoding: utf8
  database: survey_web_test
  pool: 5
  username: 
  password:
  host: localhost

production:
  adapter: postgresql
  encoding: utf8
  database: survey_web_prod 
  pool: 5
  username:
  password:
```

- Navigate to the survey-web directory from a terminal.
- Type `rails server`
- If the server starts up without complaining, your database is set up correctly.

Gems
----

- To install all the libraries required by this application, navigate to the survey-web directory from a terminal.
- Type `gem install bundler` and then `bundle install`

Users
-----

- Create an admin user for user-owner by running the following. This step is required.

```bash
$ rake db:admin
```

- You can generate a CSO Admin and a Field agent as well by running the following. This is optional.

```bash
$ rake db:users
```

- You will now have the following users set up:

```json
CSO Admin: {email: "cso_admin@admin.com", password: "cso_admin"}
Field Agent: {email: "field_agent@admin.com", password: "field_agent"}
```

- These users belong to **My Organization**

Finally...
-------
- Start the survey-web app by typing `rails server` from the console.
- Use `rails server -p 3001` if a client app is running on the default port `3000`.