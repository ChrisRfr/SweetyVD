; ---------------------------------------------------------------------------------------
;           Name: SweetyVD
;    Description: Sweety Visual Designer
;     dependency: CodeCreate.pb (Sweety Visual Designer Code Form and Code creation)
;         Author: ChrisR
;           Date: 2017-05-25
;        Version: 2.1.2.0
;     PB-Version: 5.60 (x86/x64)
;             OS: Windows, Linux, Mac
;         Credit: Stargâte: Transformation of gadgets at runtime
;                 Falsam: Tiny Visual Designer (TVD)
;                 blueb: FullColorRequester
;                 Zebuddi: Add PreFix and SuFix for variable (eg: iButton_1.i)
;  English-Forum: http://www.purebasic.fr/english/viewtopic.php?f=27&t=68187
;   French-Forum: http://www.purebasic.fr/french/viewtopic.php?f=3&t=16527
;         Github: https://github.com/ChrisRfr/SweetyVD
; ---------------------------------------------------------------------------------------

Structure StructureGadget       ;Structure of gadgets. Gadget 0 for OpenWindow
  Gadget.i                      ;gadget Id
  Model.s                       ;Gadget Model (ButtonGadget, TextGadget ........)
  Type.i                        ;Type
  Name.s                        ;Name
  Vname.s                       ;Variable Name Prefix and Post Fix
  X.i                           ;Pos X
  Y.i                           ;Pos Y
  Width.i                       ;Dim Width
  Height.i                      ;Dim Height
  Caption.s                     ;Caption Or Gadget content
  ToolTip.s                     ;ToolTip
  Option1.s                     ;Option1
  Option2.s                     ;Option2
  Option3.s                     ;Option2
  FontID.i                      ;Font ID
  FrontColor.s                  ;FrontColor
  BackColor.s                   ;FrontColor
  Constants.s                   ;Available Constants (Ex: "#PB_Text_Center,#PB_Text_Right,#PB_Text_Border")
  Hide.b                        ;Hide Gadget
  Disable.b                     ;Disable Gadget
  Lock.b                        ;Lock Gadget
  ModelType.i                   ;0=Window, 2=Gadget, 9=Gadget Deleted
  Key.s                         ;ModelType + GadgetY(IdGadget) + GadgetX(IdGadget)
EndStructure

Declare.s sStringToLength(sString.s, iLength.i)
Declare.s GetTempFilename(BaseName.s, NbRamdomLetter.l, ext.s)
Declare   CodeCreateOnTimer()
Declare   CodeCreate(Dest.s = "")
Declare.s CustomAddition(Group.s)

Procedure.s sStringToLength(sString.s, iLength.i)
  ProcedureReturn sString + Space(iLength - Len(sString))
EndProcedure

Procedure.s GetTempFilename(BaseName.s, NbRamdomLetter.l, ext.s)
  Protected I.i, FileName.s  = GetTemporaryDirectory() + BaseName
  For I = 1 To NbRamdomLetter
    FileName + Chr('a'+Random(25))
  Next
  FileName + ext
  If FileSize(FileName) = -1   ; If file does not exist, return the generated filename
    ProcedureReturn FileName
  Else                          ; Else: generate a new name
    ProcedureReturn GetTempFilename(BaseName, NbRamdomLetter, ext)
  EndIf
EndProcedure

Procedure CodeCreateOnTimer()
  If MapSize(SVDListGadget()) > 1   ;At least one Gadget
    CodeCreate()
  EndIf
EndProcedure

Procedure CodeCreate(Dest.s = "")
  Protected Dim CodeGadgets.StructureGadget(0)
  Protected IdGadget.i, SavModelType = -1
  Protected ImageExtPath.s, ImageExtFullPath.s, TmpImagePath.s, sFontStyle.s, IncludeFileAdded.s, IncludeFileAddedTmp.s
  Protected Code_TitleBlock.b = #True, CodeEnumeration.b = #True, CodeConstants.b = #True, CodeEventLoop.b = #True, CodeCustomAddition.b = 0
  Protected TmpCode.s, DateFormat.s="%yyyy-%mm-%dd"
  Protected Code.s, Model.s, Name.s, X.s, Y.s, Width.s, Height.s, Caption.s, Caption7.s
  Protected Mini.i, Maxi.i, Hexa_Color.b, SavCodeImageID.s, TmpColor.i, TmpTabName.s, ActiveTab.i=-1, TmpConstants.s, INDENT$ = "  ", FirstPass.b, I.i, J.i
  Protected WinName.s, sPreF.s, sSuFF.s = ".i", iVarNameLength.i
  Protected sFilePath.s, hFile.i, CompilerPath.s, ProgramName.s
  Protected Compiler.i, LastProgramString.s, SavTitle.s

  If MapSize(SVDListGadget()) <= 1   ;At least one Gadget
    MessageRequester("SweetyVD Information", "Let me play with at least one Gadget. Please  ;)", #PB_MessageRequester_Warning|#PB_MessageRequester_Ok)
    ProcedureReturn 1
  EndIf

  If FileSize(PBIDEpath) < 1
    MessageRequester("SweetyVD Warning", "Define the PureBasic path beforehand", #PB_MessageRequester_Warning|#PB_MessageRequester_Ok)
    ProcedureReturn 1
  EndIf

  If OpenPreferences("SweetyVD.ini", #PB_Preference_GroupSeparator)
    PreferenceGroup("Designer")
    DisplayHandleCornerOnMove    = ReadPreferenceLong("Display_Handle_Corner_On_Move", DisplayHandleCornerOnMove)
    DisplayUnselectedItemsBorder = ReadPreferenceLong("Display_Unselected_Items_Border", DisplayUnselectedItemsBorder)
    PreferenceGroup("CodeCreate")
    Code_TitleBlock              = ReadPreferenceLong("Include_TitleBlock", Code_TitleBlock)
    CodeEnumeration              = ReadPreferenceLong("Include_Enumeration", CodeEnumeration)
    If ReadPreferenceLong("Variable", 0) = #True : CodeConstants = #False : EndIf
    CodeEventLoop                = ReadPreferenceLong("Include_EventLoop", CodeEventLoop)
    CodeCustomAddition           = ReadPreferenceLong("Include_CustomAddition", CodeCustomAddition)
    PreferenceGroup("CodeOption")
    Hexa_Color                   = ReadPreferenceLong("Hexa_Color", Hexa_Color)
    sPreF                        = ReadPreferenceString("PreFix", sPreF)
    sSuFF                        = ReadPreferenceString("Suffix", sSuFF)
    If ReadPreferenceLong("Suffix_Enabled", 0) = 0 : sSuFF = #Null$ : EndIf
    If ReadPreferenceLong("Tab_Indentation", 0) = 1
      INDENT$ = #TAB$
    Else
      INDENT$ = Space(ReadPreferenceLong("Space_Indentation", 2))
    EndIf
    ClosePreferences()
  EndIf

  I = 0
  ReDim CodeGadgets(MapSize(SVDListGadget())-1)
  ResetMap(SVDListGadget())
  With SVDListGadget()
    While NextMapElement(SVDListGadget())
      CodeGadgets(I)\Gadget     = \Gadget
      CodeGadgets(I)\Model      = \Model
      CodeGadgets(I)\Type       = \Type
      CodeGadgets(I)\Name       = \Name
      CodeGadgets(I)\Vname      =  sPreF + Mid(\Name, 2)   ;get var with prefix
      CodeGadgets(I)\X          = \X
      CodeGadgets(I)\Y          = \Y
      CodeGadgets(I)\Width      = \Width
      CodeGadgets(I)\Height     = \Height
      CodeGadgets(I)\Caption    = \Caption
      CodeGadgets(I)\ToolTip    = \ToolTip
      CodeGadgets(I)\Option1    = \Option1
      CodeGadgets(I)\Option2    = \Option2
      CodeGadgets(I)\Option3    = \Option3
      CodeGadgets(I)\FontID     = \FontID
      CodeGadgets(I)\FrontColor = \FrontColor
      CodeGadgets(I)\BackColor  = \BackColor
      CodeGadgets(I)\Constants  = \Constants
      CodeGadgets(I)\Hide       = \Hide
      CodeGadgets(I)\Disable    = \Disable
      CodeGadgets(I)\Lock       = \Lock
      CodeGadgets(I)\ModelType  = \ModelType
      If \ModelType = 0   ;Gadget Deleted
        CodeGadgets(I)\Key = Str(\ModelType) + RSet("0", 5, "0") + RSet("0", 5, "0")
      ElseIf \ModelType = 1
        CodeGadgets(I)\Key = Str(\ModelType) + RSet(Str(\Y), 5, "0") + RSet(Str(\X), 5, "0")
      ElseIf \ModelType = 2
        CodeGadgets(I)\Key = Str(\ModelType) + RSet(Str(\Y), 5, "0") + RSet(Str(\X), 5, "0")
      Else
        CodeGadgets(I)\Key = Str(\ModelType) + RSet("0", 5, "0") + RSet("0", 5, "0")
      EndIf
      If Len(CodeGadgets(I)\Vname) > iVarNameLength   ;Find max len var with prefix for indentation
        iVarNameLength = Len(CodeGadgets(I)\Vname)
      EndIf
      I + 1
    Wend
  EndWith

  If AddMenu   ;Status Bar Enumeration length
    If Len(sPreF + "MainMenu") > iVarNameLength
      iVarNameLength = Len(sPreF + "MainMenu")
    EndIf
  EndIf
  If AddPopupMenu   ;Status Bar Enumeration length
    If Len(sPreF + "PopupMenu") > iVarNameLength
      iVarNameLength = Len(sPreF + "PopupMenu")
    EndIf
  EndIf
  If AddToolBar   ;Status Bar Enumeration length
    If Len(sPreF + "ToolBar") > iVarNameLength
      iVarNameLength = Len(sPreF + "ToolBar")
    EndIf
  EndIf
  If AddStatusBar   ;Status Bar Enumeration length
    If Len(sPreF + "StatusBar") > iVarNameLength
      iVarNameLength = Len(sPreF + "StatusBar")
    EndIf
  EndIf

  For I = 0 To ArraySize(CodeGadgets())
    CodeGadgets(I)\Vname = sStringToLength(CodeGadgets(I)\Vname, iVarNameLength)   ; Expand all gadget names to max name length
  Next

  SortStructuredArray(CodeGadgets(), #PB_Sort_Ascending, OffsetOf(StructureGadget\Key), TypeOf(StructureGadget\Key))

  If Code_TitleBlock = #True   ;-Include Title block
    If OpenPreferences("SweetyVD.ini", #PB_Preference_GroupSeparator)
      PreferenceGroup("TitleBlock")
      DateFormat =  ReadPreferenceString("FormatDate", DateFormat)
      ExaminePreferenceKeys()
      While  NextPreferenceKey()
        If Left(PreferenceKeyName(), 4) = "Line"
          TmpCode = ReplaceString(PreferenceKeyValue(), "%Date%", FormatDate(DateFormat, Date()), #PB_String_NoCase, 1)
          If TmpCode <> "" Or Code <> "": Code + TmpCode +#CRLF$ : EndIf
        EndIf
      Wend
      ClosePreferences()
    EndIf
  EndIf
  Code + #CRLF$

  If CodeEnumeration = #True
    Code + "EnableExplicit" +#CRLF$+#CRLF$
  EndIf

  If CodeCustomAddition
    TmpCode = CustomAddition("CustomAddition_Include")
    If TmpCode <> "" : Code + TmpCode +#CRLF$ : EndIf
  EndIf

  For I=0 To ArraySize(CodeGadgets())   ;XIncludeFile "TabBarGadget.pbi" if used
    With CodeGadgets(I)
      Select \Type
        Case 40   ;Type specific TabBar Gadget
          If FindString(IncludeFileAdded, "TabBarGadget.pbi;", 1) = 0
            If FileSize(GetCurrentDirectory() + "CustomGadgets\TabBarGadget.pbi") > 1
              Code + "XIncludeFile " + #DQUOTE$ + GetCurrentDirectory() + "CustomGadgets\TabBarGadget.pbi" + #DQUOTE$ +#CRLF$
            ElseIf FileSize(GetCurrentDirectory() + "Include\TabBarGadget.pbi") > 1
              Code + "XIncludeFile " + #DQUOTE$ + GetCurrentDirectory() + "Include\TabBarGadget.pbi" + #DQUOTE$ +#CRLF$
            ElseIf FileSize(GetCurrentDirectory() + "TabBarGadget.pbi") > 1
              Code + "XIncludeFile " + #DQUOTE$ + GetCurrentDirectory() + "TabBarGadget.pbi" + #DQUOTE$ +#CRLF$
            Else
              Code + "XIncludeFile " + #DQUOTE$ + "TabBarGadget.pbi" + #DQUOTE$ +#CRLF$
            EndIf
            IncludeFileAdded + "TabBarGadget.pbi;"
          EndIf
        Case 50   ;Custom Gadget
          For J=0 To ArraySize(ModelGadget())
            If ModelGadget(J)\Type = \Type
              IncludeFileAddedTmp = ModelGadget(J)\CustomIncludeFile
              If FindString(IncludeFileAdded, IncludeFileAddedTmp + ";", 1) = 0
                Code + "XIncludeFile " + #DQUOTE$ + IncludeFileAddedTmp + #DQUOTE$ +#CRLF$
                IncludeFileAdded + IncludeFileAddedTmp + ";"
              EndIf
            EndIf
          Next
      EndSelect
    Next
  EndWith
  If IncludeFileAdded <> ""
    Code +#CRLF$
  EndIf

  If CodeCustomAddition
    TmpCode = CustomAddition("CustomAddition_Constante")
    If TmpCode <> "" : Code + TmpCode +#CRLF$ : EndIf
  EndIf
  If CodeConstants = 0 And CodeCustomAddition
    TmpCode = CustomAddition("CustomAddition_Structure")
    If TmpCode <> "" : Code + TmpCode +#CRLF$ : EndIf
  EndIf
  If CodeConstants = 0 And CodeCustomAddition
    TmpCode = CustomAddition("CustomAddition_Variable")
    If TmpCode <> "" : Code + TmpCode +#CRLF$ : EndIf
  EndIf

  ;window global declaration code
  If CodeEnumeration = #True   ;-Include Enumeration
    With CodeGadgets(0)
      If CodeConstants = #True
        Code + "Enumeration Window" +#CRLF$
        Code +INDENT$+ \Name +#CRLF$
        Code + "EndEnumeration" +#CRLF$+#CRLF$
      Else
        Code + "Global " + Trim(\Vname) + sSuFF +#CRLF$+#CRLF$
      EndIf
    EndWith

    If CodeConstants = #True And (AddMenu + AddPopupMenu + AddToolBar + AddStatusBar) > 0
      Code + "Enumeration" +#CRLF$
    EndIf
    If CodeConstants = #True
      If AddMenu = #True : Code +INDENT$+ "#MainMenu" +#CRLF$ : EndIf
      If AddPopupMenu = #True : Code +INDENT$+ "#PopupMenu" +#CRLF$ : EndIf
      If AddToolBar = #True : Code +INDENT$+ "#ToolBar" +#CRLF$ : EndIf
      If AddStatusBar = #True : Code +INDENT$+ "#StatusBar" +#CRLF$ : EndIf
    Else
      If AddMenu = #True : Code + "Global " + sPreF + "MainMenu" + sSuFF +#CRLF$ : EndIf
      If AddPopupMenu = #True : Code + "Global " + sPreF + "PopupMenu" + sSuFF +#CRLF$ :EndIf
      If AddToolBar = #True : Code + "Global " + sPreF + "ToolBar" + sSuFF +#CRLF$ : EndIf
      If AddStatusBar = #True : Code + "Global " + sPreF + "StatusBar" + sSuFF +#CRLF$ : EndIf
    EndIf
    If AddMenu + AddPopupMenu + AddToolBar + AddStatusBar > 0
      If CodeConstants = #True
        Code + "EndEnumeration" +#CRLF$+#CRLF$
      Else
        Code +#CRLF$
      EndIf
    EndIf

    If CodeConstants
      Code + "Enumeration Gadgets" +#CRLF$
    EndIf
    For I=1 To ArraySize(CodeGadgets())
      With CodeGadgets(I)
        If CodeConstants
          Code +INDENT$+ \Name +#CRLF$
        Else
          Code + "Global " + Trim(\Vname) + sSuFF  +#CRLF$
        EndIf
      EndWith
    Next
    If CodeConstants
      Code + "EndEnumeration" +#CRLF$+#CRLF$
    Else
      Code +#CRLF$
    EndIf

    If ListSize(ImageBtnPathArray()) > 0   ;Image Enumeration
      If CodeConstants : Code + "Enumeration FormImage"+#CRLF$ :EndIf
      ResetList(ImageBtnPathArray())
      While NextElement(ImageBtnPathArray())
        If CodeConstants
          Code +INDENT$+ "#Img_" + Mid(CodeGadgets(0)\Name, 2) + "_" + Str(ListIndex(ImageBtnPathArray())) +#CRLF$
        Else
          Code + "Global " + sPreF + "Img_" + Mid(CodeGadgets(0)\Name, 2) + "_" + Str(ListIndex(ImageBtnPathArray())) + sSuFF +#CRLF$
        EndIf
      Wend
      If CodeConstants
        Code + "EndEnumeration" +#CRLF$+#CRLF$
      Else
        Code +#CRLF$
      EndIf
    EndIf

    If ListSize(FontStructArray()) > 0   ;Font Enumeration
      If CodeConstants : Code + "Enumeration FormFont"+#CRLF$ :EndIf
      ResetList(FontStructArray())
      While NextElement(FontStructArray())
        If CodeConstants
          Code +INDENT$+ "#Font_" + Mid(CodeGadgets(0)\Name, 2) + "_" + Str(ListIndex(FontStructArray())) +#CRLF$
        Else
          Code + "Global " + sPreF + "Font_" + Mid(CodeGadgets(0)\Name, 2) + "_" + Str(ListIndex(FontStructArray())) + sSuFF +#CRLF$
        EndIf
      Wend
      If CodeConstants
        Code + "EndEnumeration" +#CRLF$+#CRLF$
      Else
        Code +#CRLF$
      EndIf
    EndIf
  EndIf

  If CodeConstants And CodeCustomAddition
    TmpCode = CustomAddition("CustomAddition_Structure")
    If TmpCode <> "" : Code + TmpCode +#CRLF$ : EndIf
  EndIf

  If AddToolBar = #True
    Code + "UsePNGImageDecoder()" +#CRLF$
    ImageExtFullPath + "*.png" + ";"
  EndIf
  If CodeEnumeration = #True
    If ListSize(ImageBtnPathArray()) > 0   ;Image Enumeration
      ResetList(ImageBtnPathArray())
      While NextElement(ImageBtnPathArray())
        ImageExtPath = LCase(GetExtensionPart(ImageBtnPathArray()\ImagePath))
        If FindString(ImageExtFullPath, "*." + ImageExtPath + ";", 1) = 0
          Select ImageExtPath
            Case "bmp"
            Case "jpg"
              Code + "UseJPEGImageDecoder()" +#CRLF$
            Case "png"
              Code + "UsePNGImageDecoder()" +#CRLF$
          EndSelect
          ImageExtFullPath + "*." + ImageExtPath + ";"
        EndIf
      Wend
      If ImageExtFullPath <> ""
        Code +#CRLF$
      EndIf

      ResetList(ImageBtnPathArray())
      While NextElement(ImageBtnPathArray())
        ;Relative Path. Could be a setting option
        TmpImagePath = ImageBtnPathArray()\ImagePath
        If Left(TmpImagePath, Len(GetCurrentDirectory())) = GetCurrentDirectory()
          TmpImagePath = Mid(TmpImagePath, Len(GetCurrentDirectory())+1)
        EndIf
        If CodeConstants
          Code + "LoadImage(#Img_" + Mid(CodeGadgets(0)\Name, 2) + "_" + Str(ListIndex(ImageBtnPathArray())) + ", " + #DQUOTE$ + TmpImagePath + #DQUOTE$ + ")" +#CRLF$
        Else
          Code + "Global " + sPreF + "Img_" + Mid(CodeGadgets(0)\Name, 2) + "_" + Str(ListIndex(ImageBtnPathArray())) + sSuFF + " = LoadImage(#PB_Any, " + #DQUOTE$ + TmpImagePath + #DQUOTE$ + ")" +#CRLF$
        EndIf
      Wend
      Code +#CRLF$
    EndIf

    If ListSize(FontStructArray()) > 0   ;LoadFont(#Font_MainWindow_2,"Arial", 8, #PB_Font_Bold)
      ResetList(FontStructArray())
      While NextElement(FontStructArray())
        sFontStyle = ""
        If FontStructArray()\FontStyle
          sFontStyle = ", "
          If FontStructArray()\FontStyle & #PB_Font_Bold
            sFontStyle + "#PB_Font_Bold"
          EndIf
          If FontStructArray()\FontStyle & #PB_Font_Italic
            sFontStyle + "#PB_Font_Italic"
          EndIf
          If FontStructArray()\FontStyle & #PB_Font_StrikeOut
            sFontStyle + "#PB_Font_StrikeOut"
          EndIf
          If FontStructArray()\FontStyle & #PB_Font_Underline
            sFontStyle + "#PB_Font_Underline"
          EndIf
          If FontStructArray()\FontStyle & #PB_Font_HighQuality
            sFontStyle + "#PB_Font_HighQuality"
          EndIf
          sFontStyle = ReplaceString(sFontStyle, "#PB", " | #PB",0, 4)
        EndIf
        If CodeConstants
          Code + "LoadFont(#Font_" + Mid(CodeGadgets(0)\Name, 2) + "_" + Str(ListIndex(FontStructArray())) + ", " + #DQUOTE$ + FontStructArray()\FontName + #DQUOTE$ + ", " + Str(FontStructArray()\FontSize) + sFontStyle + ")" +#CRLF$
        Else
          Code + "Global " + sPreF + "Font_" + Mid(CodeGadgets(0)\Name, 2) + "_" + Str(ListIndex(FontStructArray())) + sSuFF + " = LoadFont(#PB_Any, " + #DQUOTE$ + FontStructArray()\FontName + #DQUOTE$ + ", " + Str(FontStructArray()\FontSize) + sFontStyle + ")" +#CRLF$
        EndIf
      Wend
      Code +#CRLF$
    EndIf

  EndIf

  If CodeConstants And CodeCustomAddition
    TmpCode = CustomAddition("CustomAddition_Variable")
    If TmpCode <> "" : Code + TmpCode +#CRLF$ : EndIf
  EndIf

  If CodeEnumeration = #True
    Code + "Define iEvent.i" +#CRLF$+#CRLF$
  EndIf

  If CodeCustomAddition
    TmpCode = CustomAddition("CustomAddition_Declare")
    If TmpCode <> "" : Code + TmpCode +#CRLF$ : EndIf
  EndIf

  ;-Create Window
  With CodeGadgets(0)
    If CodeConstants : Name = \Name : Else : Name = \Vname : EndIf
    Width = Str(SetDrawWidth) : Height = Str(SetDrawHeight)
    Caption = Mid(\Caption, 7)

    Code + "Declare Open_"+Mid(\Name,2)+"(X = 0, Y = 0, Width = "+Width+", Height = "+Height+")" +#CRLF$+#CRLF$

    If CodeCustomAddition
      TmpCode = CustomAddition("CustomAddition_Procedure")
      If TmpCode <> "" : Code + TmpCode +#CRLF$ : EndIf
    EndIf

    Code + "Procedure Open_"+Mid(\Name,2)+"(X = 0, Y = 0, Width = "+Width+", Height = "+Height+")" +#CRLF$

    WinName = Trim(Name)
    If CodeConstants
      Code +INDENT$+ "If OpenWindow(" + Name + ", X, Y, Width, Height, "
    Else
      Code +INDENT$+ Trim(Name) + " = OpenWindow(#PB_Any, X, Y, Width, Height, "
    EndIf
    Code + #DQUOTE$ + Caption + #DQUOTE$   ;For window model, Caption=#Text:blabla => "blabla", or ""

    If \Constants <> ""   ;Are there any Constants for the window
      FirstPass.b = #False
      For I=1 To CountString(\Constants, "|") + 1
        TmpConstants = Trim(StringField(\Constants, I, "|"))
        If Right(TmpConstants, 3) = "(x)"
          If FirstPass = #False
            Code + ", "
            FirstPass = #True
          Else
            Code + " | "
          EndIf
          Code + "#PB_" + Left(TmpConstants, Len(TmpConstants)-3)
        EndIf
      Next
    EndIf

    Code + ")" +#CRLF$   ;End of generation of the window code
    If CodeConstants = #False : Code +INDENT$+ "If " + Name +#CRLF$ :EndIf

    If Left(\BackColor, 5) <> "#Nooo" And \BackColor <> ""   ;Background window color
      TmpColor = Val(\BackColor)
      If Hexa_Color = 1
        Code +INDENT$+INDENT$+ "SetWindowColor(" + Trim(Name) + ", $" + RSet(Hex(Blue(TmpColor)), 2, "0") + RSet(Hex(Green(TmpColor)), 2, "0") + RSet(Hex(Red(TmpColor)), 2, "0") + ")" +#CRLF$   ;Hex value in BGR format
      Else
        Code +INDENT$+INDENT$+ "SetWindowColor(" + Trim(Name) + ", RGB(" + Str(Red(TmpColor)) + ", " + Str(Green(TmpColor)) + ", " + Str(Blue(TmpColor)) + "))" +#CRLF$
      EndIf
    EndIf
  EndWith

  If AddMenu   ;-Add Menu
    If CodeConstants = #True
      Code +#CRLF$+INDENT$+INDENT$+ "If CreateMenu(#MainMenu, WindowID(" + WinName + "))" +#CRLF$
    Else
      Code +#CRLF$+INDENT$+INDENT$+ sStringToLength(sPreF + "MainMenu", iVarNameLength) + INDENT$ + " = CreateMenu(#PB_Any, WindowID(" + WinName + "))" +#CRLF$
      Code +INDENT$+INDENT$+ "If " + sPreF + "MainMenu" +#CRLF$
    EndIf
    Code +INDENT$+INDENT$+INDENT$+ "MenuTitle(" + #DQUOTE$ + "Project"  + #DQUOTE$ + ")" +#CRLF$
    Code +INDENT$+INDENT$+INDENT$+INDENT$+ "MenuItem(0, " + #DQUOTE$ + "New" + #DQUOTE$ + ")" +#CRLF$
    Code +INDENT$+INDENT$+INDENT$+INDENT$+ "MenuItem(1, " + #DQUOTE$ + "Open" + #DQUOTE$ + ")" +#CRLF$
    Code +INDENT$+INDENT$+INDENT$+INDENT$+ "MenuItem(2, " + #DQUOTE$ + "Save" + #DQUOTE$ + ")" +#CRLF$
    Code +INDENT$+INDENT$+INDENT$+INDENT$+ "MenuBar()" +#CRLF$
    CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
      Code +INDENT$+INDENT$+INDENT$+INDENT$+ ""+ #CRLF$
      Code +INDENT$+INDENT$+INDENT$+INDENT$+ "MenuItem(#PB_Menu_About, " + #DQUOTE$ +#DQUOTE$ + ")" +#CRLF$
      Code +INDENT$+INDENT$+INDENT$+INDENT$+ "MenuItem(#PB_Menu_Preferences, " + #DQUOTE$ +#DQUOTE$ + ")" +#CRLF$
    CompilerElse
      Code +INDENT$+INDENT$+INDENT$+INDENT$+ "MenuItem(3, " + #DQUOTE$ + "&Quit" + #DQUOTE$ + ")" +#CRLF$
      Code +INDENT$+INDENT$+INDENT$+INDENT$+ ""+ #CRLF$
      Code +INDENT$+INDENT$+INDENT$+INDENT$+ "MenuTitle(" + #DQUOTE$ + "?" + #DQUOTE$ + ")" +#CRLF$
      Code +INDENT$+INDENT$+INDENT$+INDENT$+ "MenuItem(4, " + #DQUOTE$ + "About" + #DQUOTE$ + ")" +#CRLF$
    CompilerEndIf
    Code +INDENT$+INDENT$+ "EndIf" +#CRLF$
  EndIf
  If AddPopupMenu   ;-Add PopupMenu
    If CodeConstants = #True
      Code +#CRLF$+INDENT$+INDENT$+ "If CreatePopupMenu(#PopupMenu)" +#CRLF$
    Else
      Code +#CRLF$+INDENT$+INDENT$+ sStringToLength(sPreF + "PopupMenu", iVarNameLength) + INDENT$ + " = CreatePopupMenu(#PB_Any)" +#CRLF$
      Code +INDENT$+INDENT$+ "If " + sPreF + "PopupMenu" +#CRLF$
    EndIf
    Code +INDENT$+INDENT$+INDENT$+ "MenuItem(0, " + #DQUOTE$ + "New" + #DQUOTE$ + ")" +#CRLF$
    Code +INDENT$+INDENT$+INDENT$+ "MenuItem(1, " + #DQUOTE$ + "Open" + #DQUOTE$ + ")" +#CRLF$
    Code +INDENT$+INDENT$+INDENT$+ "MenuItem(2, " + #DQUOTE$ + "Save" + #DQUOTE$ + ")" +#CRLF$
    Code +INDENT$+INDENT$+INDENT$+ "MenuBar()" +#CRLF$
    Code +INDENT$+INDENT$+INDENT$+ "OpenSubMenu(" + #DQUOTE$ + "?" + #DQUOTE$ + ")" +#CRLF$
    Code +INDENT$+INDENT$+INDENT$+ "MenuItem(4, " + #DQUOTE$ + "About" + #DQUOTE$ + ")" +#CRLF$
    Code +INDENT$+INDENT$+INDENT$+ "CloseSubMenu()" +#CRLF$
    Code +INDENT$+INDENT$+ "EndIf" +#CRLF$
  EndIf
  If AddToolBar   ;-Add ToolBar
    If CodeConstants = #True
      Code +#CRLF$+INDENT$+INDENT$+ "If CreateToolBar(#ToolBar, WindowID(" + WinName + "))" +#CRLF$
    Else
      Code +#CRLF$+INDENT$+INDENT$+ sStringToLength(sPreF + "ToolBar", iVarNameLength) + INDENT$ + " = CreateToolBar(#PB_Any, WindowID(" + WinName + "))" +#CRLF$
      Code +INDENT$+INDENT$+ "If " + sPreF + "ToolBar" +#CRLF$
    EndIf
    ;Code +INDENT$+INDENT$+INDENT$+ "ToolBarImageButton(0, LoadImage(0, #PB_Compiler_Home + " + #DQUOTE$ + "examples/sources/Data/ToolBar/New.png" + #DQUOTE$ + "))" +#CRLF$
    ;Code +INDENT$+INDENT$+INDENT$+ "ToolBarImageButton(1, LoadImage(0, #PB_Compiler_Home + " + #DQUOTE$ + "examples/sources/Data/ToolBar/Open.png" + #DQUOTE$ + "))" +#CRLF$
    ;Code +INDENT$+INDENT$+INDENT$+ "ToolBarImageButton(2, LoadImage(0, #PB_Compiler_Home + " + #DQUOTE$ + "examples/sources/Data/ToolBar/Save.png" + #DQUOTE$ + "))" +#CRLF$
    Code +INDENT$+INDENT$+INDENT$+ "ToolBarStandardButton(0, #PB_ToolBarIcon_New)" +#CRLF$
    Code +INDENT$+INDENT$+INDENT$+ "ToolBarStandardButton(1, #PB_ToolBarIcon_Open)" +#CRLF$
    Code +INDENT$+INDENT$+INDENT$+ "ToolBarStandardButton(2, #PB_ToolBarIcon_Save)" +#CRLF$
    Code +INDENT$+INDENT$+INDENT$+ "ToolBarSeparator()" +#CRLF$
    Code +INDENT$+INDENT$+ "EndIf" +#CRLF$
  EndIf
  If AddStatusBar   ;-Add StatusBar
    If CodeConstants
      Code +#CRLF$+INDENT$+INDENT$+ "If CreateStatusBar(#StatusBar, WindowID(" + Name + "))" +#CRLF$
      Code +INDENT$+INDENT$+INDENT$+ "AddStatusBarField(80)" +#CRLF$
      Code +INDENT$+INDENT$+INDENT$+ "StatusBarText(#StatusBar, 0, " + #DQUOTE$ + "StatusBar" + #DQUOTE$ + ")" +#CRLF$
    Else
      Code +#CRLF$+INDENT$+INDENT$+ sStringToLength(sPreF + "StatusBar", iVarNameLength) + INDENT$ + " = CreateStatusBar(#PB_Any, WindowID(" + WinName + "))" +#CRLF$
      Code +INDENT$+INDENT$+ "If " + sPreF + "StatusBar" +#CRLF$
      Code +INDENT$+INDENT$+INDENT$+ "AddStatusBarField(80)" +#CRLF$
      Code +INDENT$+INDENT$+INDENT$+ "StatusBarText(" + sPreF + "StatusBar, 0, " + #DQUOTE$ + "StatusBar" + #DQUOTE$ + ")" +#CRLF$
    EndIf
    Code +INDENT$+INDENT$+ "EndIf" +#CRLF$
  EndIf
  If (AddMenu + AddPopupMenu + AddToolBar + AddStatusBar) > 0
    Code +#CRLF$
  EndIf

  ;-Create Gadgets
  For I=1 To ArraySize(CodeGadgets())
    With CodeGadgets(I)
      IdGadget = \Gadget
      Model = \Model
      If CodeConstants : Name = \Name : Else : Name = \Vname : EndIf
      X = Str(\X) : Y = Str(\Y)
      If AddMenu = #True : Y = Str(\Y - AddMenuHeight) : EndIf
      Width = Str(\Width) : Height = Str(\Height)
      Caption = Mid(\Caption, 7)
      SavCodeImageID = "0"

      If Model = "ScintillaGadget"   ;Specific ScintillaGadget: If InitScintilla() : ScintillaGadget(xxx) : EndIf
        Code +#CRLF$+INDENT$+INDENT$+ "If InitScintilla()" +#CRLF$+INDENT$
      EndIf

      If CodeConstants
        Code +INDENT$+INDENT$+ Model + "(" + Name + ", " + X + ", " + Y + ", " + Width + ", " + Height   ;Common part
      Else
        If Model = "ScintillaGadget"
          Code +INDENT$+INDENT$+ Name + " = " + Model + "(#PB_Any, " + X + ", " + Y + ", " + Width + ", " + Height   ;Common part
        Else
          Code +INDENT$+INDENT$+ Name +INDENT$+ " = " + Model + "(#PB_Any, " + X + ", " + Y + ", " + Width + ", " + Height   ;Common part
        EndIf
      EndIf

      Select Left(\Caption, 5)   ;- > Properties Text, Date, Image...
        Case "#Text"
          If Model <> "CanvasGadget"   ;Draw the Text Later for Canvas Gadget
            Code + ", " + #DQUOTE$ + Caption + #DQUOTE$   ;Caption=#Text:blabla => "blabla", or ""
          EndIf
        Case "#Date"
          If Caption <> "" Or FindString(\Constants, "(x)") > 0
            Code + ", " + #DQUOTE$ + Caption + #DQUOTE$ + ", 0"   ;"%dd/%mm/%yyyy". If empty, nothing and no comma for the default value
          EndIf
        Case "#Dir$"
          If Caption <> "" And FileSize(Caption) <> -2 : Caption = "" : EndIf   ;check folder: Empty if it is not a folder
          Code + ", " + #DQUOTE$ + Caption + #DQUOTE$
        Case "#Url$" : Code + ", " + #DQUOTE$ + Caption + #DQUOTE$   ;It should be a valid Url
      EndSelect

      Select Left(\Option1, 5)
        Case "#Mini" : Code + ", " + Mid(\Option1, 7)
        Case "#InrW" : Code + ", " + Mid(\Option1, 7)
        Case "#Hard" : Code + ", " + Mid(\Option1, 7)
        Case "#Titl" : Code + ", " +#DQUOTE$+ Name +#DQUOTE$
        Case "#Imag"
          TmpImagePath = Mid(\Option1, 7)
          If TmpImagePath = "0"
            SavCodeImageID = "0"
          Else
            ResetList(ImageBtnPathArray())
            While NextElement(ImageBtnPathArray())
              If ImageBtnPathArray()\ImagePath = TmpImagePath
                If CodeConstants
                  SavCodeImageID = "ImageID(#Img_" + Mid(CodeGadgets(0)\Name, 2) + "_" + Str(ListIndex(ImageBtnPathArray())) + ")"
                Else
                  SavCodeImageID = "ImageID(" + sPreF + "Img_" + Mid(CodeGadgets(0)\Name, 2) + "_" + Str(ListIndex(ImageBtnPathArray())) + ")"
                EndIf
                Break
              EndIf
            Wend
          EndIf
          If Model = "ButtonImageGadget" Or Model = "ImageGadget"
            Code + ", " +SavCodeImageID
          EndIf
      EndSelect

      Select Left(\Option2, 5)
        Case "#Maxi" : Code + ", " + Mid(\Option2, 7)
        Case "#InrH" : Code + ", " + Mid(\Option2, 7)
        Case "#Widh" : Code + ", " + Mid(\Option2, 7)
      EndSelect

      ;Specific addition
      Select Model
        Case "ScrollBarGadget" : Code + ", 0"                      ;Specific ScrollBarGadget: Page length
        Case "ScrollAreaGadget" : Code + ", " + Mid(\Option3, 7)   ;Specific ScrollAreaGadget: Displacement Value

      EndSelect

      If \Constants <> ""   ;- > Constants
        FirstPass.b = #False
        For J=1 To CountString(\Constants, "|") + 1
          TmpConstants = Trim(StringField(\Constants, J, "|"))
          If Right(TmpConstants, 3) = "(x)"
            If FirstPass = #False
              Code + ", "
              FirstPass = #True
            Else
              Code + " | "
            EndIf
            Select \Type
              Case 40   ;Specific TabBar Gadget
                Code + "#TabBarGadget_" + Left(TmpConstants, Len(TmpConstants)-3)
              Case 50   ;Specific Custom Gadget
                Code + Left(TmpConstants, Len(TmpConstants)-3)
              Default
                Code + "#PB_" + Left(TmpConstants, Len(TmpConstants)-3)
            EndSelect
          EndIf
        Next
      EndIf

      If Model = "TabBarGadget"   ;Specific TabBar Gadget
        If FirstPass = #False : Code + ", 0" :EndIf
        If CodeConstants : Code + ", " + CodeGadgets(0)\Name : Else : Code + ", " + sPreF + Mid(CodeGadgets(0)\Name,2) : EndIf
      EndIf

      Code + ")" +#CRLF$   ;End of generation of the gadget code

      ;- > Specific addition AddGadgetItem...
      Select Model
        Case "CanvasGadget"
          If SavCodeImageID <> "0"
            Code +INDENT$+INDENT$+INDENT$+ "SetGadgetAttribute("+ Trim(Name) + ", #PB_Button_Image, " + SavCodeImageID + ")" +#CRLF$
          EndIf
          If Caption <> ""
            Code +INDENT$+INDENT$+INDENT$+ "If StartDrawing(CanvasOutput(" + Trim(Name) + "))" +#CRLF$
            Code +INDENT$+INDENT$+INDENT$+INDENT$+ "DrawingMode(#PB_2DDrawing_Transparent)" +#CRLF$
            If \FontID <> 0
              ResetList(FontStructArray())
              While NextElement(FontStructArray())
                If FontStructArray()\FontID = \FontID
                  If CodeConstants
                    Code +INDENT$+INDENT$+INDENT$+INDENT$+ "DrawingFont(FontID(" + "#Font_" + Mid(CodeGadgets(0)\Name, 2) + "_" + Str(ListIndex(FontStructArray())) + "))" +#CRLF$
                  Else
                    Code +INDENT$+INDENT$+INDENT$+INDENT$+ "DrawingFont(FontID(" + sPreF + "Font_" + Mid(CodeGadgets(0)\Name, 2) + "_" + Str(ListIndex(FontStructArray())) + "))" +#CRLF$
                  EndIf
                  Break
                EndIf
              Wend
            EndIf
            Code +INDENT$+INDENT$+INDENT$+INDENT$+ "DrawText(5, 5, " + #DQUOTE$ + Caption + #DQUOTE$ + ", #Blue, #White)" +#CRLF$
            Code +INDENT$+INDENT$+INDENT$+INDENT$+ "StopDrawing()" +#CRLF$
            Code +INDENT$+INDENT$+INDENT$+ "EndIf" +#CRLF$
          EndIf

        Case "ComboBoxGadget"
          Code +INDENT$+INDENT$+INDENT$+ "AddGadgetItem("+ Trim(Name) + ", -1, " + #DQUOTE$ + Mid(\Name,2) + #DQUOTE$ + ")" +#CRLF$
          Code +INDENT$+INDENT$+INDENT$+ "SetGadgetState("+ Trim(Name) + ", 0)" +#CRLF$
        Case "EditorGadget"
          Code +INDENT$+INDENT$+INDENT$+ "AddGadgetItem("+ Trim(Name) + ", -1, " + #DQUOTE$ + Mid(\Name,2) + #DQUOTE$ + ")" +#CRLF$
        Case "IPAddressGadget"
          Code +INDENT$+INDENT$+INDENT$+ "SetGadgetState("+ Trim(Name) + ", MakeIPAddress(127, 0, 0, 1))" +#CRLF$
        Case "ListIconGadget"
          Code +INDENT$+INDENT$+INDENT$+ "AddGadgetItem("+ Trim(Name) + ", -1, " + #DQUOTE$ + "Element1" + #DQUOTE$ + ")" +#CRLF$
        Case "ListViewGadget"
          Code +INDENT$+INDENT$+INDENT$+ "AddGadgetItem("+ Trim(Name) + ", -1, " + #DQUOTE$ + Mid(\Name,2) + " (Element1)" + #DQUOTE$ + ")" +#CRLF$
        Case "PanelGadget"
          For J=0 To CountString(Caption, "|")   ;Draw Tab + Text (eg: "Tab1|Tab2(x)|Tab3"
            TmpTabName = Trim(StringField(Caption, J+1, "|"))
            If TmpTabName <> ""
              If Right(TmpTabName, 3) = "(x)"
                TmpTabName = Left(TmpTabName, Len(TmpTabName)-3)
                Code +INDENT$+INDENT$+INDENT$+ "AddGadgetItem("+ Trim(Name) + ", -1, " + #DQUOTE$ + TmpTabName + #DQUOTE$ + ")" +#CRLF$
                ActiveTab = J
              Else
                Code +INDENT$+INDENT$+INDENT$+ "AddGadgetItem("+ Trim(Name) + ", -1, " + #DQUOTE$ + TmpTabName + #DQUOTE$ + ")" +#CRLF$
              EndIf
            EndIf
          Next
          If ActiveTab = -1 : ActiveTab = 0 : EndIf
          Code +INDENT$+INDENT$+INDENT$+ "SetGadgetState(" + Trim(Name) + ", " + ActiveTab + ")" +#CRLF$
        Case "ScintillaGadget"
          : Code +INDENT$+INDENT$+ "EndIf" +#CRLF$+#CRLF$
        Case "TreeGadget"
          Code +INDENT$+INDENT$+INDENT$+ "AddGadgetItem("+ Trim(Name) + ", -1, " + #DQUOTE$ + "Node" + #DQUOTE$ + ", 0,  0)" +
                ": AddGadgetItem("+ Trim(Name) + ", -1, " + #DQUOTE$ + "Sub-element" + #DQUOTE$ + ", 0,  1)" +
                ": AddGadgetItem("+ Trim(Name) + ", -1, " + #DQUOTE$ + "Element" + #DQUOTE$ + ", 0,  0)" +
                ":SetGadgetItemState("+ Trim(Name) + ", 0, #PB_Tree_Expanded)" +#CRLF$
        Case "ProgressBarGadget", "SpinGadget", "TrackBarGadget"   ;Set progression 2/3 Cosmetic
          Mini = Val(Mid(\Option1, 7)) : Maxi = Val(Mid(\Option2, 7))
          Code +INDENT$+INDENT$+INDENT$+ "SetGadgetState("+ Trim(Name) + ", " + Str(Mini+(Maxi-Mini)*2/3) + ")" +#CRLF$
        Case "TabBarGadget"
          Code +INDENT$+INDENT$+INDENT$+ "AddTabBarGadgetItem("+ Trim(Name) + ", #PB_Default, " + #DQUOTE$ + Caption + #DQUOTE$ + ")" +#CRLF$
      EndSelect

      If Left(\FrontColor, 5) <> "#Nooo" And \FrontColor <> ""
        TmpColor = Val(\FrontColor)
        If Hexa_Color = 1
          Code +INDENT$+INDENT$+INDENT$+ "SetGadgetColor(" + Trim(Name) + ", #PB_Gadget_FrontColor, $" + RSet(Hex(Blue(TmpColor)), 2, "0") + RSet(Hex(Green(TmpColor)), 2, "0") + RSet(Hex(Red(TmpColor)), 2, "0") + ")" +#CRLF$   ;Hex value in BGR format
        Else
          Code +INDENT$+INDENT$+INDENT$+ "SetGadgetColor(" + Trim(Name) + ", #PB_Gadget_FrontColor, RGB(" + Str(Red(TmpColor)) + ", " + Str(Green(TmpColor)) + ", " + Str(Blue(TmpColor)) + "))" +#CRLF$
        EndIf
        ;Code +INDENT$+INDENT$+ "SetGadgetColor(" + Trim(Name) + ", #PB_Gadget_FrontColor, " + \FrontColor + ")" +#CRLF$
      EndIf
      If Left(\BackColor, 5) <> "#Nooo" And \BackColor <> ""
        TmpColor = Val(\BackColor)
        If Hexa_Color = 1
          Code +INDENT$+INDENT$+INDENT$+ "SetGadgetColor(" + Trim(Name) + ", #PB_Gadget_BackColor, $" + RSet(Hex(Blue(TmpColor)), 2, "0") + RSet(Hex(Green(TmpColor)), 2, "0") + RSet(Hex(Red(TmpColor)), 2, "0") + ")" +#CRLF$   ;Hex value in BGR format
        Else
          Code +INDENT$+INDENT$+INDENT$+ "SetGadgetColor(" + Trim(Name) + ", #PB_Gadget_BackColor, RGB(" + Str(Red(TmpColor)) + ", " + Str(Green(TmpColor)) + ", " + Str(Blue(TmpColor)) + "))" +#CRLF$
        EndIf
        ;Code +INDENT$+INDENT$+INDENT$+ "SetGadgetColor(" + Trim(Name) + ", #PB_Gadget_BackColor, " + \BackColor + ")" +#CRLF$
      EndIf

      If \ToolTip <> "#Nooo" And \ToolTip <> ""
        Code +INDENT$+INDENT$+INDENT$+ "GadgetToolTip(" + Trim(Name) + ", " + #DQUOTE$ + \ToolTip + #DQUOTE$ + ")" +#CRLF$
      EndIf

      If \FontID <> 0 And \Model <> "CanvasGadget"
        ResetList(FontStructArray())
        While NextElement(FontStructArray())
          If FontStructArray()\FontID = \FontID
            If CodeConstants
              Code +INDENT$+INDENT$+INDENT$+ "SetGadgetFont(" + Trim(Name) + ", FontID(" + "#Font_" + Mid(CodeGadgets(0)\Name, 2) + "_" + Str(ListIndex(FontStructArray())) + "))" +#CRLF$
            Else
              Code +INDENT$+INDENT$+INDENT$+ "SetGadgetFont(" + Trim(Name) + ", FontID(" + sPreF + "Font_" + Mid(CodeGadgets(0)\Name, 2) + "_" + Str(ListIndex(FontStructArray())) + "))" +#CRLF$
            EndIf
            Break
          EndIf
        Wend
      EndIf

      If \Hide = #PB_Checkbox_Checked
        Code +INDENT$+INDENT$+INDENT$+ "HideGadget(" + Trim(Name) + ", #True)" +#CRLF$
      EndIf
      If \Disable = #PB_Checkbox_Checked
        Code +INDENT$+INDENT$+INDENT$+ "DisableGadget(" + Trim(Name) + ", #True)" +#CRLF$
      EndIf

      Select Model
        Case "ContainerGadget", "PanelGadget", "ScrollAreaGadget"
          Code +INDENT$+INDENT$+INDENT$+ "CloseGadgetList()" +#CRLF$
      EndSelect

    EndWith
  Next

  Code +INDENT$+ "EndIf" +#CRLF$
  Code + "EndProcedure" +#CRLF$+#CRLF$

  If CodeCustomAddition
    TmpCode = CustomAddition("CustomAddition_Init")
    If TmpCode <> "" : Code + TmpCode +#CRLF$ : EndIf
  EndIf

  Code + "Open_" + Mid(CodeGadgets(0)\Name,2) + "()" +#CRLF$+#CRLF$

  If CodeCustomAddition
    TmpCode = CustomAddition("CustomAddition_Main")
    If TmpCode <> "" : Code + TmpCode +#CRLF$ : EndIf
  EndIf

  If CodeEventLoop = #False   ;-Include Event Loop
    Code + "Repeat : Until WaitWindowEvent() = #PB_Event_CloseWindow" +#CRLF$
  Else
    Code + "Repeat" +#CRLF$
    Code +INDENT$+ "iEvent = WaitWindowEvent()" +#CRLF$
    Code +INDENT$+ "Select iEvent" +#CRLF$

    CompilerIf #PB_Compiler_OS = #PB_OS_Windows
      If AddPopupMenu
        Code +INDENT$+INDENT$+ "Case #WM_RBUTTONDOWN   ;Windows right click" +#CRLF$
        If CodeConstants = #True
          Code +INDENT$+INDENT$+INDENT$+ "DisplayPopupMenu(#PopupMenu, WindowID(" + WinName+ "))" +#CRLF$+#CRLF$
        Else
          Code +INDENT$+INDENT$+INDENT$+ "DisplayPopupMenu("+ sPreF + "PopupMenu, WindowID(" + WinName+ "))" +#CRLF$+#CRLF$
        EndIf
      EndIf
    CompilerEndIf

    ;- > #PB_Event_Menu
    Code +INDENT$+INDENT$+ "Case #PB_Event_Menu" +#CRLF$
    Code +INDENT$+INDENT$+INDENT$+ "Select EventMenu()" +#CRLF$
    If AddMenu
      CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
        Code +INDENT$+INDENT$+INDENT$+INDENT$+ "Case #PB_Menu_Quit" +#CRLF$
      CompilerElse
        Code +INDENT$+INDENT$+INDENT$+INDENT$+ "Case 3   ;Quit" +#CRLF$
      CompilerEndIf
      Code +INDENT$+INDENT$+INDENT$+INDENT$+INDENT$+ "End" +#CRLF$
    EndIf
    If (AddMenu + AddPopupMenu + AddToolBar) > 0
      CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
        Code +INDENT$+INDENT$+INDENT$+INDENT$+ "Case #PB_Menu_About" +#CRLF$
        Code +INDENT$+INDENT$+INDENT$+INDENT$+INDENT$+ "MessageRequester(" + #DQUOTE$ + "About" + #DQUOTE$ + ", " + #DQUOTE$ + "Menu Sample" + #DQUOTE$ + ", 0)" +#CRLF$
        Code +INDENT$+INDENT$+INDENT$+INDENT$+ "Case #PB_Menu_Preferences" +#CRLF$
        Code +INDENT$+INDENT$+INDENT$+INDENT$+INDENT$+ "MessageRequester(" + #DQUOTE$ + "Preferences" + #DQUOTE$ + ", " + #DQUOTE$ + "Menu Preferences" + #DQUOTE$ + ", 0)" +#CRLF$
      CompilerElse
        Code +INDENT$+INDENT$+INDENT$+INDENT$+ "Case 4   ;About" +#CRLF$
        Code +INDENT$+INDENT$+INDENT$+INDENT$+INDENT$+ "MessageRequester(" + #DQUOTE$ + "About" + #DQUOTE$ + ", " + #DQUOTE$ + "Menu Sample" + #DQUOTE$ + ", 0)" +#CRLF$
      CompilerEndIf
      Code +INDENT$+INDENT$+INDENT$+INDENT$+ "Default" +#CRLF$
      Code +INDENT$+INDENT$+INDENT$+INDENT$+INDENT$+ "MessageRequester(" + #DQUOTE$ + "Information" + #DQUOTE$ + ", " + #DQUOTE$ + "ToolBar Or Menu ID: " + #DQUOTE$ + " + Str(EventMenu()), 0)" +#CRLF$
    EndIf
    Code +INDENT$+INDENT$+INDENT$+ "EndSelect" +#CRLF$+#CRLF$

    ;- > #PB_Event_Gadget
    Code +INDENT$+INDENT$+ "Case #PB_Event_Gadget" +#CRLF$
    Code +INDENT$+INDENT$+INDENT$+ "Select EventGadget()" +#CRLF$
    For I=1 To ArraySize(CodeGadgets())
      With CodeGadgets(I)
        If \Type = 1    ;Button
          If CodeConstants
            Code +INDENT$+INDENT$+INDENT$+INDENT$+ "Case " + Trim(\Name) + "   ;" + Mid(\Caption, 7) + #CRLF$
            Code +INDENT$+INDENT$+INDENT$+INDENT$+INDENT$+ "MessageRequester(" + #DQUOTE$ + "Information" + #DQUOTE$ + ", " + #DQUOTE$ + "Button ID Name : " + Trim(\Name) + #DQUOTE$ + " +#CRLF$+#CRLF$+ " + #DQUOTE$ + "Text : " + Mid(\Caption, 7) +#DQUOTE$ + ")" +#CRLF$
          Else
            Code +INDENT$+INDENT$+INDENT$+INDENT$+ "Case " + Trim(\VName) + "   ;" + Mid(\Caption, 7) + #CRLF$
            Code +INDENT$+INDENT$+INDENT$+INDENT$+INDENT$+ "MessageRequester(" + #DQUOTE$ + "Information" + #DQUOTE$ + ", " + #DQUOTE$ + "Button ID Name : " + Trim(\VName) + #DQUOTE$ + " +#CRLF$+#CRLF$+ " + #DQUOTE$ + "Text : " + Mid(\Caption, 7) +#DQUOTE$ + ")" +#CRLF$
          EndIf
        EndIf
        If \Type = 19   ;Button Image
          If CodeConstants
            Code +INDENT$+INDENT$+INDENT$+INDENT$+ "Case " + Trim(\Name) + "   ;" + Mid(\Caption, 7) + #CRLF$
            Code +INDENT$+INDENT$+INDENT$+INDENT$+INDENT$+ "MessageRequester(" + #DQUOTE$ + "Information" + #DQUOTE$ + ", " + #DQUOTE$ + "Button image ID Name : " + Trim(\Name) + #DQUOTE$ + ")" +#CRLF$
          Else
            Code +INDENT$+INDENT$+INDENT$+INDENT$+ "Case " + Trim(\VName) + "   ;" + Mid(\Caption, 7) + #CRLF$
            Code +INDENT$+INDENT$+INDENT$+INDENT$+INDENT$+ "MessageRequester(" + #DQUOTE$ + "Information" + #DQUOTE$ + ", " + #DQUOTE$ + "Button image ID Name : " + Trim(\VName) + #DQUOTE$ + ")" +#CRLF$
          EndIf
        EndIf
      EndWith
    Next
    Code +INDENT$+INDENT$+INDENT$+ "EndSelect" +#CRLF$+#CRLF$

    Code +INDENT$+INDENT$+ "Case #PB_Event_CloseWindow" +#CRLF$
    Code +INDENT$+INDENT$+INDENT$+ "End" +#CRLF$
    Code +INDENT$+ "EndSelect" +#CRLF$
    Code + "ForEver" +#CRLF$
  EndIf

  If CodeCustomAddition
    TmpCode = CustomAddition("CustomAddition_Exit")
    If TmpCode <> "" : Code +#CRLF$ + TmpCode : EndIf
  EndIf

  FreeArray(CodeGadgets())

  If SaveProgress = #True   ;Save In Progress, On Timer or at the same time as another request
    sFilePath = GetCurrentDirectory() + "SweetyVD_InProgress.pb"
    hFile = CreateFile(#PB_Any, sFilePath)
    If hFile
      WriteStringFormat(hFile, #PB_UTF8)
      WriteStringN(hFile, Code)
      CloseFile(hFile)
    EndIf
    If FileSize(sFilePath) < 1
      MessageRequester("SweetyVD Warning", "Source File Creation Failure Temp\" + GetFilePart(sFilePath), #PB_MessageRequester_Warning|#PB_MessageRequester_Ok)
      ProcedureReturn 1
    EndIf
  EndIf

  ;- Save to Destination
  Select Dest
    Case "Play"
      CompilerIf #PB_Compiler_OS = #PB_OS_Linux
        CompilerPath = GetPathPart(PBIDEpath) + "pbcompiler"
      CompilerElseIf #PB_Compiler_OS = #PB_OS_MacOS   ;Not tested
        CompilerPath = GetPathPart(PBIDEpath) + "pbcompiler.exe"   ;Not tested
      CompilerElse
        CompilerPath = GetPathPart(PBIDEpath) + "Compilers\pbcompiler.exe"
      CompilerEndIf

      If FileSize(CompilerPath)
        sFilePath  = GetTempFilename("~SweetyVD_", 6, ".pb")
        hFile = CreateFile(#PB_Any, sFilePath)
        If hFile
          WriteStringFormat(hFile, #PB_UTF8)
          WriteStringN(hFile, Code)
          CloseFile(hFile)

          SavTitle = GetWindowTitle(#MainWindow)
          SetWindowTitle(#MainWindow, SavTitle + "     *****  Compiling in progress  *****")
          CompilerIf #PB_Compiler_OS = #PB_OS_Linux
            ProgramName = GetFilePart(sFilePath, #PB_FileSystem_NoExtension)
            Compiler = RunProgram(CompilerPath, #DQUOTE$ + sFilePath + #DQUOTE$ + " -e " + #DQUOTE$ + GetPathPart(sFilePath) + ProgramName +#DQUOTE$, "", #PB_Program_Hide | #PB_Program_Open | #PB_Program_Read)
          CompilerElseIf #PB_Compiler_OS = #PB_OS_MacOS   ;Not tested
            ProgramName = GetFilePart(sFilePath, #PB_FileSystem_NoExtension) + ".exe"
            Compiler = RunProgram(CompilerPath, #DQUOTE$ + sFilePath + #DQUOTE$ + " -e " + #DQUOTE$ + GetPathPart(sFilePath) + ProgramName +#DQUOTE$, "", #PB_Program_Hide | #PB_Program_Open | #PB_Program_Read)
          CompilerElse
            ProgramName = GetFilePart(sFilePath, #PB_FileSystem_NoExtension) + ".exe"
            Compiler = RunProgram(CompilerPath, #DQUOTE$ + sFilePath + #DQUOTE$ + " /EXE " + #DQUOTE$ + GetPathPart(sFilePath) + ProgramName +#DQUOTE$ + " /DPIAWARE", "", #PB_Program_Hide | #PB_Program_Open | #PB_Program_Read)
            ;Compiler = RunProgram(CompilerPath, #DQUOTE$ + sFilePath + #DQUOTE$ + " -e " + #DQUOTE$ + GetPathPart(sFilePath) + ProgramName +#DQUOTE$ + " /DPIAWARE", "", #PB_Program_Hide | #PB_Program_Open | #PB_Program_Read)
          CompilerEndIf
          If Compiler
            While ProgramRunning(Compiler)
              If AvailableProgramOutput(Compiler)
                LastProgramString = ReadProgramString(Compiler)
              EndIf
            Wend
            If ProgramExitCode(Compiler) <> 0
              CloseProgram(Compiler)
              MessageRequester("SweetyVD Warning", "Fail to Compile:" +#CRLF$+ "pbcompiler.exe Temp\" + GetFilePart(sFilePath) + " -e Temp\" + ProgramName + #CRLF$+#CRLF$+ LastProgramString, #PB_MessageRequester_Warning|#PB_MessageRequester_Ok)
            Else
              CloseProgram(Compiler)
              If FileSize(GetPathPart(sFilePath) + ProgramName)
                DeleteFile(sFilePath, #PB_FileSystem_Force)
                SetWindowTitle(#MainWindow, SavTitle + "     *****  Close the Play Window to Continue  *****")
                RunProgram(GetPathPart(sFilePath) + ProgramName, "", "", #PB_Program_Wait)
                Delay(250)
                DeleteFile(GetPathPart(sFilePath) + ProgramName, #PB_FileSystem_Force)
              Else
                MessageRequester("SweetyVD Warning", "Fail to Compile:" +#CRLF$+ "pbcompiler.exe Temp\" + GetFilePart(sFilePath) + " -e Temp\" + ProgramName, #PB_MessageRequester_Warning|#PB_MessageRequester_Ok)
              EndIf
            EndIf
          Else
            MessageRequester("SweetyVD Warning", "Fail to Compile:" +#CRLF$+ "pbcompiler.exe Temp\" + GetFilePart(sFilePath) + " -e Temp\" + ProgramName, #PB_MessageRequester_Warning|#PB_MessageRequester_Ok)
          EndIf
          SetWindowTitle(#MainWindow, SavTitle)
        EndIf
      Else
        MessageRequester("SweetyVD Warning", "pbcompiler.exe was Not Found in Compilers Folder", #PB_MessageRequester_Warning|#PB_MessageRequester_Ok)
      EndIf

    Case "NewTab"
      sFilePath  = GetTempFilename("~SweetyVD_", 6, ".pb")
      hFile = CreateFile(#PB_Any, sFilePath)
      If hFile
        WriteStringFormat(hFile, #PB_UTF8)
        WriteStringN(hFile, Code)
        CloseFile(hFile)
        RunProgram(PBIDEpath, #DQUOTE$ + sFilePath + #DQUOTE$, "")
        CompilerIf #PB_Compiler_OS = #PB_OS_Windows
          ShowWindow_(WindowID(#MainWindow), #SW_MINIMIZE)
        CompilerElse
          MessageRequester("SweetyVD Information", "The Created Code is copied to a New Tab  :)", #PB_MessageRequester_Info|#PB_MessageRequester_Ok)
        CompilerEndIf
      Else
        SetClipboardText(Code)
        MessageRequester("SweetyVD Information", "The Created Code is copied to the Clipboard  :)", #PB_MessageRequester_Info|#PB_MessageRequester_Ok)
      EndIf

    Case "Save"
      sFilePath = SaveFileRequester("Save As", "", "PureBasic (*.pb) (*.pbf)|*.pb;*.pbf", 0)
      If sFilePath
        If GetExtensionPart(sFilePath) = "" : sFilePath + ".pb" :EndIf
        hFile = CreateFile(#PB_Any, sFilePath)
        If hFile
          WriteStringFormat(hFile, #PB_UTF8)
          WriteStringN(hFile, Code)
          CloseFile(hFile)
        EndIf
      EndIf

    Case "Clipboard"
      SetClipboardText(Code)   ;Copy the code to the clipboard
      MessageRequester("SweetyVD Information", "The Created Code is copied to the Clipboard  :)", #PB_MessageRequester_Info|#PB_MessageRequester_Ok)
  EndSelect
EndProcedure

Procedure.s CustomAddition(Group.s)
  Protected Code.s, TmpCode.s
  If OpenPreferences("SweetyVD.ini", #PB_Preference_GroupSeparator)
    PreferenceGroup(Group)
    ExaminePreferenceKeys()
    While  NextPreferenceKey()
      If Left(PreferenceKeyName(), 4) = "Line"
        TmpCode = PreferenceKeyValue()
        If Left(TmpCode, 1) = "." : TmpCode = Mid(TmpCode, 2) : EndIf
        If TmpCode <> "" Or Code <> "" : Code + TmpCode +#CRLF$ : EndIf
      EndIf
    Wend
    ClosePreferences()
  EndIf
  ProcedureReturn Code
EndProcedure

; IDE Options = PureBasic 5.71 LTS (Windows - x64)
; Folding = ---
; EnableXP
; Executable = SweetyVD.exe
; EnablePurifier
