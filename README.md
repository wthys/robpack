RobPack
=======

ComputerCraft libraries and utilities


Libraries
---------

### Bencode

The bencode encoding use by BitTorrent with the small difference of the
integer being changed to a number (possibly floating point, impossible in the
BitTorrent bencoding specification). Can be used to pass complicated objects
over RedNet or to save an object to file. The objects must consist of lists,
dicts, strings and/or numbers.

### Base64

Base64 encoding using _._ and _/_ as char 62 and 64. Padding can be customised
but defaults to _=_. Ideal when sending binary data over RedNet or using the
HTTP API.
