;==================================================================
;
; Author:     blueb
; Date:       May 8, 2017
; Explain:    Create a new ColorRequester that saves User Colors (between calls)
; Forum:      http://www.purebasic.fr/english/viewtopic.php?f=12&t=68450
; Saved as:   FullColorRequester.pb
;=========================================================

EnableExplicit
; --------------------------------------------------------------------------
; Goal - write a 'Unique' preference file in the temporary directory that 
; stays in the temporary directory even when user switches to other programs.
; It will keep the special colors the user last adjusted.
; --------------------------------------------------------------------------
Declare InitColorPrefs()
Declare ExitColorPrefs()
Declare FullColorRequester()

Structure COLORREF
  RGB.l[16]
EndStructure 

; Structure CHOOSECOLOR ; see PB toolbox
;      lStructSize.l
;      hwndOwner.i
;      hInstance.i
;      rgbResult.l
;      *lpCustColors
;      Flags.l
;      lCustData.i
;      *lpfnHook
;      *lpTemplateName
; EndStructure

; Needed for preferences file.
Global.i  COLORREF1, COLORREF2, COLORREF3, COLORREF4, COLORREF5, COLORREF6, COLORREF7, COLORREF8, COLORREF9 
Global.i  COLORREF10, COLORREF11, COLORREF12, COLORREF13, COLORREF14, COLORREF15, COLORREF16

Procedure InitColorPrefs()   ;Color Preference file - Storage information
  If OpenPreferences(GetTemporaryDirectory() + "GetUserColors.prefs") = 0 ; Does not exist, "GetUserColors.prefs" is erased. So create it with Default values
    CreatePreferences(GetTemporaryDirectory() + "GetUserColors.prefs")
    WritePreferenceInteger("COLORREF1", COLORREF1)   ;The first color
    WritePreferenceInteger("COLORREF2", COLORREF2)
    WritePreferenceInteger("COLORREF3", COLORREF3)
    WritePreferenceInteger("COLORREF4", COLORREF4)
    WritePreferenceInteger("COLORREF5", COLORREF5)
    WritePreferenceInteger("COLORREF6", COLORREF6)
    WritePreferenceInteger("COLORREF7", COLORREF7)
    WritePreferenceInteger("COLORREF8", COLORREF8)
    WritePreferenceInteger("COLORREF9", COLORREF9)
    WritePreferenceInteger("COLORREF10", COLORREF10)
    WritePreferenceInteger("COLORREF11", COLORREF11)
    WritePreferenceInteger("COLORREF12", COLORREF12)
    WritePreferenceInteger("COLORREF13", COLORREF13)
    WritePreferenceInteger("COLORREF14", COLORREF14)
    WritePreferenceInteger("COLORREF15", COLORREF15)
    WritePreferenceInteger("COLORREF16", COLORREF16)
    ClosePreferences()
  Else   ;It exists, retrieve the GetUserColors.prefs information
    COLORREF1 = ReadPreferenceInteger("COLORREF1", COLORREF1)   ;The first user color
    COLORREF2 = ReadPreferenceInteger("COLORREF2", COLORREF2)
    COLORREF3 = ReadPreferenceInteger("COLORREF3", COLORREF3)
    COLORREF4 = ReadPreferenceInteger("COLORREF4", COLORREF4)
    COLORREF5 = ReadPreferenceInteger("COLORREF5", COLORREF5)
    COLORREF6 = ReadPreferenceInteger("COLORREF6", COLORREF6)
    COLORREF7 = ReadPreferenceInteger("COLORREF7", COLORREF7)
    COLORREF8 = ReadPreferenceInteger("COLORREF8", COLORREF8)
    COLORREF9 = ReadPreferenceInteger("COLORREF9", COLORREF9)
    COLORREF10 = ReadPreferenceInteger("COLORREF10", COLORREF10)
    COLORREF11 = ReadPreferenceInteger("COLORREF11", COLORREF11)
    COLORREF12 = ReadPreferenceInteger("COLORREF12", COLORREF12)
    COLORREF13 = ReadPreferenceInteger("COLORREF13", COLORREF13)
    COLORREF14 = ReadPreferenceInteger("COLORREF14", COLORREF14)
    COLORREF15 = ReadPreferenceInteger("COLORREF15", COLORREF15)
    COLORREF16 = ReadPreferenceInteger("COLORREF16", COLORREF16)
    ClosePreferences()
  EndIf
EndProcedure

Procedure ExitColorPrefs()
  If OpenPreferences(GetTemporaryDirectory() + "GetUserColors.prefs")
    WritePreferenceInteger("COLORREF1", COLORREF1)   ;The first color
    WritePreferenceInteger("COLORREF2", COLORREF2)
    WritePreferenceInteger("COLORREF3", COLORREF3)
    WritePreferenceInteger("COLORREF4", COLORREF4)
    WritePreferenceInteger("COLORREF5", COLORREF5)
    WritePreferenceInteger("COLORREF6", COLORREF6)
    WritePreferenceInteger("COLORREF7", COLORREF7)
    WritePreferenceInteger("COLORREF8", COLORREF8)
    WritePreferenceInteger("COLORREF9", COLORREF9)
    WritePreferenceInteger("COLORREF10", COLORREF10)
    WritePreferenceInteger("COLORREF11", COLORREF11)
    WritePreferenceInteger("COLORREF12", COLORREF12)
    WritePreferenceInteger("COLORREF13", COLORREF13)
    WritePreferenceInteger("COLORREF14", COLORREF14)
    WritePreferenceInteger("COLORREF15", COLORREF15)
    WritePreferenceInteger("COLORREF16", COLORREF16)
    ClosePreferences()
   EndIf
EndProcedure

Procedure FullColorRequester()   ;Place CHOOSECOLOR Info into requester()
  Protected CHOOSECOLOR.CHOOSECOLOR, COLORREF.COLORREF
  
  InitColorPrefs()
  ;Place saved colors inside requester()
  COLORREF\RGB[0] = COLORREF1
  COLORREF\RGB[1] = COLORREF2
  COLORREF\RGB[2] = COLORREF3
  COLORREF\RGB[3] = COLORREF4
  COLORREF\RGB[4] = COLORREF5
  COLORREF\RGB[5] = COLORREF6
  COLORREF\RGB[6] = COLORREF7
  COLORREF\RGB[7] = COLORREF8
  COLORREF\RGB[8] = COLORREF9
  COLORREF\RGB[9] = COLORREF10
  COLORREF\RGB[10] = COLORREF11
  COLORREF\RGB[11] = COLORREF12
  COLORREF\RGB[12] = COLORREF13
  COLORREF\RGB[13] = COLORREF14
  COLORREF\RGB[14] = COLORREF15
  COLORREF\RGB[15] = COLORREF16
  
  CHOOSECOLOR\LStructSize = SizeOf(CHOOSECOLOR)
  CHOOSECOLOR\hwndOwner = WindowID(0)
  CHOOSECOLOR\rgbResult = 0   ;Nothing selected
  CHOOSECOLOR\lpCustColors = COLORREF
  CHOOSECOLOR\flags = #CC_ANYCOLOR | #CC_FULLOPEN | #CC_RGBINIT
  
  If ChooseColor_(@CHOOSECOLOR)
     COLORREF1 =COLORREF\RGB[0]
     COLORREF2 =COLORREF\RGB[1]
     COLORREF3 =COLORREF\RGB[2]
     COLORREF4 =COLORREF\RGB[3]
     COLORREF5 =COLORREF\RGB[4]
     COLORREF6 =COLORREF\RGB[5]
     COLORREF7 =COLORREF\RGB[6]
     COLORREF8 =COLORREF\RGB[7]
     COLORREF9 =COLORREF\RGB[8]
     COLORREF10 =COLORREF\RGB[9]
     COLORREF11 =COLORREF\RGB[10]
     COLORREF12 =COLORREF\RGB[11]
     COLORREF13 =COLORREF\RGB[12]
     COLORREF14 =COLORREF\RGB[13]
     COLORREF15 =COLORREF\RGB[14]
     COLORREF16 =COLORREF\RGB[15]
    ExitColorPrefs()   ;Save info and Return Color Selected
    ProcedureReturn CHOOSECOLOR\rgbResult
  Else   ;No color was selected
    ExitColorPrefs()   ;Save info
    ProcedureReturn -1
  EndIf
EndProcedure

;Debug "Color Selected " + FullColorRequester()

; IDE Options = PureBasic 5.60 (Windows - x64)
; CursorPosition = 125
; FirstLine = 121
; Folding = -
; EnableXP
; Executable = FullColorRequester.exe