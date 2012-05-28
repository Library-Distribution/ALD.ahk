/*
Source: http://www.autohotkey.com/community/viewtopic.php?p=55554#p55554 by Laszlo
Thanks a lot!

Modifications:
	* changed function names
	* added explicit concatenation in some places
	* made Chars variables local
*/
Base64_Encode(string) {
   Loop Parse, string
   {
      m := Mod(A_Index,3)
      IfEqual      m,1, SetEnv buffer, % Asc(A_LoopField) << 16
      Else IfEqual m,2, EnvAdd buffer, % Asc(A_LoopField) << 8
      Else {
         buffer += Asc(A_LoopField)
         out := out . Base64_Code(buffer>>18) . Base64_Code(buffer>>12) . Base64_Code(buffer>>6) . Base64_Code(buffer)
      }
   }
   IfEqual m,0, Return out
   IfEqual m,1, Return out . Base64_Code(buffer>>18) . Base64_Code(buffer>>12) . "=="
   Return out . Base64_Code(buffer>>18) . Base64_Code(buffer>>12) . Base64_Code(buffer>>6) . "="
}

Base64_Decode(code) {
   StringReplace code, code, =,,All
   Loop Parse, code
   {
      m := A_Index & 3 ; mod 4
      IfEqual m,0, {
         buffer += Base64__DeCode(A_LoopField)
         out := out . Chr(buffer>>16) . Chr(255 & buffer>>8) . Chr(255 & buffer)
      }
      Else IfEqual m,1, SetEnv buffer, % Base64__DeCode(A_LoopField) << 18
      Else buffer += Base64__DeCode(A_LoopField) << 24-6*m
   }
   IfEqual m,0, Return out
   IfEqual m,2, Return out Chr(buffer>>16)
   Return out . Chr(buffer>>16) . Chr(255 & buffer>>8)
}

Base64_Code(i) {   ; <== Chars[i & 63], 0-base index
   local Chars := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
   StringMid i, Chars, (i&63)+1, 1
   Return i
}

Base64__DeCode(c) { ; c = a char in Chars ==> position [0,63]
   local Chars := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
   Return InStr(Chars,c,1) - 1
}