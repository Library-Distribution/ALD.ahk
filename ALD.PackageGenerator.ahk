class PackageGenerator
{
	_doc := ComObjCreate("MSXML.DOMDocument")

	Package(definitionFile)
	{
		_doc.load(definitionFile)
		; ...
	}
}