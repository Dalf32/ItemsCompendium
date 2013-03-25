ItemsCompendium
===============

This is a flexible command-line tool for easily searching items with arbitrary fields.
At present, the application operates over data in a simple intermediary CSV format, where the fields to be used are the
first row in the file and every subsequent row represents a new 'record'. Additionally, you may have several CSV files
all loaded in by the ItemsCompendium which will be identified as separate 'Types', which allows you to partition your
data so that you may search different Types individually if you wish. Fields may be marked as 'hidden' by prepending
them with "-", which makes them initially hidden during searches; this is useful for fields with an unwieldy amount of content.


I personally use this to quickly search through Magic Items from the D&D 4.0 books.
This amounts to just over 1800 Items, the details of which I parsed from the D&D Insider Character Builder's XML data
file. Because of this, I unfortunately can't include any of these data files, but I will be adding some example files
for reference, should anyone be interested in actually using this.

There is some code in here that I feel is flexible enough to be ripped out of here and used in a completely different
application (CommandProcessor for instance), so hopefully there's something useful to be found here.
