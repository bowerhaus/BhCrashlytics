BhCrashlytics
=============

A quick demonstration of Crashlytics crash logging for Gideros SDK. 

Most crash logging systems record only the unlying processor stack trace when a crash/exception occurs. For Lua errors, where the app will probably just exit normally without throwing an exception, this is of little use. Here we demonstrate the BhCrashlytics plugin which works with the http://www.crashlytics.com logging service to log not only raw crashes but also ones caused by a Lua error. In the case of the latter, the Lua stack trace is logged along with the other crash information.

See http://bowerhaus.eu/blog/files/luacrashlogging.html for installation instructions.

Folder Structure
----------------

This module is part of the general Bowerhaus library for Gideros mobile.

###/MyDocs
Place your own projects in folder below here

###/MyDocs/Library
Folder for library modules

###/MyDocs/Library/Bowerhaus
Folder containing sub-folders for all Bowerhaus libraries

###/MyDocs/Library/Bowerhaus/BhCrashlytics
Folder for THIS FILE