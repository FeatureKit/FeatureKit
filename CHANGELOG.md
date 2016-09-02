# 0.6

This is a complete re-imagining of this project using Swift. The scope has been cut back to only consider whether a feature is available. Framework consumers should define their own feature definitions, and then a provide suitable JSON file to load the features in the application.

The JSON is loaded from a URL, which can be local or remote, and it is mapped into strong types using the identifiers defined in the application.

Features can also be persisted locally, with built in support for `NSUserDefaults`, buy any storage type (i.e. a database) can be supported.