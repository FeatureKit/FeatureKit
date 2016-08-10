![](https://raw.githubusercontent.com/FeatureKit/FeatureKit/development/header.png)

[![Build status](https://badge.buildkite.com/f5cd9b123bdef230157b46e02508fc2518c0d908.svg)](https://buildkite.com/blindingskies/featurekit)

_FeatureKit_ is a small Swift framework which is to enable application developers to use [feature flags](https://en.wikipedia.org/wiki/Feature_toggle).

Briefly, feature flags enable continuous deployment of product features. During the development of new product features, the changes are “switched off” behind a feature flag. When the product feature is ready, the flag can be switched to enable the new feature. This could all be done after the application has shipped to customers.

This allows for multiple streams of development to occur concurrently, which is often necessary for large products or teams.

FeatureKit provides a software framework to support the basics on the client side. It will allow client side application developers to:

1. Define the feature identifiers
2. Instantiate a “service” layer which can be queried for features
3. Toggling of features
4. Loading of features via a URL, with an appropriate mapper