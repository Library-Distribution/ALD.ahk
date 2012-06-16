Base64_Encode(ByRef Data)
{
	static CharSet := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	Length := StrLen(Data) << !!A_IsUnicode ;make sure the length is the number of bytes, not the number of characters
	VarSetCapacity(Output,Ceil(Length / 3) << 2), Index := 0, pBin := &Data ;set the size of the Base64 output, initialize variables
	Loop, % Length // 3 ;process 3 bytes per iteration
	{
		;convert the 3 bytes to 4 Base64 characters
		Value := (*(pBin ++) << 16) | (*(pBin ++) << 8) | *(pBin ++)
		Output .= SubStr(CharSet,((Value >> 18) & 63) + 1,1)
			. SubStr(CharSet,((Value >> 12) & 63) + 1,1)
			. SubStr(CharSet,((Value >> 6) & 63) + 1,1)
			. SubStr(CharSet,(Value & 63) + 1,1)
	}
	Length := Mod(Length,3) ;determine the number of characters left over
	If Length = 0 ;no characters remaining, conversion complete
		Return, Output
	Value := (*pBin) << 10
	If Length = 1
		Return, Output ;one character remaining
			. SubStr(CharSet,((Value >> 12) & 63) + 1,1)
			. SubStr(CharSet,((Value >> 6) & 63) + 1,1) . "=="
	Value |= *(++ pBin) << 2 ;insert the third character
	Return, Output ;two characters remaining
		. SubStr(CharSet,((Value >> 12) & 63) + 1,1)
		. SubStr(CharSet,((Value >> 6) & 63) + 1,1)
		. SubStr(CharSet,(Value & 63) + 1,1) . "="
}

Base64_Decode(Code)
{
	static CharSet := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	Value := (SubStr(Code,0) = "=") + (SubStr(Code,-1,1) = "=")
	If Value > 0 ;remove any padding in the input
		Code := SubStr(Code,1,0 - Value)
	Length := StrLen(Code)
	BufferSize := Ceil((Length / 4) * 3), VarSetCapacity(Data,BufferSize) ;calculate the correct buffer size
	Index := 1, BinPos := 0
	Loop, % Length >> 2 ;process 4 characters per iteration
	{
		;decode the characters and store them in the output buffer
		Value := ((InStr(CharSet,SubStr(Code,Index ++,1),1) - 1) << 18)
			| ((InStr(CharSet,SubStr(Code,Index ++,1),1) - 1) << 12)
			| ((InStr(CharSet,SubStr(Code,Index ++,1),1) - 1) << 6)
			| (InStr(CharSet,SubStr(Code,Index ++,1),1) - 1)
		NumPut((Value >> 16)
			| (((Value >> 8) & 255) << 8)
			| ((Value & 255) << 16),Data,BinPos,"UInt")
		BinPos += 3
	}
	Length &= 3 ;determine the number of characters remaining
	If Length > 0 ;characters remain
	{
		;decode the first of the remaining characters and store it in the output buffer
		Value := ((InStr(CharSet,SubStr(Code,Index,1),1) - 1) << 18)
			| ((InStr(CharSet,SubStr(Code,Index + 1,1),1) - 1) << 12)
		NumPut(Value >> 16,Data,BinPos,"UChar")

		;another character remains
		If Length = 3
		{
			;decode the character and store it in the output buffer
			Value |= (InStr(CharSet,SubStr(Code,Index + 2,1),1) - 1) << 6
			NumPut((Value >> 8) & 255,Data,BinPos + 1,"UChar")
		}
	}
	Return, Data
}