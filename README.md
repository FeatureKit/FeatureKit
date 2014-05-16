DNTFeatures
===========

DNTFeatures is a small collection of classes which enable you, an iOS app developer, to use feature flags in your app.

During development using Features flags enable you to protect code which hasn't been completed or tested yet. This code is safe to merge into your main development branch, meaning that large features, or development efforts can be done on branches which don't exist for a long time. This minimises risk, aides collaboration with other developers, help QA perform comparisons manually, and with a little bit of server work can even help you ease release of a new feature once your app goes live.

I recommend you take a look at the demo project first to get an idea of how Features are created.

Tap twice with two fingers to bring up the Features controller where flags can be switched on or off.


Warning
=======
DNTFeatures is not 1.0 yet, and it is not safe to use in production code yet. However, this is actually the third time I've written this component, and the 2nd version is live in a app which handles 10M launches per day.

Installation
============
At the moment, the .podspec for DNTFeatures is not public, so for now, the easiest way to use this in your application is to drag the project file into your project. Or if using CocoaPods

    pod 'DNTFeatures', :path => 'where/you/downloaded/it/then/moved/'


Requirements
============

This work depends on YapDatabase, which is a key-value store built ontop of sqlite. It's great, and perhaps this project will introduce it to you, and you'll think twice before using Core Data in your next project.

DNTFeatures will set up it's own database if necessary, alternatively you can inject your own Database if you're already using YapDatabase, and DNTFeatures will work in its own space happily inside your database.

Things that are missing
=======================

1. The code is a little messy at the moment, don't judge me too harshly.
2. Test coverage is very weak at the moment - see the Warning notes above.
3. The Debug Settings are missing a basic text entry type.
