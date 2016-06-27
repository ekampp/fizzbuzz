# FizzBuzz API

This is the Ruby API that exposes a [fizzbuzz](https://en.wikipedia.org/wiki/Fizz_buzz) number sequence.

To create the database:

```bash
initdb db/posgres
postgres -D db/postgres
```

Then in another terminal window create the tables

```bash
bundle exec rake db:create db:migrate
```

Then terminate the database server and start the API:

```bash
bundle exec foreman start -f Procfile.dev
```

This will start a JSON API webserver on [localhost:9292](http://localhost:9292).
