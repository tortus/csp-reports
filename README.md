# Content Security Policy (CSP) Violation Report Handler

Tiny Sinatra application to parse CSP violation reports,
format them nicely, and forward them on to an email address.

## Setup

Set the following environment variables, or place them in your
.env file in development mode:

    CSP_REPORT_SENDER="csp-reports@mysite.com"
    CSP_REPORT_RECIPIENTS="csp-violations@mysite.com"

Run app.rb using bundler:

    bundle exec ruby ./app.rb
