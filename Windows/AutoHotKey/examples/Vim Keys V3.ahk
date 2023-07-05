SendMode Input
RegRead, OutputVar, HKEY_CLASSES_ROOT, http\shell\open\command
StringReplace, OutputVar, OutputVar,"
SplitPath, OutputVar,,OutDir,,OutNameNoExt, OutDrive
browser=%OutDir%\%OutNameNoExt%.exe

Suspend On

;===Navigate
h::Left
j::Down
k::Up
l::Right
p::PgUp
`;::PgDn
a::Home
e::End

;===Run, First letter of service, blog, homework, snip, autohotkey, dropbox
r & b:: Run D:\Users\Corm\Dropbox\Notebooks\Notes\Personal Notes\blog posts\(1) March
r & h::Run D:\Users\Corm\Dropbox\Notebooks\Homework
r & s:: Run D:\Users\Corm\Documents\Unsorted\SnippingTool.exe
r & a::Reload
r & d::Run D:\Users\Corm\Dropbox\Backup Data

;===Skip words
*w::
  SetKeyDelay -1
  Send {Blind}{Control DownTemp}{Right DownTemp}
return

*w up::
 SetKeyDelay -1
  Send {Blind}{Right up}{Control Up}
return

*b::
  SetKeyDelay -1
  Send {Blind}{Control DownTemp}{Left DownTemp}
return

*b up::
  SetKeyDelay -1
  Send {Blind}{Left up}{Control Up}
return

;===Skip down/up

Space::
	SetKeyDelay -1
	Loop, 16
		Send {Down}
	return

+space::
	SetKeyDelay -1
	Loop, 16
		Send {Up}
	return

;===Google!

g::
{
   BlockInput, on
   prevClipboard = %clipboard%
   clipboard =
   Send, ^c
   BlockInput, off
   ClipWait, 2
   if ErrorLevel = 0
   {
      searchQuery=%clipboard%
      GoSub, GoogleSearch
   }
   clipboard = %prevClipboard%
   return
}

GoogleSearch:
   StringReplace, searchQuery, searchQuery, `r`n, %A_Space%, All
   Loop
   {
      noExtraSpaces=1
      StringLeft, leftMost, searchQuery, 1
      IfInString, leftMost, %A_Space%
      {
         StringTrimLeft, searchQuery, searchQuery, 1
         noExtraSpaces=0
      }
      StringRight, rightMost, searchQuery, 1
      IfInString, rightMost, %A_Space%
      {
         StringTrimRight, searchQuery, searchQuery, 1
         noExtraSpaces=0
      }
      If (noExtraSpaces=1)
         break
   }
   StringReplace, searchQuery, searchQuery, \, `%5C, All
   StringReplace, searchQuery, searchQuery, %A_Space%, +, All
   StringReplace, searchQuery, searchQuery, `%, `%25, All
   IfInString, searchQuery, .
   {
      IfInString, searchQuery, +
         Run, %browser% http://www.google.com/search?hl=en&q=%searchQuery%
      else
         Run, %browser% %searchQuery%
   }
   else
      Run, %browser% http://www.google.com/search?hl=en&q=%searchQuery%
return

+Capslock::
CapsLock::Suspend Off
CapsLock Up::Suspend On