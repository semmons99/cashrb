cashrb v1.2.0
=============
 - allow creation using decimal values instead of cents if you'd rather

cashrb v1.1.1
=============
 - fix bug in #to_s/#to_f regarding negative amounts

cashrb v1.1.0
=============
 - use "include Comparable" instead of custom functions
 - #== no longer throws an IncompatibleCurrency exception
 - cleanup tests that we auto passing
 - if currency implements :cents_in_whole, use it

cashrb v1.0.3
=============
 - change to "require 'cashrb'" to avoid clash with 'cash' gem

cashrb v1.0.2
=============
 - fix error with scope for ruby 1.8.7
 - require 'rubygems' in tests

cashrb v1.0.1
=============
 - revert to hashrocket syntax for compatibility with rubies prior to 1.9.2

cashrb v1.0.0
=============
 - first release!
