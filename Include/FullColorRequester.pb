;==============================================================================
; Author:     blueb
; Date:       May 8, 2017
; Explain:    Create a new ColorRequester that saves User Colors (between calls)
; Forum:      http://www.purebasic.fr/english/viewtopic.php?f=12&t=68450
; Saved as:   FullColorRequester.pb
; Addition:   ChrisR: ColorPref array + choose color window position
;==============================================================================

EnableExplicit
; -----------------------------------------------------------------------------
; Goal - write a 'Unique' preference file in the temporary directory that
; stays in the temporary directory even when user switches to other programs.
; It will keep the special colors the user last adjusted.
; -----------------------------------------------------------------------------
Declare InitColorPrefs()
Declare ExitColorPrefs()
Declare FullColorRequester(X.i = 0, Y.i = 0)

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
Global.i Dim ColorPref(15)

Procedure InitColorPrefs()   ;Color Preference file - Storage information in GetCurrentDirectory for SweetyVD instead of GetTemporaryDirectory()
  Protected I.l
  If OpenPreferences(GetCurrentDirectory() + "GetUserColors.prefs") = 0 ; Does not exist, "GetUserColors.prefs" is erased. So create it with Default values
    CreatePreferences(GetCurrentDirectory() + "GetUserColors.prefs")
    For I = 0 To 15
      WritePreferenceInteger("COLORREF"+Str(I+1), ColorPref(I))
    Next
    ClosePreferences()
  Else   ;It exists, retrieve the GetUserColors.prefs information
    For I = 0 To 15
      ColorPref(I) = ReadPreferenceInteger("COLORREF"+Str(I+1), ColorPref(I))
    Next
    ClosePreferences()
  EndIf
EndProcedure

Procedure ExitColorPrefs()
  Protected I.l
  If OpenPreferences(GetCurrentDirectory() + "GetUserColors.prefs")
    For I = 0 To 15
      WritePreferenceInteger("COLORREF"+Str(I+1), ColorPref(I))
    Next
    ClosePreferences()
   EndIf
EndProcedure

Procedure FullColorRequester(X.i = 0, Y.i = 0)   ;Place CHOOSECOLOR Info into requester()
  Protected CHOOSECOLOR.CHOOSECOLOR, COLORREF.COLORREF, hwnd.i, I.l
  hwnd = OpenWindow(#PB_Any, X, Y, 0, 0, "", #PB_Window_Invisible)
  StickyWindow(hwnd, #True)
  ;InitColorPrefs()   ;Done once in SweetyVD Init() proc 
  ;Place saved colors inside requester()
  For I = 0 To 15
    COLORREF\RGB[I] = ColorPref(I)
  Next

  CHOOSECOLOR\LStructSize = SizeOf(CHOOSECOLOR)
  If IsWindow(hwnd)   ;Window Owner
    CHOOSECOLOR\hwndOwner = WindowID(hwnd)
  Else   ;No Owner
    CHOOSECOLOR\hwndOwner = 0
  EndIf
  CHOOSECOLOR\rgbResult = 0   ;Nothing selected
  CHOOSECOLOR\lpCustColors = COLORREF
  CHOOSECOLOR\flags = #CC_ANYCOLOR | #CC_RGBINIT

  If ChooseColor_(@CHOOSECOLOR)
    For I = 0 To 15
      ColorPref(I) = COLORREF\RGB[I]
    Next
    ;ExitColorPrefs()   ;Save info, done once in SweetyVD Exit() proc. Return Color Selected
    CloseWindow(hwnd)
    ProcedureReturn CHOOSECOLOR\rgbResult
  Else   ;No color was selected
    ;ExitColorPrefs()   ;Save info, done once in SweetyVD Exit() proc. Return -1 as ColorRequester()
    CloseWindow(hwnd)
    ProcedureReturn -1
  EndIf
EndProcedure

;Example: uncomment InitColorPrefs() and ExitColorPrefs()
; Define SelectedColor.i = FullColorRequester(100, 100)
; Debug ColorRequester()
; If SelectedColor = -1
;   Debug "Canceled by user"
; Else
;   Debug "Color Selected: " + SelectedColor
;   Debug "Hex: " + "$" + RSet(Hex(Blue(SelectedColor)), 2, "0") + RSet(Hex(Green(SelectedColor)), 2, "0") + RSet(Hex(Red(SelectedColor)), 2, "0")   ;Hex value in BGR format
;   Debug "RGB(" + Str(Red(SelectedColor)) + ", " + Str(Green(SelectedColor)) + ", " + Str(Blue(SelectedColor)) + ")"
; EndIf

; IDE Options = PureBasic 5.60 (Windows - x64)
; Folding = -
; EnableXP