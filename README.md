metrics.cocoapods.org
=====================

Metrics calculations & Metrics API for CocoaPods.

## Installation

1. Install [trunk][1] locally, see its README.

2. Migrate the databases for the various environments:

        $ rake db:migrate RACK_ENV=test
        $ rake db:migrate RACK_ENV=development

3. You can now run the tests using:

		$ rake spec


[1]: https://github.com/CocoaPods/trunk.cocoapods.org