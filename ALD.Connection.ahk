class Connection
{
	static hModule := DllCall("LoadLibrary", "str", "WinInet")

	URL := ""

	__New(URL)
	{
		this.URL := URL
	}

	getUserList(start = 0, count = "all")
	{
		local RequestURL := this.URL . "/users/list.php?start=" . start . "&count=" . count
			, NamespaceURI := "ald://api/users/list/schema/2012"

		doc := this._GETRequest(RequestURL, NamespaceURI)
		, array := []
		, list := doc.selectNodes("/ald:user-list/ald:user")

		Loop % list.length
		{
			array.Insert(list.item(A_Index - 1).getAttribute("ald:name"))
		}

		return array
	}

	getUser(name)
	{
		local RequestURL := this.URL . "/users/describe.php?name=" . name
			, NamespaceURI := "ald://api/users/describe/schema/2012"

		doc := this._GETRequest(RequestURL, NamespaceURI)
		, user := {}

		user["name"] := doc.documentElement.getAttribute("ald:name")
		, user["mail"] := doc.documentElement.getAttribute("ald:mail")
		, user["joined"] := doc.documentElement.getAttribute("ald:joined")
		, user["privileges"] := doc.documentElement.getAttribute("ald:privileges")

		return user
	}

	getItemById(id)
	{
		local RequestURL := this.URL "/items/describe.php?id=" . id
			, NamespaceURI := "ald://api/items/describe/schema/2012"

		return this._parseItemXML(this._GETRequest(RequestURL, NamespaceURI))
	}

	getItem(name, version)
	{
		local RequestURL := this.URL "/items/describe.php?name=" . name . "&version=" . version
			, NamespaceURI := "ald://api/items/describe/schema/2012"

		return this._parseItemXML(this._GETRequest(RequestURL, NamespaceURI))
	}

	_parseItemXML(doc)
	{
		item := {}

		; ...

		return item
	}

	getItemList(start = 0, count = "all", type = "", user = "", name = "")
	{
		local RequestURL := this.URL . "/items/list.php?start=" . start . "&count=" . count . (type ? "&type=" . type : "") . (user ? "&user=" . user : "") . (name ? "&name=" . name : "")
			, NamespaceURI := "ald://api/items/list/schema/2012"

		doc := this._GETRequest(RequestURL, NamespaceURI)
		, array := []
		, list := doc.selectNodes("/ald:item-list/ald:item")

		Loop % list.length
		{
			item := list.item(A_Index - 1)
			, array.Insert( { "name" : item.getAttribute("ald:name"), "id" : item.getAttribute("ald:id"), "version" : item.getAttribute("ald:version") } )
		}

		return array
	}

	_GETRequest(URL, NamespaceURI)
	{
		local headers := "Accept: text/xml"
			, response := ""

		if (HttpRequest(URL, response, headers, "Method: GET") > 0)
		{
			if (RegExMatch(headers, "`am)^HTTP/1.1\s+(\d{3})\s+(.*)$", match))
			{
				code := match1, msg := match2

				if (code < 200 || code >= 300)
				{
					throw Exception("Failure code: " . code . " - " . msg)
				}

				doc := ComObjCreate("MSXML.DOMDocument")
				, doc.setProperty("SelectionNamespaces", "xmlns:ald='" NamespaceURI . "'")
				, doc.LoadXML(response)

				return doc
			}
			throw Exception("Status code missing")
		}
		throw Exception("No response received")
	}
}