[General]
SyntaxVersion=2
BeginHotkey=20
BeginHotkeyMod=2
PauseHotkey=45
PauseHotkeyMod=8
StopHotkey=123
StopHotkeyMod=0
RunOnce=1
EnableWindow=
MacroID=860e7c08-0af1-47c3-977f-37dca84d5579
Description=A9script_rework
Enable=1
AutoRun=0
[Repeat]
Type=0
Number=1
[SetupUI]
Type=2
QUI=
[Relative]
SetupOCXFile=
[Comment]

[Script]
'version 0.1

Global tweakerPath
Global a9Col
Global mpLowestCarLevel

'=========================
'start of config

tweakerPath="C:\Users\dicecat\Desktop\BSTweaker5\BlueStacksTweaker5.exe"
a9Col = 3
mpMinCarLevel = 0
'bronze0 silver1 gold2 platinum3 legend4

'end of config
'=========================

Global mpMaxCarLevel

Global bsTweakerHandler
tweakerHandler=0
Global bsHandler
bsHandler=0

Global tweakerX
tweakerX=0
Global tweakerY
tweakerY=0

Global bsX
bsX=0
Global bsY
bsY=0

Global failRunCount
failRunCount=0

Global pressCount
pressCount = 0

'relative
Global a9IconX
a9IconX = 70+118*(a9Col-1)
Global a9IconY
a9IconY = 170

'absolute
Global carX
carX = 0
Global carY
carY = 0
Global prevCar
prevCar = 0

Global dailyMPReward
dailyMPReward = 0

Global ticketEmpty
ticketEmpty = 0

Global fuelEmpty
fuelEmpty = 0

Global nextEurotime
nextEurotime = 30

Global successRunCount
successRunCount=0

mainthread = BeginThread(mainLoop)
'guardian
While 1

	For 5
		Delay 60000
	Next
	'no success attempt in 5 minutes -> restart mainLoop
	If successRunCount < 1 Then 
		StopThread SEhuntthread
		StopThread mpthread
		StopThread eurothread
		StopThread mainthread
		mainthread = BeginThread(mainLoop)
	End If
	successRunCount=0

Wend


Sub mainLoop
	While 1

		SEhuntthread = BeginThread(SEhuntMain)
		While (ticketEmpty = 0 AND fuelEmpty = 0)
			Delay 1500
		Wend
		StopThread SEhuntthread
		ticketEmpty = 0
		fuelEmpty = 0
		
		timeStart=Plugin.Sys.GetTime()
		mpthread = BeginThread(dailyMP)
		For nextEurotime
			Delay 60000
		Next
		'in case still running a car, wait a round
		For 1200
			'home button 1375, 75
			IfColor bsX+1375, bsY+75, "EEE9E6", 0 Then 
				Exit For
			End If
			Delay 100
		Next
		StopThread mpthread
		dailyMPReward = 0
		timeEnd=Plugin.Sys.GetTime()
		
		timeElapsed=CLng((timeEnd-timeStart)/6000)
		If nextEurotime - timeElapsed > 0 Then 
			eurothread = BeginThread(euroMain)
			For nextEurotime-timeElapsed
				If ticketEmpty = 1 Then 
					Exit For
				End If
				For 60
					Delay 1000			
				Next
			Next
			For 1200
				IfColor bsX+1375, bsY+75, "EEE9E6", 0 Then 
					Exit For
				End If
				Delay 100
			Next
			StopThread eurothread
			ticketEmpty = 0
		End If
		
	Wend
End Sub


Sub SEhuntMain
	While 1
		
		HwndEx = Plugin.Window.Search("BlueStacks Tweaker")
		bsHandler = Plugin.Window.Find(0, "BlueStacks")
		If NOT (HwndEx="" OR bsHandler <= 0) Then 
			Call Plugin.Window.Restore(bsHandler)
			Call Plugin.Window.Top(bsHandler,0)
			Delay 2000
			Call getBSHandler
			MoveTo bsX+10, bsY+10
			LeftClick 1
			Delay 2000
		Else
			Call initAS9
		End If

		URCorner = GetPixelColor(bsX + 1375, bsY + 75)
		If NOT ( URCorner = "EEE9E6" OR URCorner = "C9C8C8" ) Then 
			'try to click back button 292,948 563631
			MoveTo bsX+35, bsY+863
			LeftClick 1
			Delay 5000
		End If
		'cancel exit game dialog when needed
		IfColor bsX+650, bsY+588, "210900", 0 Then
			IfColor bsX+1085, bsY+588, "210900", 0 Then
				KeyPress "Esc", 1
				Delay 5000
			End If
		End If

		'no ads now
		If failRunCount < 3 Then 
			'MoveTo bsX+10, bsY+10
			'LeftClick 1
			'Delay 1000
			'show homepage button
			IfColor bsX+1375, bsY+75, "EEE9E6", 1 Then 
				MoveTo bsX+1375, bsY+75
				LeftClick 1
				Delay 3000
			End If
			IfColor bsX+1375, bsY+75, "EEE9E6", 0 Then 
				MoveTo bsX+1375, bsY+75
				LeftClick 1
				Delay 3000
				Call initCarSEhunt
				Call runCarSEhunt
			Else 
				failRunCount = failRunCount + 1
			End If
		Else 
			'restart when failRunCount >=3
			failRunCount = 0
			Call initAS9
			Call initCarSEhunt
			Call runCarSEhunt
		End If

	Wend
End Sub


Sub dailyMP

	mpMaxCarLevel=4

	While 1

		HwndEx = Plugin.Window.Search("BlueStacks Tweaker")
		bsHandler = Plugin.Window.Find(0, "BlueStacks")
		If NOT (HwndEx="" OR bsHandler <= 0) Then 
			Call Plugin.Window.Restore(bsHandler)
			Call Plugin.Window.Top(bsHandler,0)
			Delay 2000
			Call getBSHandler
			MoveTo bsX+10, bsY+10
			LeftClick 1
			Delay 2000
		Else
			Call initAS9
		End If

		URCorner = GetPixelColor(bsX+1375, bsY+75)
		If NOT ( URCorner = "EEE9E6" OR URCorner = "C9C8C8" ) Then 
			'try to click back button 292,948 563631
			MoveTo bsX+35, bsY+863
			LeftClick 1
			Delay 5000
		End If
		'cancel exit game dialog when needed
		IfColor bsX+650, bsY+588, "210900", 0 Then
			IfColor bsX+1085, bsY+588, "210900", 0 Then
				KeyPress "Esc", 1
				Delay 5000
			End If
		End If

		'no ads now
		If failRunCount < 3 Then 
			'MoveTo bsX+10, bsY+10
			'LeftClick 1
			'Delay 1000
			'show homepage button
			IfColor bsX+1375, bsY+75, "EEE9E6", 1 Then 
				MoveTo bsX+1375, bsY+75
				LeftClick 1
				Delay 3000
			End If
			IfColor bsX+1375, bsY+75, "EEE9E6", 0 Then 
				MoveTo bsX+1375, bsY+75
				LeftClick 1
				Delay 3000
				Call initMP
				Call runCarMP
			Else 
				failRunCount = failRunCount + 1
			End If
		Else 
			'restart when failRunCount >=3
			failRunCount = 0
			Call initAS9
			Call initMP
			Call runCarMP
		End If

	Wend
End Sub


Sub euroMain
	While 1

		HwndEx = Plugin.Window.Search("BlueStacks Tweaker")
		bsHandler = Plugin.Window.Find(0, "BlueStacks")
		If NOT (HwndEx="" OR bsHandler <= 0) Then 
			Call Plugin.Window.Restore(bsHandler)
			Call Plugin.Window.Top(bsHandler,0)
			Delay 2000
			Call getBSHandler
			MoveTo bsX+10, bsY+10
			LeftClick 1
			Delay 2000
		Else
			Call initAS9
		End If

		URCorner = GetPixelColor(bsX+1375, bsY+75)
		If NOT ( URCorner = "EEE9E6" OR URCorner = "C9C8C8" ) Then 
			'try to click back button 292,948 563631
			MoveTo bsX+35, bsY+863
			LeftClick 1
			Delay 5000
		End If
		'cancel exit game dialog when needed
		IfColor bsX+650, bsY+588, "210900", 0 Then
			IfColor bsX+1085, bsY+588, "210900", 0 Then
				KeyPress "Esc", 1
				Delay 5000
			End If
		End If

		'no ads now
		If failRunCount < 3 Then 
			'MoveTo bsX+10, bsY+10
			'LeftClick 1
			'Delay 1000
			'show homepage button
			IfColor bsX+1375, bsY+75, "EEE9E6", 1 Then 
				MoveTo bsX+1375, bsY+75
				LeftClick 1
				Delay 3000
			End If
			IfColor bsX+1375, bsY+75, "EEE9E6", 0 Then 
				MoveTo bsX+1375, bsY+75
				LeftClick 1
				Delay 3000
				Call initEuro
				Call runCarEuro
			Else 
				failRunCount = failRunCount + 1
			End If
		Else 
			'restart when failRunCount >=3
			failRunCount = 0
			Call initAS9
			Call initEuro
			Call runCarEuro
		End If

	Wend
End Sub


Sub getBSHandler
	
	bsHandler = Plugin.Window.Find(0, "BlueStacks")
	bsArray = Split(Plugin.Window.GetClientRect(bsHandler), "|")
	bsX = CLng(bsArray(0)) '257
	bsY = CLng(bsArray(1)) '85
	
End Sub

Sub initAS9

	'launch bstweaker
	HwndEx = Plugin.Window.Search("BlueStacks Tweaker")
	If NOT HwndEx = "" Then 
		HwndEx2Int = Split(HwndEx, "|")
		tweakerHandler = CLng(HwndEx2Int(0))
		Call Plugin.Window.Close(tweakerHandler)
	End If
	RunApp tweakerPath
	Delay 2500
	HwndEx = Plugin.Window.Search("BlueStacks Tweaker")
	HwndEx2Int = Split(HwndEx, "|")
	tweakerHandler = CLng(HwndEx2Int(0))
	
	'get tweaker xy
	Call Plugin.Window.Restore(tweakerHandler)
	Delay 2000
	Call Plugin.Window.Top(tweakerHandler, 0)
	Delay 1000
	tweakerArray = Split(Plugin.Window.GetClientRect(tweakerHandler), "|")
	tweakerX = CLng(tweakerArray(0)) '18
	tweakerY = CLng(tweakerArray(1)) '41
	
	'switch to bstweaker
	MoveTo tweakerX + 40, tweakerY + 10
	Delay 1000
	LeftClick 1
	'forcekill BS
	MoveTo tweakerX + 600, tweakerY + 160
	Delay 1000
	LeftClick 1
	Do While ( Not Plugin.Window.Find(0, "BlueStacks")=0 )
		Delay 1000
	Loop
	Delay 2000
	'restart bs
	MoveTo tweakerX + 500, tweakerY + 80
	Delay 1000
	LeftClick 1
	Delay 1000
	'Call Plugin.Window.Min(tweakerHandler)
	Delay 1000
	Call Plugin.Window.Top(tweakerHandler, 1)
	
	'remove dupe icons in systray
	ScreenW = Plugin.Sys.GetScRX()
	ScreenH = Plugin.Sys.GetScRY()
	FindColor CLng(ScreenW/2),ScreenH-45,ScreenW,ScreenH,"269942",intX,intY
	If intX > 0 And intY > 0 Then 
		MoveTo intX, intY
		Delay 1000
	End If

	'get handler id
	Call getBSHandler
	Call Plugin.Window.Top(bsHandler,0)
		
	For 200
		IfColor bsX + 65, bsY + 177, "FFD100", 0 Then
			Exit For
		End If
		Delay 1000
	Next
	Delay 1000
	
	'launch a9
	MoveTo bsX + 185, bsY + 11
	Delay 1000
	LeftClick 1
	MoveTo bsX+a9IconX, bsY+a9IconY
	Delay 1000
	LeftClick 1
	Delay 2000
	LeftClick 1
	For 60
		a9Launched = GetPixelColor(bsX + 21, bsY + 493)
		If (a9Launched = "060202" OR a9Launched = "331200") Then 
			Exit For
		End If
		Delay 1000
	Next
	Delay 3000

	'skip startup ads
	'career button 1003,795
	GetColor = GetPixelColor(bsX + 1003, bsY + 795)
	If GetColor = "53230E" OR GetColor = "FFFFFF" Then 
		Exit Sub
	End If
	KeyPress "Esc", 1
	Delay 3000

End Sub


Sub initEuro

	'switch to & click mycareer
	MoveTo bsX+1003, bsY+795
	IfColor bsX+1003, bsY+795, "FFFFFF",0 Then
		LeftClick 1
		Delay 2000
	Else 
		LeftClick 1
		Delay 2000
		LeftClick 1
		Delay 2000
	End If

	'click slidebar to euroshowdown
	MoveTo bsX+1129,bsY+808
	LeftClick 1
	Delay 2000
	'click euroshowdown
	MoveTo bsX+843,bsY+265
	LeftClick 1
	Delay 2000

End Sub


Sub runCarEuro
	While 1

		'scroll to race12
		MoveTo 943+bsX, 275+bsY
		LeftClick 1
		Delay 1000
		For 8
			MouseWheel 1
			Delay 1000
		Next
		
		'click race12
		FindColor bsX+436, bsY+128, bsX+591, bsY+813,"12FBC3",intX,intY
		MoveTo intX,intY
		LeftClick 1
		Delay 1000

		'advance to car selection
		Call clickNEXT
		Delay 1500

		'pick car & be careful with infinite loops
		UserVar currentCar=0 "pickCar"
		While currentCar = 0
			currentCar = pickCar()
			Delay 1000
			'exceptions handler
			If currentCar = -1 Then
				failRunCount = failRunCount + 1
				Exit Sub
			End If
		Wend
		
		MoveTo carX, carY
		LeftDown 1
		LeftClick 1
		LeftUp 1
		Delay 2000
		Call touchDriveCheck
		Call clickNEXT
		Delay 5000

		'runcar
		For 10000
			KeyDown "Space", 1
			Delay 10
			KeyUp "Space", 1
			FindColor bsX+1036,bsY+745,bsX+1089,bsY+775,"12FBC3",intX,intY
			If intX> 0 And intY> 0 Then
				Delay 200
				Exit For
			End If
		Next

		'skip ending scenes
		KeyPress "Esc", 1
		Delay 2000
		KeyPress "Esc", 1
		Delay 2000
		KeyPress "Esc", 1
		Delay 2000

		'reset counts after successful run
		failRunCount = 0
		successRunCount=successRunCount+1
		prevCar = currentCar
	
		'freepackcheck
		IfColor bsX+1061,bsY+125,"00FEBF",0 Then
			IfColor bsX+1111,bsY+124,"00FEBF",0 Then
				IfColor bsX+1166,bsY+123,"00FEBF",0 Then
					Call freePackClaim
				end If
			end If
		end If

	Wend
End Sub


Function pickCar

	pickCar = 0
	
	'car1 car3
	'car2 car4
	Dim carX1
	Dim carY1
	Dim carX2
	Dim carY2
	carX1=493
	carY1=500
	carX2=822
	carY2=765
	
	If prevCar = 1 Then 
		IfColor bsX+carX1,bsY+carY1, "12FBC3", 0 Then
			pickCar = 1
			carX = bsX+carX1
			carY = bsY+carY1
			'still need to set pressCount
			pressCount = 173
			Exit Function
		End If
	End If

	If prevCar = 2 Then 
		IfColor bsX+carX1,bsY+carY2, "12FBC3", 0 Then
			pickCar = 2
			carX = bsX+carX1
			carY = bsY+carY2
			pressCount = 181
			Exit Function
		End If
	End If

	If prevCar = 3 Then 
		IfColor bsX+carX2,bsY+carY1, "12FBC3", 0 Then
			pickCar = 3
			carX = bsX+carX2
			carY = bsY+carY1
			pressCount = 170
			Exit Function
		End If
	End If

	If prevCar = 4 Then 
		IfColor bsX+carX2,bsY+carY2, "12FBC3", 0 Then
			pickCar = 4
			carX = bsX+carX2
			carY = bsY+carY2
			pressCount = 165
			Exit Function
		End If
	End If

	'=============not prevCar================
	IfColor bsX+carX2,bsY+carY1, "12FBC3", 0 Then
		pickCar = 3
		carX = bsX+carX2
		carY = bsY+carY1
		pressCount = 170
		Exit Function
	End If

	IfColor bsX+carX2,bsY+carY2, "12FBC3", 0 Then
		pickCar = 4
		carX = bsX+carX2
		carY = bsY+carY2
		pressCount = 165
		Exit Function
	End If

	IfColor bsX+carX1,bsY+carY2, "12FBC3", 0 Then
		pickCar = 2
		carX = bsX+carX1
		carY = bsY+carY2
		pressCount = 181
		Exit Function
	End If

	IfColor bsX+carX1,bsY+carY1, "12FBC3", 0 Then
		pickCar = 1
		carX = bsX+carX1
		carY = bsY+carY1
		pressCount = 173
		Exit Function
	End If

	IfColor bsX+carX1,bsY+carY1, "5401FF", 0 Then
		pickCar = 0
		ticketEmpty = 1
		Delay 2000
		Exit Function
	Else 
		pickCar = - 1 
		Exit Function
	End If
	
End Function


Sub initMP

	'switch to & click mp
	MoveTo bsX+543,bsY+795
	IfColor bsX+543,bsY+795, "FFFFFF",0 Then
		LeftClick 1
		Delay 2500
	Else 
		LeftClick 1
		Delay 2500
		LeftClick 1
		Delay 4500
	End If

End Sub


Sub runCarMP
	While 1

		'claim rewards
		IfColor bsX+213,bsY+628, "2B3D2E", 0 Then
			IfColor bsX+213,bsY+628, "2B3D2E", 0 Then
				MoveTo bsX+629,bsY+740
				LeftClick 1
				Delay 6000
				KeyPress Esc, 1
				Delay 6000
			End If
		End If

		'daily reward already collected?
		'denote the following if run anyway
		/*
		IfColor bsX+183,bsY+646,"14FBC3",1 Then
			dailyMPReward = 1
			'delay >= 1500 in mainloop
			Delay 5000
			Exit Sub
		End If
		*/

		'click play
		FindColor bsX + 760, bsY + 755, bsX + 770, bsY + 765, "12FBC3", intX, intY
		If intX > 0 and intY > 0 Then 
			MoveTo intX, intY
			LeftClick 1
			Delay 2000
		Else 
			failRunCount = failRunCount + 1
			Exit Sub
		End If

		'pick car
		UserVar currentCar=0 "pickCarMP"
		For 40
			currentCar = pickCarMP()
			Delay 1000
			'exceptions handler
			If currentCar = -1 Then
				failRunCount = failRunCount + 1
				Exit Sub
			End If
			If currentCar > 0 Then
				MoveTo carX, carY
				LeftDown 1
				LeftClick 1
				LeftUp 1
				Delay 2000
				IfColor bsX+930,bsY+749,"8EC9DD",1 Then 'legend n/a
					IfColor bsX+901,bsY+755,"F76592",1 Then 'plat n/a
						IfColor bsX + 960, bsY + 756, "00CCFF", 1 Then'gold n/a
							Exit For
						End If
					End If
				End If
			End If
			mpMaxCarLevel=mpMaxCarLevel-1
			KeyPress "Esc",1
			Delay 2000
			currentCar=0
		Next
		
		If currentCar <= 0 Then 
			failRunCount = failRunCount + 3
			Exit Sub
		End If
		Call touchDriveCheck
		Call clickNEXT
		Delay 12000

		'runCarMP
		pressCount = 2200
		For pressCount
			KeyDown "Space", 1
			Delay 100
			KeyUp "Space", 1
			KeyPress "A", 1
			FindColor bsX+1036,bsY+745,bsX+1089,bsY+775,"12FBC3",intX,intY
			If intX> 0 And intY> 0 Then
				Delay 200
				Exit For
			End If
		Next

		'skip ending scenes
		KeyPress "Esc", 1
		Delay 3000
		KeyPress "Esc", 1
		Delay 5000

		'reset counts after successful run
		failRunCount = 0
		successRunCount=successRunCount+1

		'freepackcheck
		IfColor bsX+1061,bsY+125,"00FEBF",0 Then
			IfColor bsX+1111,bsY+124,"00FEBF",0 Then
				IfColor bsX+1166,bsY+123,"00FEBF",0 Then
					Call freePackClaim
				end If
			end If
		end If

	Wend
End Sub


Function pickCarMP

	pickCarMP = 0

	If mpMinCarLevel > mpMaxCarLevel Then
		dailyMPReward = 1
		Delay 1000
		Exit Function
	End If

	'car7 car1 car3 car5
	'car8 car2 car4 car6 

	'================================================
	'legend
	If mpMaxCarLevel>=4 Then

		MoveTo bsX+1301,bsY+162
		LeftClick 1
		Delay 2000

		FindColor bsX+1212,bsY+454,bsX+1326,bsY+509,"12FBC3",intX,intY
		If intX> 0 And intY> 0 Then
			carX = intX
			carY = intY
			pickCarMP = 2
			Exit Function
		End If

		If mpMinCarLevel=4 Then
			FindColor bsX+1212,bsY+454,bsX+1326,bsY+509,"5401FF",intX,intY
			If intX> 0 And intY> 0 Then
				pickCarMP = 0
				'fake reward claimed, to exit MP thread
				dailyMPReward = 1
				Delay 1000
				Exit Function
			Else 
				pickCarMP = - 1 
				Exit Function
			End If
		End If

	End If

	'================================================
	'platinum
	If mpMaxCarLevel>=3 Then

		MoveTo bsX+1203,bsY+167
		LeftClick 1
		Delay 2000

		'car3
		FindColor bsX+886,bsY+464,bsX+964,bsY+506,"12FBC3",intX,intY
		If intX> 0 And intY> 0 Then
			carX = intX
			carY = intY
			pickCarMP = 3
			Exit Function
		End If

		'car2
		FindColor bsX+516,bsY+725,bsX+587,bsY+763,"12FBC3",intX,intY
		If intX> 0 And intY> 0 Then
			carX = intX
			carY = intY
			pickCarMP = 2
			Exit Function
		End If

		'car1
		FindColor bsX+516,bsY+467,bsX+591,bsY+501,"12FBC3",intX,intY
		If intX> 0 And intY> 0 Then
			carX = intX
			carY = intY
			pickCarMP = 1
			Exit Function
		End If

		If mpMinCarLevel=3 Then
			FindColor bsX+516,bsY+467,bsX+591,bsY+501,"5401FF",intX,intY
			If intX> 0 And intY> 0 Then
				pickCarMP = 0
				dailyMPReward = 1
				Delay 1000
				Exit Function
			Else 
				pickCarMP = - 1 
				Exit Function
			End If
		End If

	End If

	'================================================
	'gold
	If mpMaxCarLevel>=2 Then

		MoveTo bsX+1123,bsY+169
		LeftClick 1
		Delay 1500

		'car3
		FindColor bsX+886,bsY+464,bsX+964,bsY+506,"12FBC3",intX,intY
		If intX> 0 And intY> 0 Then
			carX = intX
			carY = intY
			pickCarMP = 3
			Exit Function
		End If

		'car2
		FindColor bsX+516,bsY+725,bsX+587,bsY+763,"12FBC3",intX,intY
		If intX> 0 And intY> 0 Then
			carX = intX
			carY = intY
			pickCarMP = 2
			Exit Function
		End If

		'car1
		FindColor bsX+516,bsY+467,bsX+591,bsY+501,"12FBC3",intX,intY
		If intX> 0 And intY> 0 Then
			carX = intX
			carY = intY
			pickCarMP = 1
			Exit Function
		End If

		If mpMinCarLevel=2 Then
			FindColor bsX+516,bsY+467,bsX+591,bsY+501,"5401FF",intX,intY
			If intX> 0 And intY> 0 Then
				pickCarMP = 0
				dailyMPReward = 1
				Delay 1000
				Exit Function
			Else 
				pickCarMP = - 1 
				Exit Function
			End If
		End If

	End If

	'================================================
	'silver
	If mpMaxCarLevel>=1 Then

		MoveTo bsX+1029,bsY+168
		LeftClick 1
		Delay 2000

		'car3
		FindColor bsX+886,bsY+464,bsX+964,bsY+506,"12FBC3",intX,intY
		If intX> 0 And intY> 0 Then
			carX = intX
			carY = intY
			pickCarMP = 3
			Exit Function
		End If

		'car2
		FindColor bsX+516,bsY+725,bsX+587,bsY+763,"12FBC3",intX,intY
		If intX> 0 And intY> 0 Then
			carX = intX
			carY = intY
			pickCarMP = 2
			Exit Function
		End If

		'car1
		/*FindColor bsX+516,bsY+467,bsX+591,bsY+501,"12FBC3",intX,intY
		If intX> 0 And intY> 0 Then
			carX = intX
			carY = intY
			pickCarMP = 1
			Exit Function
		End If*/

		If mpMinCarLevel=1 Then
			FindColor bsX+516,bsY+725,bsX+587,bsY+763,"5401FF",intX,intY
			If intX> 0 And intY> 0 Then
				pickCarMP = 0
				dailyMPReward = 1
				Delay 1000
				Exit Function
			Else 
				pickCarMP = - 1 
				Exit Function
			End If
		End If

	End If

	'================================================
	'bronze
	If mpMaxCarLevel>=1 Then

		MoveTo bsX+944,bsY+167
		LeftClick 1
		Delay 2000

		'car3
		FindColor bsX+886,bsY+464,bsX+964,bsY+506,"12FBC3",intX,intY
		If intX> 0 And intY> 0 Then
			carX = intX
			carY = intY
			pickCarMP = 3
			Exit Function
		End If

		'car2
		FindColor bsX+516,bsY+725,bsX+587,bsY+763,"12FBC3",intX,intY
		If intX> 0 And intY> 0 Then
			carX = intX
			carY = intY
			pickCarMP = 2
			Exit Function
		End If

		'car1
		FindColor bsX+516,bsY+467,bsX+591,bsY+501,"12FBC3",intX,intY
		If intX> 0 And intY> 0 Then
			carX = intX
			carY = intY
			pickCarMP = 1
			Exit Function
		End If

		If mpMinCarLevel=1 Then
			FindColor bsX+516,bsY+467,bsX+591,bsY+501,"5401FF",intX,intY
			If intX> 0 And intY> 0 Then
				pickCarMP = 0
				dailyMPReward = 1
				Delay 1000
				Exit Function
			Else 
				pickCarMP = - 1 
				Exit Function
			End If
		End If

	End If

End Function


Sub freePackClaim
	MoveTo bsX+1188,bsY+93
	LeftClick 1
	Delay 3500
	MoveTo bsX+710,bsY+462
	LeftClick 1
	Delay 3500
	IfColor bsX+709,bsY+735,"12FBC3",0 Then
		MoveTo bsX+709,bsY+735
		LeftClick 1
		Delay 5000
		KeyPress "Esc",1
		Delay 2000
		KeyPress "Esc",1
		Delay 2000
	End If
End Sub


Sub clickNEXT
	MoveTo bsX+1143,bsY+785
	LeftClick 1
	Delay 1000
End Sub


Sub touchDriveCheck
	IfColor bsX+1301,bsY+680, "12FBC3", 0 Then
		Exit Sub
	Else
		MoveTo bsX+1301,bsY+680
		LeftClick 1
		Delay 2000
	End If
End Sub



Sub initCarSEhunt

	'switch to & click daily event
	MoveTo bsX+91,bsY+745
	IfColor bsX+91,bsY+745, "FFFFFF",0 Then
		LeftClick 1
		Delay 2000
	Else 
		LeftClick 1
		Delay 2000
		LeftClick 1
		Delay 2000
	End If

	'cash run
	For 18
		KeyPress "Left",1
		Delay 200
	Next
	'looking for special event
	MoveTo bsX+717,bsY+427
	LeftClick 1
	Delay 3000

End Sub


Function pickCarSEhunt

	pickCarSEhunt = 0
	
	Dim amgX
	Dim amgY
	
	'find AMG
	FindColor bsX+132,bsY+514,bsX+1290,bsY+802,"1899E0",intX,intY
	If intX> 0 And intY> 0 Then
		amgX=intX '1108
		amgY=intY '739
		'ticket 1108,837
	Else 
		ticketEmpty = 1
		Exit Function
	End If

	FindColor amgX-15,amgY+90,amgX+15,amgY+110,"12FBC3",intX,intY
	If intX > 0 And intY > 0 Then 
		carX = intX
		carY = intY
		pickCarSEhunt = 1
		pressCount = 61
		nextEurotime = 30
		Exit Function
	End If

	FindColor amgX-15,amgY+90,amgX+15,amgY+110,"5401FF",intX,intY
	If intX> 0 And intY> 0 Then
		pickCarSEhunt = 0
		nextEurotime = 30
		fuelEmpty = 1
		Exit Function
	Else 
		pickCarSEhunt = -1 
		Exit Function
	End If

	'starup page skip
	IfColor bsX+455,bsY+756, "40220D", 0 Then
		IfColor bsX+497,bsY+754, "40220D", 0 Then
			IfColor bsX+628,bsY+753, "FFFFFF", 0 Then
				KeyPress "Esc", 1
				Delay 4000
				pickCarSEhunt = 0
				Exit Function
			End If
		End If
	End If

End Function


Sub runCarSEhunt
	While 1

		'advance to car selection
		Call clickNEXT
		Delay 2500

		'pick car
		UserVar currentCar=0 "pickCarMP"
		While currentCar = 0
			currentCar = pickCarSEhunt()
			Delay 1000
			'exceptions handler
			If currentCar = -1 Then
				failRunCount = failRunCount + 1
				Exit Sub
			End If
		Wend

		MoveTo carX, carY
		LeftDown 1
		LeftClick 1
		LeftUp 1
		Delay 2000
		Call touchDriveCheck
		Call clickNEXT
		
		IfColor bsX+1234,bsY+240, "5500FF", 0 Then
			IfColor bsX+1208,bsY+241, "FFFFFF", 0 Then
				IfColor bsX+503,bsY+591, "12FBC3", 0 Then
					'ticket insufficient
					/*For 6
						IfColor bsX+816,bsY+612, "FFFFFF", 0 Then
							MoveTo bsX+816,bsY+612
							LeftClick 1
							Call adSkipper
						End If
					Next*/
					nextEurotime = 30
					KeyPress "Esc",1
					ticketEmpty = 1
					Delay 5000
					Exit Sub
				Else 
					'ticket refilling error -> restart
					failRunCount = failRunCount + 3
					Exit Sub
				End If
			End If
		End If
		
		'wait till load page
		For 1000
			IfColor bsX+94,bsY+155,"2A1ABF", 1 Then
				Delay 5
			Else 
				Exit For
			End If
		Next
		'wait till load complete
		For 3000
			IfColor bsX+94,bsY+155,"2A1ABF", 0 Then
				Delay 5
			Else 
				Exit For
			End If
		Next
		'wait till timer start
		Delay 10200
		
		'run amg
		'first stage
		For 13
			KeyPress "D",1
			'KeyPress "Space", 1
			Delay 550
		Next
		For 5
			KeyPress "A",1
			'KeyPress "D",1
			KeyPress "Space", 1
			Delay 550
		Next
		For 22
			KeyPress "Space", 1
			Delay 50
		Next
		'12.4
		KeyDown "S", 1
		Delay 50
		KeyUp "S",1
		Delay 4400

		'first turn
		KeyPress "Space", 1
		Delay 550
		KeyPress "Space", 1
		Delay 1500
		For 5
			KeyPress "A",1
			KeyPress "Space", 1
			Delay 550
		Next
		KeyDown "S", 1
		Delay 50
		KeyUp "S",1
		Delay 1100

		'second turn
		For 7
			KeyPress "A",1
			KeyPress "Space", 1
			Delay 550
		Next

		For 7
			KeyPress "D",1
			KeyPress "Space", 1
			Delay 550
		Next
		pressCount = 110
		For pressCount
			KeyPress "A",1
			KeyPress "Space", 1
			Delay 550
			FindColor bsX+1036,bsY+745,bsX+1089,bsY+775,"12FBC3",intX,intY
			If intX> 0 And intY> 0 Then
				Delay 200
				Exit For
			End If
		Next

		'skip ending scenes
		KeyPress "Esc", 1
		MoveTo 100,100
		Delay 2000
		KeyPress "Esc", 1
		MoveTo 300,300
		Delay 5000
		KeyPress "Esc", 1
		MoveTo 400,400
		Delay 2000

		'reset counts after successful run
		failRunCount=0
		successRunCount=successRunCount+1

	Wend
End Sub

