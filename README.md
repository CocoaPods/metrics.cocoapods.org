# metrics.cocoapods.org
[![Apiary Documentation](https://img.shields.io/badge/Apiary-Documented-blue.svg)](http://docs.cocoapodsmetrics.apiary.io/)

Metrics calculations & Metrics API for CocoaPods.

## Installation
1. Migrate the databases for the various environments via Humus.
2. Create a `.env` file in the root of the repo based on `test.env`.

### Run tests
- Seed the test DB in trunk (while Humus does not yet seed): `RACK_ENV=test bundle exec rake db:seed`
- You can now run the tests using:

  ```
   $ bundle exec rake spec
  ```

## Running a single update
You can use the rake task `rake update[Pod name]` to run through updating just one Pod.
