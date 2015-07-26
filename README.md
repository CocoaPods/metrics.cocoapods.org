metrics.cocoapods.org
=====================

[![Build Status](http://img.shields.io/travis/CocoaPods/metrics.cocoapods.org/master.svg?style=flat)](https://travis-ci.org/CocoaPods/metrics.cocoapods.org)
[![Apiary Documentation](https://img.shields.io/badge/Apiary-Documented-blue.svg)](http://docs.cocoapodsmetrics.apiary.io/)

Metrics calculations & Metrics API for CocoaPods.

## Installation

1. Migrate the databases for the various environments via Humus.

### Run tests

1. Seed the test DB in trunk (while Humus does not yet seed): `RACK_ENV=test bundle exec rake db:seed`

2. You can now run the tests using:

		$ bundle exec rake spec

