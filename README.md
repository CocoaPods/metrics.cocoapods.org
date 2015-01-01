metrics.cocoapods.org
=====================

Metrics calculations & Metrics API for CocoaPods.

## Installation

1. Migrate the databases for the various environments via Humus.

### Run tests

1. Seed the test DB in trunk (while Humus does not yet seed): `RACK_ENV=test bundle exec rake db:seed`

2. You can now run the tests using:

		$ bundle exec rake spec


[1]: https://github.com/CocoaPods/trunk.cocoapods.org