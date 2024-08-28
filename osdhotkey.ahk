FileCreateDir, icons
FileInstall, icons\colors.bmp, icons\colors.bmp, 0
FileInstall, icons\disable.ico, icons\disable.ico, 0
FileInstall, icons\enable.ico, icons\enable.ico, 0
/*
ToDo:
	- font selector
	- remove + from normal keys, i.e. a+b+c+d will be shown as abcd
	- transparency
	- key like CTRL or ALT will be more important than others, so if you type "r+ALT+g" it will display "ALT+g"
	- supra and mousebutton displays in a dedicated area, and the keyboard keys in another
	- log
*/

#Persistent
OnMessage(0x204, "winmove")
FileDelete, log.txt

font=Arial
style=bold
color=black

; Define image paths
MouseLeft := "C:\Users\Danish Nazir Arain\Downloads\Mouse Button\New\1x\Left_CLick.png"
MouseRight := "C:\Users\Danish Nazir Arain\Downloads\Mouse Button\New\1x\Right_CLick.png"
MouseMiddle := "C:\Users\Danish Nazir Arain\Downloads\Mouse Button\New\1x\Middle_CLick.png"
Scroll := "C:\Users\Danish Nazir Arain\Downloads\Mouse Button\New\1x\Scroll.png"

idleMouseImage := "C:\Users\Danish Nazir Arain\Downloads\Mouse Button\New\1x\Mouse_Idle.png"

global currentMouseImage := idleMouseImage

IniRead, class, colors.ini, class, c

IfNotExist, icons
	FileCreateDir, icons
FileInstall, enable.ico, icons\enable.ico
FileInstall, disable.ico, icons\disable.ico

Gui, +Owner  ; +Owner prevents a taskbar button from appearing.
IniRead, col_b, colors.ini, colors, background, FFFF00
Gui, Color, %col_b%
IniRead, col_t, colors.ini, colors, text, 0000FF
IniRead, font_t, colors.ini, colors, font, Arial
IniRead, style_t, colors.ini, colors, style, bold s20
gui, font,c%col_t% %style_t%, %font_t%

;Gui, Color, EEAA99 150
Gui, Add, Text, BackgroundTrans vMyText x5 y5 w290
Gui, Add, Picture, ,mouseImage  ; Image control


Gui, -Caption
Gui, +AlwaysOnTop
IniRead, x, colors.ini, positions, x, 200 
IniRead, y, colors.ini, positions, y, 200
IniRead, w, colors.ini, positions, w, 300
IniRead, h, colors.ini, positions, h, 50

IniRead, unshowTime, colors.ini, times, timeToHide, 2000


;Gui, show, NA x%x% y%y% w%w% h%h%, OSD hotkey
Gui, +Resize



Menu,tray,Icon,icons\enable.ico,,1
Menu, Tray, NoStandard
Menu, Tray, add, Disabled, enable_disable
Menu, Tray, add, Options, showOptionsDialog
Menu, Tray, add, Class control, class_control
Menu, Tray, add, Set class for class control, sel_class
Menu,  Tray, add, About, about
Menu, Tray, add, Exit, GuiClose

SetTimer, mouseHolded, 1000

Gui, 2:add, ListView, xm h20 w20 ReadOnly 0x4000 +BackgRound%col_b% vcol1
Gui, 2:add, edit, x+5 vbackground_color, %col_b%
Gui, 2:add, button, x+5 gselect_background_color, ...
Gui, 2:add, ListView, xm h20 w20 ReadOnly 0x4000 +BackgRound%col_t% vcol2
Gui, 2:add, edit, x+5 vtext_color, %col_t%
Gui, 2:add, button, x+5 gselect_text_color, ...
Gui, 2:add, button, xm h20 w100 gselect_text_font, Change text font
Gui, 2:add, Text, xm, Transparency level


;IniRead, transparency_level, colors.ini, positions, transparency_level
Gui, 2:add, slider, xm Range1-255  vtransparency_level gtransparency_level, 255
OnExit, ExitSub
#Include ColorPicker.ahk
#Include FontPicker.ahk
return

																			;FUNCTIONS FOR WINDOW MOVING

winmove()
{
	getwininfo()
	SetTimer, Muovi , 20
	return
}

Muovi:
	xb1:=GetKeyState("LButton","P")
	;if up
	if(xb1="0")
	{
		CoordMode,MOUSE,SCREEN
		MOUSEGetPos,x,y
		in_x:=wx+x-posx
		in_y:=wy+y-posy
		WinMove, ahk_class %class%, , in_x, in_y
		;Tooltip,Current Position`nx:%in_x%`ny:%in_y%
	}
	;it's still down
	Else
		{
			SetTimer,Muovi,off
			;Tooltip,
			Return
		}
Return

getwininfo()
	{
		global
		CoordMode,MOUSE,SCREEN
		MOUSEGetPos,posx,posy,id
		WinGetClass, class, ahk_id %id%
		WinGetPos , wx, wy, ww, wh,ahk_class %class%
		Return
	}

																			;SELECT BACKGROUND COLOR

select_background_color:
	color:=ColorPicker()
	if(color="")
		return
	GuiControl, 2:, background_color, %color%
	GuiControl, 2:+BackgRound%color%, col1
	Gui, 1:Color, %color%
	IniWrite, %color%, colors.ini, colors, background
return
select_text_font:
	if(font="")
		font = %font_t%
	if(style="")
		style= %style_t%
	ChooseFont(font,style,color2)
	gui, 1:font,c%color% %style%, %font%
	GuiControl, 1:Font, MyText
	IniWrite, %font%, colors.ini, colors, font
	IniWrite, %style%, colors.ini, colors, style
return
select_text_color:	
	color:=ColorPicker()
	if(color="")
		return
	GuiControl, , text_color, %color%
	GuiControl, 2:+BackgRound%color%, col2
	gui, 1:font,c%color% %style%, %font%
	GuiControl, 1:Font, MyText
	IniWrite, %color%, colors.ini, colors, text
return

																			;SAVE MOUSE POSTION

ExitSub:
	WinGetPos , x, y, w, h, OSD hotkey
	IniWrite, %x%, colors.ini, positions, x
	IniWrite, %y%, colors.ini, positions, y
	IniWrite, %w%, colors.ini, positions, w
	IniWrite, %h%, colors.ini, positions, h
	exitapp
return

																			;ENABLE AND DISABLE APP

enable_disable:
Suspend
Menu, Tray, ToggleCheck, Disabled
if(A_IsSuspended=1)
	{
		Menu,tray,Icon , icons\disable.ico,,1
		Gui, hide
	}
else
	{
		Menu,tray,Icon,icons\enable.ico,,1
		Gui, show
	}
return

																			;CLASS CONTROL AND SELECTION

class_control:
Menu, Tray, ToggleCheck, Class control
if(class_control="true")
	class_control=false
else
	class_control=true
return

sel_class:
	ToolTip,Click with left MOUSE Button on the program window
	SetTimer, RemoveToolTip, 3000
	KeyWait, LButton,D
	MOUSEGetPos,,,idn
	WinGetClass, class, ahk_id %idn%
	IniWrite, %class%, colors.ini, class, c
	msgbox, Class set successfully
return
RemoveToolTip:
	SetTimer, RemoveToolTip, off
	Tooltip,
return



																			;--------------MOUSE BUTTON PRESS FUNCTIONS--------------------


~LButton::
	osdText=MouseLeft
	updateOSD(osdText)

	mouseImage := "C:\Users\Danish Nazir Arain\Downloads\Mouse Button\New\1x\Left_Click.png"
	ChangeMouseImage(mouseImage)
return



~*LButton::
	IfInString, osdText, MouseLeft
		return
	osdText=%osdText%MouseLeft
	updateOSD(osdText)

	mouseImage := "C:\Users\Danish Nazir Arain\Downloads\Mouse Button\New\1x\Left_Click.png"
	ChangeMouseImage(mouseImage)
return

~RButton::
	osdText=MouseRight
	updateOSD(osdText)

	mouseImage := "C:\Users\Danish Nazir Arain\Downloads\Mouse Button\New\1x\Right_Click.png"
	ChangeMouseImage(mouseImage)
return

~*RButton::
	IfInString, osdText, MouseRight
		return
	osdText=%osdText%MouseRight
	updateOSD(osdText)
	
	mouseImage := "C:\Users\Danish Nazir Arain\Downloads\Mouse Button\New\1x\Right_Click.png"
	ChangeMouseImage(mouseImage)
	
return

~MButton::
	osdText=MouseMiddle
	updateOSD(osdText)
	
	mouseImage := "C:\Users\Danish Nazir Arain\Downloads\Mouse Button\New\1x\Middle_Click.png"
	ChangeMouseImage(mouseImage)
	return

~*MButton::
	IfInString, osdText, MouseMiddle
		return
	osdText=%osdText%MouseMiddle
	updateOSD(osdText)

	mouseImage := "C:\Users\Danish Nazir Arain\Downloads\Mouse Button\New\1x\Middle_Click.png"
	ChangeMouseImage(mouseImage)
return

~WheelUp::
	osdText=MouseWheelUp
	updateOSD(osdText)
	
	mouseImage := "C:\Users\Danish Nazir Arain\Downloads\Mouse Button\New\1x\Scroll.png"
	ChangeMouseImage(mouseImage)
return

~*WheelUp::
	IfInString, osdText, MouseWheelUp
		return
	osdText=%osdText%MouseWheelUp
	updateOSD(osdText)
	
	mouseImage := "C:\Users\Danish Nazir Arain\Downloads\Mouse Button\New\1x\Scroll.png"
	ChangeMouseImage(mouseImage)
return

~WheelDown::
	osdText=MouseWheelDown
	updateOSD(osdText)
	
	mouseImage := "C:\Users\Danish Nazir Arain\Downloads\Mouse Button\New\1x\Scroll.png"
	ChangeMouseImage(mouseImage)
return
~*WheelDown::
	IfInString, osdText, MouseWheelDown
		return
	osdText=%osdText%MouseWheelDown
	updateOSD(osdText)
	
	mouseImage := "C:\Users\Danish Nazir Arain\Downloads\Mouse Button\New\1x\Scroll.png"
	ChangeMouseImage(mouseImage)
return



																			;--------------MOUSE BUTTON PRESS FUNCTIONS ENDED------------------







																			;---------------------MOUSE HOLDED FUNCTIONS

mouseHolded:
	if(GetKeyState("LButton", P)=1 or GetKeyState("MButton", P)=1 or GetKeyState("RButton", P)=1)
		{

			if(!InStr(osdText,"(hold)"))
				osdText=%osdText%(hold)
			updateOSD(osdText)

			ShowMouseImage()
			;Gui, Show
		}
		else
		{
		GuiControl,, mouseImage, %currentMouseImage%
		Gui, Show
		}
	
return

ChangeMouseImage(mouseImage){
	
	currentMouseImage := mouseImage

}

ShowMouseImage(){
	
	GuiControl,, mouseImage, %currentMouseImage%
	;Gui, Show

}


ShowImage(imagePath) {
    global 
    if(GetKeyState("LButton", P)=1 or GetKeyState("MButton", P)=1 or GetKeyState("RButton", P)=1)
		{
    ; Update the GUI with the selected image and button text
    GuiControl,, mouseImage, %imagePath%
    ;SetTimer, HideImage, off
		;Gui, Show
		}
		else{
		; Update the GUI with the selected image and button text
    GuiControl,, mouseImage, %imagePath%
		Gui, Show
 		; Hide the image and text after 2.5 seconds
    ;SetTimer, HideImage, 2500
		}
    }


GuiSize:
	GuiControl, Move, MyText, % "w" A_GuiWidth - 10
	GuiControl, Move, MyText, % "h" A_GuiHeight - 10
return


updateOSD(string)
	{
		global
		
		SetTimer, hs, %unshowTime%
		
		if(osdText!="")
			FileAppend, %A_Hour%:%A_Min%:%A_Sec% - %osdText%`n  ,log.txt
		osdText=%string%
		if(class_control="true")
			{
				IfWinActive, ahk_class %class%
					GuiControl,, MyText, %osdText%
					GuiControl,, mouseImage, %currentMouseImage%
					;Gui, Show
					;HideImage() 

			}
		else
			GuiControl,, MyText, %osdText%
			;GuiControl,, mouseImage, %idleMouseImage%
			;Gui, Show
		SetTimer,unshowOSD,2500
		
		
		return
	}

	


hs:
	GuiControl,, MyText, %A_Space%
	;if(mouseImage != idleMouseImage){
	GuiControl,, mouseImage  ; Clear the image from the GUI
	;}
	
return


unshowOSD:
	SetTimer,unshowOSD,off
	Gui, Hide
return

hk_space:
	if(A_TimeSincePriorHotkey>1000)
		osdText=Space
	else
		osdText=%osdText%_
return

hk_label:
	StringTrimLeft, thisHotkey, A_ThisHotkey, 1 ; remove ~
	if(A_TimeSincePriorHotkey>1000)
			osdText=%thisHotkey%
	else
		osdText=%thisHotkey%
	updateOSD(osdText)
return
hk_label2:
	StringTrimLeft, thisHotkey, A_ThisHotkey, 2 ; remove ~*
	if(A_TimeSincePriorHotkey>1000)
		osdText=%thisHotkey%
	else
		osdText=%thisHotkey%
	updateOSD(osdText)
return
hks_label:
	StringTrimLeft, thisHotkey, A_ThisHotkey, 1 ; remove ~
	if(A_TimeSincePriorHotkey>1000)
			osdText=%thisHotkey%
	else
		osdText=%osdText%%thisHotkey%
	updateOSD(osdText)
return
hks_label2:
	StringTrimLeft, thisHotkey, A_ThisHotkey, 2 ; remove ~*
	if(A_TimeSincePriorHotkey>1000)
		osdText=%thisHotkey%
	else
		osdText=%osdText%%thisHotkey%
	updateOSD(osdText)
return

GuiClose:
ExitApp

about:
MsgBox,
(
Author: Salvatore Agostino Romeo
E-Mail: romeo84@gmail.com
Web: http://www.romeosa.com/osdhotkey
Description:
  This program show current pressed mouse and keyboard keys.
Version: 1.0
License: GPL
)
return

showOptionsDialog:
	Gui, 2:show, , Colors
return

transparency_level:
	WinSet, Transparent, %transparency_level%, OSD hotkey
return
