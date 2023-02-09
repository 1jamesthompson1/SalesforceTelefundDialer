#SingleInstance Force
SendMode "Input"
SetWorkingDir A_ScriptDir

programName := "Salesforce Dialer v0.0.2"

MouseDisabling := false

loop
{
  if not A_IsAdmin
    {
      Run '*RunAs "' A_ScriptFullPath '" /restart'
      ExitApp
    }
  ; Install and setup the program  
  if !FileExist("config.ini")
  {

    MsgBox "Starting install"
    installLocation := A_ProgramFiles "\salesforceDialer"
    configLocation := installLocation  "\config.ini"
    shortcutLocation := A_Programs "\Salesforce Dialer.lnk"

    ;Check to see if it is already installed if so do uninstall procedure
    if DirExist(installLocation)  != "" 
    {
      uninstall(installLocation, shortcutLocation)
    }

    install(installLocation, shortcutLocation)

    MsgBox "Installed now time to setup!"
    CoordMode "Mouse"
    MsgBox "Please press on the phone number", programName
    MouseDisabling := true
    sleep 200
    KeyWait "LButton", "D"
    MouseGetPos &xpos, &ypos
    phoneNumberX := xpos
    phoneNumberY := ypos
    MouseDisabling := !MouseDisabling

    writeToConfig("phoneNumberX", phoneNumberX)
    writeToConfig("phoneNumberY", phoneNumberY)

    ; userName := InputBox("What is your name?", "Seting up" programName)
    ; if (userName.Result = "Cancel") 
    ;   ExitApp

    ; writeToConfig("userName", userName.value)
  }
  else
  { 

    ; userName := readConfig("userName")

    phoneNumberX := readConfig("phoneNumberX")
    phoneNumberY := readConfig("phoneNumberY")

    startupGUI := Gui(,programName)
    startupGUI.Add("Text",, "Welcome to the Salesforce dialer")
    
    ; startupGUI.Add("Text",, "Your current user name is:")
    ; editBox := startupGUI.Add("Edit", "r1", userName)
    ; changeName := startupGUI.Add("Button", ,"Change name")
    ; changeName.OnEvent("Click", editName.Bind(editBox.Value))

    GetCallingBtn := startupGUI.AddButton("Default w80", "Ok")
    GetCallingBtn.OnEvent("Click", closeStartupGUI.Bind(startupGUI)) 

    startupGUI.Show
    Break
  }
}

closeStartupGUI(gui, info, btn) {
  gui.Destroy() 
}

readConfig(key) {
  return IniRead("config.ini", "Settings", key)
}

writeToConfig(key, value) {
  IniWrite value, "config.ini", "Settings", key
}

editName(currentName, GuiCtrlObj, Info) {
  MsgBox "Changing name to" currentName
    writeToConfig("userName", currentName)
}

uninstall(installLocation, shortcutLocation) {
  DirDelete installLocation, 1
  FileDelete shortcutLocation
}

install(installLocation, shortcutLocation) {
  DirCreate installLocation
  FileMove A_ScriptName, installLocation
  SetWorkingDir installLocation
  FileCreateShortcut A_WorkingDir "\" A_ScriptName, shortcutLocation
}

; THis script will go from being selected on the right cell to dialing the caller and upadting the call attempt
dial(phoneX, phoneY) {
  Sleep 200
  Send "{Enter}"
  Sleep 300
  Send "{Down}"
  Sleep 300
  Send "{Enter}"
  Sleep 300
  MsgBox "Has the leads record loaded?", "Waiting for phone load", "T3"

  
  MouseClick "left", phoneX, phoneY, 2

  Sleep 100

  Send "^c"

  Sleep 100

  ; Process the phone number so that it can be called
  phoneNumber := A_Clipboard
  
  if (StrLen(phoneNUmber) < 8) {
    MsgBox(StrLen(phoneNumber))
    MsgBox("I beleive there is something wrong with the phone number.`nThis is what I have: " phoneNumber, "Error in phone number")
    return
  }

  if (SubStr(phoneNumber, 1, 2) == "64") {
    formattedPhoneNumber := "10" SubStr(phoneNumber, 3)
  } else {
    formattedPhoneNumber := "1" phoneNumber
  }

  WinWait "FormCallAssistance"
	WinActivate

  Send formattedPhoneNumber

  Send "{Enter}"

  ; ; Move back to the browser
  ; WinWait "chrome.exe"
	; WinActivate
  return
}

Rctrl::F14

;Default shortcut for dial
F14::
{
  dial(phoneNumberX, phoneNumberY)
  return
}


#HotIf  MouseDisabling
LButton::return
#HotIf