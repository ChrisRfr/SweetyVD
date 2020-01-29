Declare AboutForm()
Declare PrefsForm()
Declare PrefsFormFocus()
Declare PrefsFormLostFocus()
Declare SavePrefs()
Declare StartPrefs()
Declare ExitPrefs()

Procedure AboutForm()
  If OpenWindow(#AboutForm, WindowX(#MainWindow)+WindowWidth(#MainWindow)-430-5, WindowY(#MainWindow)+GadgetHeight(#ContainerSetting)+32, 430, 300, "SweetyVD: Licence",#PB_Window_TitleBar)
    StickyWindow(#AboutForm, #True)
    ButtonGadget(#AboutClose, 375, 276, 50, 20, "Close")
    EditorGadget(#Licence, 5, 5, 420, 268, #PB_Editor_ReadOnly)
    SetGadgetColor(#Licence, #PB_Gadget_BackColor,RGB(225,230,235))
    AddGadgetItem(#Licence,-1,"SweetyVD is an Open and Freeware tool and is Free of all Cost.")
    AddGadgetItem(#Licence,-1,"")
    AddGadgetItem(#Licence,-1,"SweetyVD is Licensed under the MIT License")
    AddGadgetItem(#Licence,-1,"")
    AddGadgetItem(#Licence,-1,"A short And simple permissive license With conditions")
    AddGadgetItem(#Licence,-1,"only requiring preservation of copyright And license notices.")
    AddGadgetItem(#Licence,-1,"Licensed works, modifications, And larger works may be distributed")
    AddGadgetItem(#Licence,-1,"under different terms And without source code.")
    AddGadgetItem(#Licence,-1,"")
    AddGadgetItem(#Licence,-1,"-")
    AddGadgetItem(#Licence,-1,"")
    AddGadgetItem(#Licence,-1,"You may use an unlimited number of copies of this tool.")
    AddGadgetItem(#Licence,-1,"")
    AddGadgetItem(#Licence,-1,"You may freely distribute SweetyVD But you can Not sell it.")
    AddGadgetItem(#Licence,-1,"")
    AddGadgetItem(#Licence,-1,"SweetyVD is provided "+#DQUOTE$+"As IS"+#DQUOTE$+" without warranty.")
    AddGadgetItem(#Licence,-1,"The use of the Software is at your own Risk.")
    AddGadgetItem(#Licence,-1,"")
    AddGadgetItem(#Licence,-1,"Thanks to Give Credit Where It's Due.")
    AddGadgetItem(#Licence,-1,Chr(169)+"2020 ChrisR")
  EndIf
EndProcedure

Procedure PrefsForm()
  ContainerGadget(#PrefsForm, WindowWidth(#MainWindow)-220-5, GadgetY(#ContainerSetting)+GadgetHeight(#ContainerSetting), 220, WindowHeight(#MainWindow)-GadgetHeight(#ContainerSetting)-10, #PB_Container_Single)
  TextGadget(#CodeGeneralText, 5, 5, 210, 20, "General")
  SetGadgetFont(#CodeGeneralText, FontID(#FontBWML))
  CheckBoxGadget(#HandlesOnMove, 10, 25, 210, 20, "Display Handles when Moving")
  CheckBoxGadget(#UnselectItemsBorder, 10, 45, 210, 20, "Unselected Items Border")
  TextGadget(#PBPathText, 10, 69, 165, 16, "PureBasic Path")
  StringGadget(#PBPathString, 10, 85, 160, 20, PBIDEpath, #PB_String_ReadOnly)
  ButtonGadget(#PBPathPick, 170, 84, 22, 22, "...")
  CatchImage(#Img_Valid,?Img_Valid)
  CatchImage(#Img_Fail,?Img_Fail)
  ImageGadget(#PBPathImage, 196, 85, 22, 22, 0)
  ButtonGadget(#ExportConfigButton, 10, 115, 200, 20, "Export Model Configuration")
  CheckBoxGadget(#SaveProgress, 10, 143, 128, 20, "Save Code Every")
  StringGadget(#SaveProgressSec, 138, 143, 44, 20, "60", #PB_String_Numeric) : SetGadgetAttribute(#SaveProgressSec, #PB_String_MaximumLength, 4)
  GadgetToolTip(#SaveProgressSec, "Save the Code Every xx Seconds. 10 Seconds at Least.")
  TextGadget(#SaveProgressText, 186, 145, 25, 20, "Sec")
  
  CanvasGadget(#SeparatorPref1, 5, 173, 210, 1, #PB_Canvas_Border) : DisableGadget(#SeparatorPref1, 1)
  If StartDrawing(CanvasOutput(#SeparatorPref1)) : Box(0, 0, OutputWidth(), OutputHeight(), $B0B0B0) : StopDrawing() : EndIf
  TextGadget(#CodeOptionsText, 5, 178, 210, 20, "Code Options")
  SetGadgetFont(#CodeOptionsText, FontID(#FontBWML))
  FrameGadget(#CodeFrameColor, 10, 198, 200, 40, "Color")
  OptionGadget(#CodeColorRGB, 30, 213, 85, 20, "RGB")
  OptionGadget(#CodeColorHex, 130, 213, 70, 20, "$Hex")
  
  FrameGadget(#CodeFramePrePost, 10, 238, 200, 45, "Variable (#PB_Any)")
  TextGadget(#TextGadget_PreFix, 20, 258, 60, 20, "PreFix")
  StringGadget(#StringGadget_PreFix, 80, 258, 40, 20, "i")
  CheckBoxGadget(#CheckBox_Suffix, 130, 258, 60, 20, "Suffix")
  
  FrameGadget(#CodeFrameIndent, 10, 283, 200, 45, "Indentation")
  TextGadget(#Text_SpaceIndent, 20, 305, 60, 20, "Nb Space")
  CompilerIf #PB_Compiler_OS = #PB_OS_Linux
    SpinGadget(#Spin_SpaceIndent, 80, 296, 44, 20, 0, 9, #PB_Spin_Numeric | #PB_Spin_ReadOnly)
  CompilerElse
    SpinGadget(#Spin_SpaceIndent, 80, 303, 44, 20, 0, 9, #PB_Spin_Numeric | #PB_Spin_ReadOnly)
  CompilerEndIf
  CheckBoxGadget(#CheckBox_TabIndent, 130, 303, 60, 20, "#Tab$")
  
  CanvasGadget(#SeparatorPref2, 5, 338, 210, 1, #PB_Canvas_Border) :  DisableGadget(#SeparatorPref2, 1)
  If StartDrawing(CanvasOutput(#SeparatorPref2)) : Box(0, 0, OutputWidth(), OutputHeight(), $B0B0B0) : StopDrawing() : EndIf
  TextGadget(#CodeIncludeText, 5, 343, 210, 20, "Code Include")
  SetGadgetFont(#CodeIncludeText, FontID(#FontBWML))
  CheckBoxGadget(#Code_TitleBlock, 10, 363, 160, 20, "Include Title Block")
  CheckBoxGadget(#CodeEnumeration, 10, 383, 160, 20, "Include Enumeration")
  FrameGadget(#CodeVariable, 10, 408, 200, 40, "Variable")
  OptionGadget(#CodeConstants, 20, 423, 85, 20, "Constants")
  OptionGadget(#CodePBany, 110, 423, 70, 20, "#PB_Any")
  
  CheckBoxGadget(#CodeEventLoop, 10, 453, 160, 20, "Include the Event Loop")
  CheckBoxGadget(#CodeCustomAddition, 10, 473, 160, 20, "Include Custom Addition")
  
  ButtonGadget(#CodePlay, 5, 503, 65, 20, "Play")
  ButtonGadget(#CodeCancel, 75, 503, 105, 20, "Close Setting")
  CatchImage(#Img_About,?Img_About)
  ButtonImageGadget(#AboutButton, 185, 500, 25, 25, ImageID(#Img_About))
  
  ButtonGadget(#CodeNewTab, 5, 533, 65, 20, "New Tab", #PB_Button_Toggle) : SetGadgetState(#CodeNewTab, #True)
  ButtonGadget(#CodeSave, 75, 533, 65, 20, "Save As")
  ButtonGadget(#CodeClipboard, 145, 533, 65, 20, "ClipBoard")
  CloseGadgetList()
  HideGadget(#PrefsForm, #True)
EndProcedure

Procedure PrefsFormFocus()
  Protected I.i, CodeTitleBlock.b = 1, CodeEnumeration.b = 1, Variable.b = 0, CodeEventLoop.b = 1, CodeCustomAddition.b = 0
  Protected Hexa_Color.b = 0, PreFix.s, Suffix.s, Suffix_Enabled.b = 0, Space_Indentation.l = 2, Tab_Indentation = 0
  
  If OpenPreferences("SweetyVD.ini", #PB_Preference_GroupSeparator)
    PreferenceGroup("Designer")
    DisplayHandleCornerOnMove    = ReadPreferenceLong("Display_Handle_Corner_On_Move", DisplayHandleCornerOnMove)
    DisplayUnselectedItemsBorder = ReadPreferenceLong("Display_Unselected_Items_Border", DisplayUnselectedItemsBorder)
    SaveProgress                 = ReadPreferenceLong("Save_Code_Progress", SaveProgress)
    SaveProgressSec              = ReadPreferenceLong("Save_Code_Progress_Sec", SaveProgressSec)
    PreferenceGroup("CodeCreate")
    CodeTitleBlock               = ReadPreferenceLong("Include_TitleBlock", CodeTitleBlock)
    CodeEnumeration              = ReadPreferenceLong("Include_Enumeration", CodeEnumeration)
    Variable                     = ReadPreferenceLong("Variable", Variable)
    CodeEventLoop                = ReadPreferenceLong("Include_EventLoop", CodeEventLoop)
    CodeCustomAddition           = ReadPreferenceLong("Include_CustomAddition", CodeCustomAddition)
    PreferenceGroup("CodeOption")
    Hexa_Color                   = ReadPreferenceLong("Hexa_Color", Hexa_Color)
    PreFix                       = ReadPreferenceString("PreFix", PreFix)
    Suffix                       = ReadPreferenceString("Suffix", Suffix)
    Suffix_Enabled               = ReadPreferenceLong("Suffix_Enabled", Suffix_Enabled)
    Space_Indentation            = ReadPreferenceLong("Space_Indentation", Space_Indentation)
    Tab_Indentation              = ReadPreferenceLong("Tab_Indentation", Tab_Indentation)
    ClosePreferences()
  EndIf
  
  CompilerIf #PB_Compiler_OS <> #PB_OS_Windows   ;Required on Linux and MacOS to keep the mouse focus
    DisplayHandleCornerOnMove = #True
    SetGadgetState(#HandlesOnMove, DisplayHandleCornerOnMove)
    HideGadget(#HandlesOnMove, #True)
  CompilerElse
    SetGadgetState(#HandlesOnMove, DisplayHandleCornerOnMove)
  CompilerEndIf
  
  SetGadgetState(#UnselectItemsBorder, DisplayUnselectedItemsBorder)
  SetGadgetState(#SaveProgress, SaveProgress)
  SetGadgetText(#SaveProgressSec, Str(SaveProgressSec))
  SetGadgetText(#StringGadget_PreFix, PreFix)
  SetGadgetState(#CheckBox_Suffix, Suffix_Enabled)
  SetGadgetState(#Spin_SpaceIndent, Space_Indentation)
  SetGadgetState(#CheckBox_TabIndent, Tab_Indentation)
  
  If Hexa_Color = 0
    SetGadgetState(#CodeColorRGB,#True)
  Else
    SetGadgetState(#CodeColorHex,#True)
  EndIf
  If Variable = 1
    SetGadgetState(#CodePBany,#True)
  Else
    SetGadgetState(#CodeConstants,#True)
  EndIf
  If FileSize(PBIDEpath) > 1
    SetGadgetState(#PBPathImage, ImageID(#Img_Valid))
  Else
    SetGadgetState(#PBPathImage, ImageID(#Img_Fail))
  EndIf
  
  SetGadgetState(#Code_TitleBlock, CodeTitleBlock)
  SetGadgetState(#CodeEnumeration, CodeEnumeration)
  SetGadgetState(#CodeEventLoop, CodeEventLoop)
  SetGadgetState(#CodeCustomAddition, CodeCustomAddition)
  HideGadget(#PrefsForm, #False)   ;On Linux with PB 5.61, the Gadget must be Visible to get GadgetWidth() or GadgetX()   
  
  ResizeGadget(#ScrollDrawArea, #PB_Ignore, #PB_Ignore, GadgetWidth(#ScrollDrawArea)-GadgetWidth(#PrefsForm)-5, #PB_Ignore)
  ResizePaintAllGadgetAndDragHandle()
  ResizePaintHandleCorner()
  ResizeGadget(#PrefsForm, WindowWidth(#MainWindow)-GadgetWidth(#PrefsForm)-5, #PB_Ignore, #PB_Ignore, WindowHeight(#MainWindow)-GadgetHeight(#ContainerSetting)-10)
  
  AddKeyboardShortcut(#MainWindow, #PB_Shortcut_Escape, #Shortcut_Escape)
  MonitorPrefsFormFocus = #True
EndProcedure

Procedure PrefsFormLostFocus()
  MonitorPrefsFormFocus = #False
  RemoveKeyboardShortcut(#MainWindow, #PB_Shortcut_Escape)
  SavePrefs()
  ResizeGadget(#ScrollDrawArea, #PB_Ignore, #PB_Ignore, GadgetWidth(#ScrollDrawArea)+GadgetWidth(#PrefsForm)+5, #PB_Ignore)
  ResizePaintAllGadgetAndDragHandle()
  ResizePaintHandleCorner()
  HideGadget(#PrefsForm, #True)
  SetGadgetState(#SVDSetting, 0)
EndProcedure

Procedure StartPrefs()
  Global Designer_Width.i = 960
  Global Designer_Height.i = 620
  UserScreen_Width.i = 640
  UserScreen_Height.i = 480
  ShowGrid = #True
  GridSize = 10
  SnapGrid = #True
  
  CompilerIf #PB_Compiler_OS <> #PB_OS_Windows   ;Required on Linux and MacOS to keep the mouse focus
    DisplayHandleCornerOnMove = #True
  CompilerElse 
    DisplayHandleCornerOnMove = #False   ;Default Value. Decreases a bit the blinking, it can be changed under windows
  CompilerEndIf
  
  DrawDragHandleBorderOnGridArea = #False  
  DisplayUnselectedItemsBorder = #True
  PBIDEpath = GetPBIDE()
  If FileSize(PBIDEpath) < 1 : PBIDEpath = "" : EndIf
  SaveProgress                   = #False
  SaveProgressSec                = 60
  
  If OpenPreferences("SweetyVD.ini", #PB_Preference_GroupSeparator) = 0   ;Create Default SweetyVD.ini setting
                                                                          ;Canvas_Size_X = 1600  not working
    CreatePreferences("SweetyVD.ini", #PB_Preference_GroupSeparator)
    PreferenceComment("The size of the drawing area (OpenWindow) is defined in the Gadget templates: SweetyVD.json file")
    ;PreferenceComment("SaveOnExit Save Designer_Width, Designer_Height, Designer_Maximize, Drag_Space, Show_Grid and Grid_Size on Exit")
    ;PreferenceComment("Boolean value 0/1: SaveOnExit, Designer_Maximize, Show_Grid, Include_TitleBlock, Include_Enumeration, Variable, Add_StatusBar, Include_EventLoop")
    PreferenceComment("")
    PreferenceGroup("Designer")
    WritePreferenceLong("SaveOnExit", 1)
    WritePreferenceLong("Designer_Width", Designer_Width)
    WritePreferenceLong("Designer_Height", Designer_Height)
    WritePreferenceLong("UserScreen_Width", UserScreen_Width)
    WritePreferenceLong("UserScreen_Height", UserScreen_Height)
    WritePreferenceLong("Designer_Maximize", 1)
    WritePreferenceLong("ScrollArea_MaxWidth", 1920)
    WritePreferenceLong("ScrollArea_MaxHeight", 1020)
    WritePreferenceLong("Show_Grid", ShowGrid)
    WritePreferenceLong("Grid_Size", GridSize)
    WritePreferenceLong("Snap_Grid", SnapGrid)
    ;
    WritePreferenceLong("Draw_DragHandle_Border_On_Grid_Area", DrawDragHandleBorderOnGridArea)
    WritePreferenceLong("Display_Handle_Corner_On_Move", DisplayHandleCornerOnMove)
    WritePreferenceLong("Display_Unselected_Items_Border", DisplayUnselectedItemsBorder)
    WritePreferenceString("PureBasic_Path", PBIDEpath)
    WritePreferenceLong("Save_Code_Progress", SaveProgress)
    WritePreferenceLong("Save_Code_Progress_Sec", SaveProgressSec)
    ;Init Code Create Window
    PreferenceGroup("CodeCreate")
    WritePreferenceLong("Include_TitleBlock", 1)
    WritePreferenceLong("Include_Enumeration", 1)
    WritePreferenceLong("Variable", 0)
    WritePreferenceLong("Include_EventLoop", 1)
    WritePreferenceLong("Include_CustomAddition", 0)
    PreferenceGroup("CodeOption")
    WritePreferenceLong("Hexa_Color", 0)
    PreferenceComment("Pre/Post fixes for Variables")
    WritePreferenceString("PreFix", "i")
    WritePreferenceString("Suffix", ".i")
    WritePreferenceLong("Suffix_Enabled", 1)
    WritePreferenceLong("Space_Indentation", 2)
    WritePreferenceLong("Tab_Indentation", 0)
    ;Default Title Block
    PreferenceGroup("TitleBlock")
    PreferenceComment("Use FormatDate (%yyyy, %yy, %mm, %dd + Separator) to format the current date, variable: %Date%")
    PreferenceComment("The Key name must start with " + #DQUOTE$ +"Line" + #DQUOTE$)
    WritePreferenceString("FormatDate", "%yyyy-%mm-%dd")
    WritePreferenceString("Line01", "; -----------------------------------------------------------------------------")
    WritePreferenceString("Line02", ";           Name:")
    WritePreferenceString("Line03", ";    Description:")
    WritePreferenceString("Line04", ";         Author:")
    WritePreferenceString("Line05", ";           Date: %Date%")
    WritePreferenceString("Line06", ";        Version:")
    WritePreferenceString("Line07", ";     PB-Version:")
    WritePreferenceString("Line08", ";             OS:")
    WritePreferenceString("Line09", ";         Credit:")
    WritePreferenceString("Line10", ";          Forum:")
    WritePreferenceString("Line11", ";     Created by: SweetyVD")
    WritePreferenceString("Line12", "; -----------------------------------------------------------------------------")
    ;Include Custom Addition
    PreferenceGroup("CustomAddition")
    PreferenceComment("Include a dot " + #DQUOTE$ + "." + #DQUOTE$ + " as first character To include spaces at the beginning of a Line (eg: indentation)")
    PreferenceComment("The Key name must start With " + #DQUOTE$ + "Line" + #DQUOTE$)
    PreferenceGroup("CustomAddition_Include")
    WritePreferenceString("Line01", "")
    PreferenceGroup("CustomAddition_Constante")
    WritePreferenceString("Line01", "")
    PreferenceGroup("CustomAddition_Structure")
    WritePreferenceString("Line01", "")
    PreferenceGroup("CustomAddition_Variable")
    WritePreferenceString("Line01", "")
    PreferenceGroup("CustomAddition_Declare")
    WritePreferenceString("Line01", "")
    PreferenceGroup("CustomAddition_Procedure")
    WritePreferenceString("Line01", "")
    PreferenceGroup("CustomAddition_Init")
    WritePreferenceString("Line01", "")
    PreferenceGroup("CustomAddition_Main")
    WritePreferenceString("Line01", "")
    PreferenceGroup("CustomAddition_Exit")
    WritePreferenceString("Line01", "")
    ClosePreferences()
  Else   ;Read Global variables
    PreferenceGroup("Designer")
    Designer_Width                 = ReadPreferenceLong("Designer_Width", Designer_Width) ; default values
    Designer_Height                = ReadPreferenceLong("Designer_Height", Designer_Height)
    UserScreen_Width               = ReadPreferenceLong("UserScreen_Width", UserScreen_Width)
    UserScreen_Height              = ReadPreferenceLong("UserScreen_Height", UserScreen_Height)
    ShowGrid                       = ReadPreferenceLong("Show_Grid", ShowGrid)
    GridSize                       = ReadPreferenceLong("Grid_Size", GridSize)
    SnapGrid                       = ReadPreferenceLong("Snap_Grid", SnapGrid)
    DrawDragHandleBorderOnGridArea = ReadPreferenceLong("Draw_DragHandle_Border_On_Grid_Area", DrawDragHandleBorderOnGridArea)
    DisplayHandleCornerOnMove      = ReadPreferenceLong("Display_Handle_Corner_On_Move", DisplayHandleCornerOnMove) 
    DisplayUnselectedItemsBorder   = ReadPreferenceLong("Display_Unselected_Items_Border", DisplayUnselectedItemsBorder)
    SaveProgress                   = ReadPreferenceLong("Save_Code_Progress", SaveProgress)
    SaveProgressSec                = ReadPreferenceLong("Save_Code_Progress_Sec", SaveProgressSec)
    PBIDEpath                      = ReadPreferenceString("PureBasic_Path", PBIDEpath)
    
    CompilerIf #PB_Compiler_OS <> #PB_OS_Windows   ;Required on Linux and MacOS to keep the mouse focus
      DisplayHandleCornerOnMove = #True
    CompilerEndIf
    
    If FileSize(PBIDEpath) < 1
      PBIDEpath = GetPBIDE()
      If FileSize(PBIDEpath) < 1 : PBIDEpath = "" : EndIf
      WritePreferenceString("PureBasic_Path", PBIDEpath)
    EndIf
    ClosePreferences()
  EndIf
EndProcedure

Procedure SavePrefs()
  CompilerIf #PB_Compiler_OS <> #PB_OS_Windows   ;To be sure. Required on Linux and MacOS to keep the mouse focus
    DisplayHandleCornerOnMove = #True
  CompilerEndIf
  ;Save Preference
  If OpenPreferences("SweetyVD.ini", #PB_Preference_GroupSeparator)
    PreferenceGroup("Designer")
    WritePreferenceLong("Display_Handle_Corner_On_Move", DisplayHandleCornerOnMove)
    WritePreferenceLong("Display_Unselected_Items_Border", DisplayUnselectedItemsBorder)
    If FileSize(PBIDEpath) < 1 : PBIDEpath = "" : EndIf
    WritePreferenceString("PureBasic_Path", PBIDEpath)
    WritePreferenceLong("Save_Code_Progress", SaveProgress)
    WritePreferenceLong("Save_Code_Progress_Sec", SaveProgressSec)
    PreferenceGroup("CodeCreate")
    WritePreferenceLong("Include_TitleBlock", GetGadgetState(#Code_TitleBlock))
    WritePreferenceLong("Include_Enumeration", GetGadgetState(#CodeEnumeration))
    WritePreferenceLong("Variable", GetGadgetState(#CodePBany))
    WritePreferenceLong("Include_EventLoop", GetGadgetState(#CodeEventLoop))
    WritePreferenceLong("Include_CustomAddition", GetGadgetState(#CodeCustomAddition))
    PreferenceGroup("CodeOption")
    WritePreferenceLong("Hexa_Color", GetGadgetState(#CodeColorHex))
    WritePreferenceString("PreFix", GetGadgetText(#StringGadget_PreFix))
    ;WritePreferenceString("Suffix", Suffix)
    WritePreferenceLong("Suffix_Enabled", GetGadgetState(#CheckBox_Suffix))
    WritePreferenceLong("Space_Indentation", GetGadgetState(#Spin_SpaceIndent))
    WritePreferenceLong("Tab_Indentation", GetGadgetState(#CheckBox_TabIndent))
    ClosePreferences()
  EndIf
EndProcedure

Procedure ExitPrefs()
  Protected Designer_Maximize.b
  CompilerIf #PB_Compiler_OS <> #PB_OS_Windows   ;To be sure. Required on Linux and MacOS to keep the mouse focus
    DisplayHandleCornerOnMove = #True
  CompilerEndIf
  
  If OpenPreferences("SweetyVD.ini", #PB_Preference_GroupSeparator) = 0 : StartPrefs() : EndIf
  If GetWindowState(#MainWindow) = #PB_Window_Maximize : Designer_Maximize = #True : EndIf
  If OpenPreferences("SweetyVD.ini", #PB_Preference_GroupSeparator)
    PreferenceGroup("Designer")
    If ReadPreferenceLong("SaveOnExit", 1) = 1
      WritePreferenceLong("Designer_Width", Designer_Width)
      WritePreferenceLong("Designer_Height", Designer_Height)
      WritePreferenceLong("Designer_Maximize", Designer_Maximize)
      WritePreferenceLong("UserScreen_Width", SetDrawWidth)
      WritePreferenceLong("UserScreen_Height", SetDrawHeight)
      WritePreferenceLong("Show_Grid", GetGadgetState(#ShowGrid))
      WritePreferenceLong("Grid_Size", GetGadgetState(#GridSize))
      WritePreferenceLong("Snap_Grid", GetGadgetState(#SnapGrid))
      WritePreferenceLong("Draw_DragHandle_Border_On_Grid_Area", DrawDragHandleBorderOnGridArea)
      WritePreferenceLong("Display_Handle_Corner_On_Move", DisplayHandleCornerOnMove)
      WritePreferenceLong("Display_Unselected_Items_Border", DisplayUnselectedItemsBorder)
      If FileSize(PBIDEpath) < 1 : PBIDEpath = "" : EndIf
      WritePreferenceString("PureBasic_Path", PBIDEpath)
      WritePreferenceLong("Save_Code_Progress", SaveProgress)
      WritePreferenceLong("Save_Code_Progress_Sec", SaveProgressSec)
      ClosePreferences()
    EndIf
  EndIf
EndProcedure
; IDE Options = PureBasic 5.71 LTS (Windows - x64)
; Folding = ---
; EnableXP