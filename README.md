# Bauditor

Run [bundler-audit](https://github.com/rubysec/bundler-audit) on multiple repositories at once.

If you manage many ruby applications it can be a hassle to keep them all up-to-date and audited. This gem can aid in running bundle-audit on many repositories at once. It will do the following:

* create a directory in `/tmp/bauditor` OR in the --repo_path
* fetch a list of repos with `git clone repo --branch master --single-branch`
* If a `Gemfile.lock` is not present it will run `bundle lock` in an attempt to generate a lockfile.
* run `bundle-audit` on the repositories `Gemfile.lock` and print the output
* Print a summary report
* If the --no-persist option is passed it will `rm -rf #{repo_path}.`

By default it will persist the repositories after each run. This way it only has to go a `git pull origin master` if the repository has already been cloned.

## Installation

```
$ gem install bauditor
```

## Usage

```
$ bauditor help audit

Usage:
  bauditor audit

Options:
      [--repo-path=REPO_PATH]      # Path to directory where fetched repositories will be stored
      [--persist], [--no-persist]  # Persist repositories, or not.
                                   # Default: true
  r, [--repos=one two three]       # Space seperate list of repositories
  c, [--config=CONFIG]             # Path to file containing repositories one per line.

run bundle-audit on multiple repositories
```

Repositories must be in a format that can passed to git clone. Currently this only works on the master branch.

`audit` is the only command and is the default so `bauditor` can be invoked without a command.
### Example

```
$ cat config

git@github.com:leklund/chopped_ingredients.git
git@github.com:leklund/bitbucket-irc-notification.git

$ bauditor -c=config -r=git@github.com:wistia/nsq-ruby.git
  OR
$ bauditor audit -c=config -r=git@github.com:wistia/nsq-ruby.git

[BAUDITOR] Updating the bundle-audit database
Updating ruby-advisory-db ...
From https://github.com/rubysec/ruby-advisory-db
 * branch            master     -> FETCH_HEAD
Already up-to-date.
Updated ruby-advisory-db
ruby-advisory-db: 273 advisories
---------------------------------------------------
[BAUDITOR] fetching and auditing nsq-ruby
---------------------------------------------------
Insecure Source URI found: http://rubygems.org/
Vulnerabilities found!
---------------------------------------------------
[BAUDITOR] fetching and auditing chopped_ingredients
---------------------------------------------------
No vulnerabilities found
---------------------------------------------------
[BAUDITOR] fetching and auditing bitbucket-irc-notification
---------------------------------------------------
Name: rack
Version: 1.5.2
Advisory: CVE-2015-3225
Criticality: Unknown
URL: https://groups.google.com/forum/#!topic/ruby-security-ann/gcUbICUmKMc
Title: Potential Denial of Service Vulnerability in Rack
Solution: upgrade to >= 1.6.2, ~> 1.5.4, ~> 1.4.6

Name: rest-client
Version: 1.6.7
Advisory: CVE-2015-1820
Criticality: Unknown
URL: https://github.com/rest-client/rest-client/issues/369
Title: rubygem-rest-client: session fixation vulnerability via Set-Cookie headers in 30x redirection responses
Solution: upgrade to >= 1.8.0

Name: rest-client
Version: 1.6.7
Advisory: CVE-2015-3448
Criticality: Unknown
URL: http://www.osvdb.org/show/osvdb/117461
Title: Rest-Client Gem for Ruby logs password information in plaintext
Solution: upgrade to >= 1.7.3

Vulnerabilities found!
---------------------------------------------------
[BAUDITOR] summary report:
____________________________________________
| Repo                       | Vulnerable? |
--------------------------------------------
| nsq-ruby                   |    YES      |
| chopped_ingredients        |    No       |
| bitbucket-irc-notification |    YES      |
--------------------------------------------

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/leklund/bauditor. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

Copyright (c) 2017 Lukas Eklund

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
