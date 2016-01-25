# Content Security Policy (CSP) Violation Report Handler

Tiny Sinatra application to parse CSP violation reports,
format them nicely, and forward them on to an email address
using sendmail (via Pony gem). Easy to deploy with Passenger,
or any other app container.

## Setup

1. Save a copy of __config.sample.yml__ as __config.yml__.
2. Edit config.yml wih the settings that make sense for you.

Run app.rb using bundler:

    bundle exec ruby ./app.rb

Or rackup:

    bundle exec rackup


### Multiple Recipients

The "recipients" option in config.yml is passed as-is to sendmail
(via Pony), so just separate multiple recipients with commas.

## Testing

Testing is easy with curl. Replace 'https://csp-reports.mysite.com/'
(the last argument) with your URL:

    curl -H 'Content-Type: application/csp-report;charset=utf-8' --data '{"csp-report":{"document-uri":"https://example.com/foo/bar","referrer":"https://www.google.com/","violated-directive":"default-src self","original-policy":"default-src self; report-uri /csp-hotline.php","blocked-uri":"http://evilhackerscripts.com"}}' 'https://csp-reports.mysite.com/'
