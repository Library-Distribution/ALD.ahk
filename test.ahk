; <AutoHotkey L>
#include ALD.ahk

conn := new ALD.Connection("http://maulesel.ahk4.net/api")
item_list := conn.getItemList()
for each, item in item_list
{
	items .= "  - {" . item.id . "} " . item.name . " ( " . item.version . " )`n"
}
MsgBox Uploaded items:`n`n%items%

user_list := conn.getUserList()
for each, user in user_list
{
	users .= "  - " . user . "`n"
}
MsgBox Registered users:`n`n%users%