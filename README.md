# Content Security Policy (CSP) Violation Report Handler

Tiny Sinatra application to parse CSP violation reports,
format them nicely, and forward them on to an email address
using sendmail (via Pony gem). Easy to deploy with Passenger,
or any other app container. Currently requires PostgreSQL,
but could easily replace with any other database.

## Setup

1. Create a PostgreSQL database to use with the app.
2. Save a copy of __config/config.sample.yml__ as __config/config.yml__.
3. Edit config/config.yml wih the settings that make sense for you.
4. Run: ```MIGRATE=true bundle exec ruby boot.rb```

Finally, run rackup:

    bundle exec rackup


### Multiple Recipients

The "recipients" option in config.yml is passed as-is to sendmail
(via Pony), so just separate multiple recipients with commas.

## Testing

Testing is easy with curl. Replace ```http://localhost:9292/```
(the last argument) with your URL:

    curl -H 'Content-Type: application/csp-report;charset=utf-8' --data '{"csp-report":{"document-uri":"https://example.com/foo/bar","referrer":"https://www.google.com/","violated-directive":"default-src self","original-policy":"default-src self; report-uri /csp-hotline.php","blocked-uri":"http://evilhackerscripts.com"}}' 'http://localhost:9292/'
