ItemsCompendium
===============

This is a flexible command-line tool for searching through large numbers of items with arbitrary fields and data.
At present, the application operates over data in a simple intermediary CSV format; sqlite support is in the pipeline.

```
Usage: ItemsCompendium [options]
    -d, --dirname=DIR                Specify the database directory
    -c, --[no-]curses                Don't use Curses for I/O
```

If your platform doesn't support curses for whatever reason it can be disabled by passing --no-curses as an argument. Note though, that doing so will also disable tab-completion.


Available commands:
```
  Quit | Close | Exit
  Search
  Refine
  Dump
  Types
  Fields
  Select
  Save
  SaveSelected
  Clear
  ShowExtended
  Count
  History | !
  Choose
  Enumerate
  CreateSet
  LoadSet
  AddtoSet
  ListSets
  TrashSet
  Help
```

Installation
============
No special steps needed, just download or clone the repo on any system with ruby installed.


Data Format
===========
The program accepts any number of CSV files ending in .db and will parse all such files in the database directory (provided as an argument).
Files are interpreted as follows:

```
IdField,Field1,Field2,...,FieldN
item1_idfield,item1_field1,item1_field2,...,item1_fieldN
item2_idfield,item2_field1a,item2_field2a,...,item2_fieldNa
item2_idfield,item2_field1b,item2_field2b,...,item2_fieldNb
...
```

Any entries sharing the same value for the Id Field are considered to be part of the same Item. Values from the separate entries are gathered into a list for each field.
Entries should not contain any spaces; underscores should be used instead. They will be replaced with spaces when data is printed to the screen.
