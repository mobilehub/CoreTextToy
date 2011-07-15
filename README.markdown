# CoreTextToy

This is a small test project for iOS CoreText related experimentation.

### CMarkupValueTransformer

A value transformer capable of converting _simple_ HTML into a NSAttributedString.
At the moment it only supports "b" and "i" tags (in any valid, nested combinations) but that is quite easy to expand. Each tag combination can have their set of attributes.

#### TODO

* Support HTML entities
* Support tags with attributes. This is important for the "a" tag.
* Support _basic_ CSS styling (changing colour of text perhaps)
* Support links
* Support tags like "p" & "br" that don't style the text but do control flow.

### UIFont_CoreTextExtensions

Extension on UIFont to get a CTFont and to get bold/italic, etc versions of the font. Scans the font name to work out the attributes of a particular font. This code is crude and effective - but needs to be tested on _all_ iOS font names (esp. the weirder ones).

### CCoreTextLabel

Beginning of a UILabel workalike that uses CoreTest to render NSAttributedString objects.
