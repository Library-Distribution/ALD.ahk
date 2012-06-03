class PackageGenerator
{
	_doc := ComObjCreate("MSXML.DOMDocument")

	__New(defFile)
	{
		this._doc.setProperty("SelectionNamespaces", "xmlns:ald='" . ALD.NamespaceURI . "'")
		, this._doc.load(defFile)
	}

	Package(outFile)
	{
		for each, file in this._getFileList()
		{
			Zip_Archive(file, outFile)
		}
	}

	_getFileList()
	{
		fileList := []

		for each, node in this._doc.selectNodes("/*/ald:files/ald:src/ald:file")
		{
			fileList.Insert(node.getAttribute("ald:path"))
		}
		for each, node in this._doc.selectNodes("/*/ald:files/ald:doc/ald:file")
		{
			fileList.Insert(node.getAttribute("ald:path"))
		}
		if (logo := this._doc.documentElement.getAttribute("ald:logo-image"))
		{
			fileList.Insert(logo)
		}

		return fileList
	}
}