/*
Zip library

Credits to shajul for his excelllent work (original code available at <http://www.autohotkey.com/community/viewtopic.php?f=13&t=65401>)

Modifications:
	* function renaming
	* removal of tooltips
	* removal of unnecessary COM Object in Extract()
*/

Zip_Archive(FilesToZip,sZip)
{
	If Not FileExist(sZip)
		Zip_CreateFile(sZip)
	psh := ComObjCreate( "Shell.Application" )
	pzip := psh.Namespace( sZip )
	if InStr(FileExist(FilesToZip), "D")
		FilesToZip .= SubStr(FilesToZip,0)="\" ? "*.*" : "\*.*"
	loop,%FilesToZip%,1
	{
		zipped++
		pzip.CopyHere( A_LoopFileLongPath, 4|16 )
		Loop
		{
			done := pzip.items().count
			if done = %zipped%
				break
		}
		done := -1
	}
}

Zip_CreateFile(sZip)
{
	Header1 := "PK" . Chr(5) . Chr(6)
	VarSetCapacity(Header2, 18, 0)
	file := FileOpen(sZip,"w")
	file.Write(Header1)
	file.RawWrite(Header2,18)
	file.close()
}

Zip_Extract(sZip, sUnz)
{
	If (!InStr(FileExist(sUnz), "D"))
		FileCreateDir %sUnz%
	psh  := ComObjCreate("Shell.Application")
	zippedItems := psh.Namespace( sZip ).items().count
	psh.Namespace( sUnz ).CopyHere( psh.Namespace( sZip ).items, 4|16 )
	Loop
	{
		unzippedItems := psh.Namespace( sUnz ).items().count
		IfEqual,zippedItems,%unzippedItems%
			break
	}
}