# Content Security Policy (CSP) Violation Report Handler

Tiny Sinatra application to parse CSP violation reports,
save them to database, and optionally forward them on to an email
address using sendmail (via Pony gem). Easy to deploy with Passenger,
or any other Rack app container. Currently requires PostgreSQL,
but another database could probably be used by editing the schema
creation SQL in Rakefile.

It attempts to coalesce duplicate reports using SHA-256 hashes
of the report body, since hundreds of visits to a site's
homepage will generate many of the exact same report. This serves as
a basic sanity check, but more could definitely be done to coalesce
reports that are about the same fundamental issue, and I'm not
sure how the hashing and JSON parsing will hold up under load.

## Setup

1. Create a PostgreSQL database to use with the app.
2. Save a copy of __config/config.sample.yml__ as __config/config.yml__.
3. Edit __config/config.yml__ wih the settings that make sense for you.
4. Install gems: ```bundle install```
5. Create the database: ```bundle exec rake db:create```

Finally, run rackup if you want to start a development server:

    bundle exec rackup


### Multiple Recipients

The "recipients" option in config.yml is passed as-is to sendmail
(via Pony), so just separate multiple recipients with commas.

### Administration Security

There is no security on the admin site. I recommend setting up a
password for /admin in your web server, or limiting it to a certain
IP range.

## Testing

Testing is easy with curl. Replace ```http://localhost:9292/```
(the last argument) with your URL:

    curl -H 'Content-Type: application/csp-report;charset=utf-8' --data '{"csp-report":{"document-uri":"https://example.com/foo/bar","referrer":"https://www.google.com/","violated-directive":"default-src self","original-policy":"default-src self; report-uri /csp-hotline.php","blocked-uri":"http://evilhackerscripts.com"}}' 'http://localhost:9292/'
