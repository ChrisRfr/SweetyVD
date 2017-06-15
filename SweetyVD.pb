; ---------------------------------------------------------------------------------------
;           Name: SweetyVD
;    Description: Sweety Visual Designer
;     dependency: SweetyVDmodule.pbi (Sweety Visual Designer Module)
;         Author: ChrisR
;           Date: 2017-05-25
;        Version: 1.9.5.1
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
; Note Linux: In order to use the WebGadget you have to utilize WebKitGTK
;   See Shardik's post http://www.purebasic.fr/english/viewtopic.php?f=15&t=54049
;   To install the Gtk3 libraries on Debian/Ubuntu: sudo apt-get install libwebkitgtk-3.0-0
; ---------------------------------------------------------------------------------------

CompilerIf #PB_Compiler_IsMainFile
  EnableExplicit

  #BuildVersion = "1.9.5.1"

  ;Import internal function
  CompilerSelect #PB_Compiler_OS
  CompilerCase #PB_OS_Windows
      #PB_IDE = "purebasic.exe"   ;File name relative to #PB_Compiler_Home
      #PB_MessageRequester_Error=16
      #PB_MessageRequester_Warning=48
      #PB_MessageRequester_Info=64
      Import ""
  CompilerCase #PB_OS_Linux
      #PB_IDE = "compilers/purebasic"
      CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
        ImportC "/usr/lib/i386-linux-gnu/libwebkitgtk-3.0.so.0"   ;Ubuntu/Kubuntu/Xubuntu x86 with GTK3
      CompilerElse
        ImportC "/usr/lib/x86_64-linux-gnu/libwebkitgtk-3.0.so.0" ;Ubuntu/Kubuntu/Xubuntu x64 with GTK3
      CompilerEndIf
  CompilerCase #PB_OS_MacOS
      #PB_IDE = "PureBasic.app"
      ImportC ""
  CompilerEndSelect
  PB_Object_EnumerateStart( PB_Objects )
  PB_Object_EnumerateNext( PB_Objects, *ID.Integer )
  PB_Object_EnumerateAbort( PB_Objects )
  PB_Object_GetObject( PB_Object , DynamicOrArrayID)
  PB_Window_Objects.i
  PB_Gadget_Objects.i
EndImport

;Dependency: SweetyVDmodule.pbi (Sweety Visual Designer Module)
XIncludeFile "SweetyVDmodule.pbi"
UseModule SVDesigner

IncludePath "Include"
XIncludeFile "LoadFontWML.pb"
XIncludeFile "GetPBIDE.pb"
XIncludeFile "GetTempFilename.pb"
XIncludeFile "DelOldFiles.pb"
XIncludeFile "TabBarGadget.pbi"
CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  XIncludeFile "FullColorRequester.pb"
CompilerEndIf

Enumeration
  #MainWindow
  #TimerId
  #PopUpMenu
  #EnableSVD
  #CodeCreate
  #SettingContainer
  #SetDrawSizeText
  #SetDrawWidth
  #SetDrawSizeTextX
  #SetDrawHeight
  #DragText
  #DragSpace
  #ShowGrid
  #GridSize
  #AddMenu
  #AddPopupMenu
  #AddToolBar
  #AddStatusBar
  #GadgetList
  #ListGadgets
  #RenameGadgetButton
  #DeleteGadgetButton
  #HideGadget
  #LockGadget
  #DisableGadget
  #PosGadgetX
  #PosGadgetY
  #PosGadgetWidth
  #PosGadgetHeight
  #ParentText
  #ParentString
  #ParentPick
  ;Properties
  #PanelControls
  #TreeControls
  #CreateControlsList
  #PropertiesContainer
  #CaptionText
  #CaptionString
  #ToolTipText
  #ToolTipString
  #MiniText
  #MiniString
  #MaxiText
  #MaxiString
  #ImageText
  #ImageString
  #ImagePick
  #FontText
  #FontString
  #FontPick
  #FrontColorText
  #FrontColorPick
  #FrontColorImg
  #BackColorText
  #BackColorPick
  #BackColorImg
  #Constants
  ;Code Generator Windows
  #CodeForm
  #CodeNewTab
  #CodeSave
  #CodeClipboard
  #CodeCancel
  #Code_TitleBlock
  #CodeEnumeration
  #CodeVariable
  #CodeConstants
  #CodePBany
  #FrameAdd
  #CodeEventLoop
  #CodeSeparator
  #CodeCustomAddition
  #CodeFrameOption
  #CodeFrameColor
  #CodeColorRGB
  #CodeColorHex
  #CodeFramePrePost
  #TextGadget_PreFix
  #StringGadget_PreFix
  #CheckBox_Suffix
  #CodeFrameIndent
  #Text_SpaceIndent
  #Spin_SpaceIndent
  #CheckBox_TabIndent
  #AboutButton
  #AboutForm
  #AboutBack
  #Licence
  ;Rename Gadget Form
  #RenameGadgetWindow
  #RenameGadgetSharp
  #RenameGadgetString
  #RenameGadgetMsg
  #RenameGadgetOK
  #RenameGadgetCancel
  #Shortcut_Escape
  #Shortcut_Return
  ;Others
  #Shortcut_Insert
  #WinBarHeight
  ;JSON Gadget templates file
  #JSONFile
EndEnumeration

Enumeration FormImage
  #Vd_Unknow
  #Img_Rename
  #Img_Delete
  #Img_About
EndEnumeration

#CountModelGadget = 32

Structure GadgetCtrl
  GadgetCtrlImage.i
  GadgetCtrlName.s
EndStructure
Global Dim GadgetCtrlArray.GadgetCtrl(0)

Structure ImageBtnPath
  ImageBtn.i
  ImagePath.s
EndStructure
Global NewList ImageBtnPathArray.ImageBtnPath()

Structure FontStruct
  FontID.i
  FontName.s
  FontSize.i
  FontStyle.i
EndStructure
Global NewList FontStructArray.FontStruct()

Structure ModelGadgetProperty   ;Structure Gadget templates from Data Section
  Model.s                       ;Gadget Model (ButtonGadget, TextGadget ........)
  Order.i                       ;Tri
  Type.i                        ;GadgetType
  DftWidth.i                    ;Default Width
  DftHeight.i                   ;Default Height
  Name.s                        ;Name
  Caption.s                     ;Caption, blank or content
  Option1.s                     ;Option1
  Option2.s                     ;Option2
  Option3.s                     ;Option2
  FrontColor.s                  ;FrontColor
  BackColor.s                   ;FrontColor
  ToolTip.s                     ;ToolTip
  Image.i                       ;Image
  Constants.s                   ;Available Constants (Ex: "#PB_Text_Center,#PB_Text_Right,#PB_Text_Border")
  CustomIncludeFile.s           ;Custom IncludeFile
  CountGadget.i                 ;Gadget Counter by Model
EndStructure
Global Dim ModelGadget.ModelGadgetProperty(0)

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

Global CountImageBtn.i, CountFontID.i, IdDrawGadgets.i = 1000000000
Global X.i, Y.i

Declare StartPrefs()
Declare ExitPrefs()
Declare LoadControls()
Declare InitModelWindow()
Declare InitModelgadget()
Declare InitJSONModelGadget()
Declare SaveJSONModelGadget()
Declare RenameGadgetForm(IdGadget.i)
Declare RenameGadget(IdGadget.i)
Declare CreateGadgets(Model.s)
Declare InitWindowSelected()
Declare InitProperties()
Declare LoadGadgetProperties(IdGadget.i)
Declare RemoveFont(FontID.i)
Declare SelectFont(IdGadget.i)
Declare RemoveImage(sImagePath.s)
Declare DrawSelectedImage(IdGadget.i)
Declare ResizeDrawArea(Width.i, Height.i)
Declare WindowSize()
Declare OpenMainWindow(Designer_Width,Designer_Height, X = 0, Y = 0)
Declare Init()
Declare Exit()

UsePNGImageDecoder()
UseJPEGImageDecoder()
;Code Create Form and Code creation
XIncludeFile "CodeCreate.pb"

Procedure StartPrefs()
  Global Designer_Width.i = 1000
  Global Designer_Height.i = 660
  UserScreen_Width.i = 640
  UserScreen_Height.i = 480
  DragSpace = 10
  ShowGrid = #True
  GridSize = 20
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
    WritePreferenceLong("Designer_Maximize", 0)
    WritePreferenceLong("ScrollArea_MaxWidth", 1920)
    WritePreferenceLong("ScrollArea_MaxHeight", 1020)
    WritePreferenceLong("Drag_Space", DragSpace)
    WritePreferenceLong("Show_Grid", ShowGrid)
    WritePreferenceLong("Grid_Size", GridSize)
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
    Designer_Width     = ReadPreferenceLong("Designer_Width", Designer_Width) ; default values
    Designer_Height    = ReadPreferenceLong("Designer_Height", Designer_Height)
    UserScreen_Width    = ReadPreferenceLong("UserScreen_Width", UserScreen_Width)
    UserScreen_Height   = ReadPreferenceLong("UserScreen_Height", UserScreen_Height)
    DragSpace          = ReadPreferenceLong("Drag_Space", DragSpace)
    ShowGrid           = ReadPreferenceLong("Show_Grid", ShowGrid)
    GridSize           = ReadPreferenceLong("Grid_Size", GridSize)
    ClosePreferences()
  EndIf
EndProcedure

Procedure ExitPrefs()
  Protected Designer_Maximize.b
  If OpenPreferences("SweetyVD.ini", #PB_Preference_GroupSeparator) = 0 : StartPrefs() : EndIf
  If GetWindowState(#MainWindow) = #PB_Window_Maximize : Designer_Maximize = #True : EndIf
  If OpenPreferences("SweetyVD.ini", #PB_Preference_GroupSeparator)
    PreferenceGroup("Designer")
    If ReadPreferenceLong("SaveOnExit", 1) = 1
      WritePreferenceLong("Designer_Width", Designer_Width)
      WritePreferenceLong("Designer_Height", Designer_Height)
      WritePreferenceLong("Designer_Maximize", Designer_Maximize)
      WritePreferenceLong("UserScreen_Width", GetGadgetState(#SetDrawWidth))
      WritePreferenceLong("UserScreen_Height", GetGadgetState(#SetDrawHeight))
      WritePreferenceLong("Drag_Space", GetGadgetState(#DragSpace))
      WritePreferenceLong("Show_Grid", GetGadgetState(#ShowGrid))
      WritePreferenceLong("Grid_Size", GetGadgetState(#GridSize))
      ClosePreferences()
    EndIf
  EndIf
EndProcedure

Procedure LoadControls()
  Protected ZipFile.i, GadgetName.s, GadgetImageSize.i, *GadgetImage, GadgetImage, GadgetCtrlCount.l
  Define ZipFileTheme.s = GetCurrentDirectory()+"SilkTheme.zip"
  If FileSize(ZipFileTheme) < 1
    CompilerIf #PB_Compiler_OS = #PB_OS_Windows
      ZipFileTheme = #PB_Compiler_Home+"themes\SilkTheme.zip"
    CompilerElse
      ZipFileTheme = #PB_Compiler_Home+"themes/SilkTheme.zip"
    CompilerEndIf
    If FileSize(ZipFileTheme) < 1
      MessageRequester("SweetyVD Error", "SilkTheme.zip Not found in the current directory" +#CRLF$+ "Or in PB_Compiler_Home\themes directory" +#CRLF$+#CRLF$+ "Exit now", #PB_MessageRequester_Error|#PB_MessageRequester_Ok)
      End
    EndIf
  EndIf
  CompilerIf #PB_Compiler_Version > 522
    UseZipPacker()
  CompilerEndIf

  GadgetImage = CatchImage(#PB_Any,?Vd_Unknow)
  GadgetCtrlArray(GadgetCtrlCount)\GadgetCtrlImage=GadgetImage
  GadgetCtrlArray(GadgetCtrlCount)\GadgetCtrlName="Unknow"

  ZipFile = OpenPack(#PB_Any, ZipFileTheme, #PB_PackerPlugin_Zip)
  If ZipFile
    If ExaminePack(ZipFile)
      While NextPackEntry(ZipFile)

        GadgetName = PackEntryName(ZipFile)
        GadgetName = ReplaceString(GadgetName,"chart_bar","vd_tabbargadget")   ;use chart_bar png for TabBarGadget
        GadgetName = ReplaceString(GadgetName,"page_white_edit","vd_scintillagadget")   ;vd_scintillagadget.png not found. Use page_white_edit.png instead
        GadgetName = ReplaceString(GadgetName,"frame3dgadget","framegadget")            ;vd_framegadget.png not found. Use vd_frame3dgadget.png instead
        If FindString(Left(GadgetName, 3), "vd_")
          GadgetImageSize = PackEntrySize(ZipFile)
          *GadgetImage = AllocateMemory(GadgetImageSize)
          UncompressPackMemory(ZipFile, *GadgetImage, GadgetImageSize)
          GadgetImage = CatchImage(#PB_Any, *GadgetImage, GadgetImageSize)
          GadgetName = LCase(GadgetName)
          GadgetName = ReplaceString(GadgetName,".png","")
          GadgetName = ReplaceString(GadgetName,"vd_","")

          Select PackEntryType(ZipFile)
            Case #PB_Packer_File
              If GadgetImage
                GadgetCtrlCount + 1
                ReDim GadgetCtrlArray(GadgetCtrlCount)
                GadgetCtrlArray(GadgetCtrlCount)\GadgetCtrlImage=GadgetImage
                GadgetCtrlArray(GadgetCtrlCount)\GadgetCtrlName=GadgetName
              EndIf
          EndSelect

          FreeMemory(*GadgetImage)
        EndIf
      Wend
    EndIf
    ClosePack(ZipFile)
  EndIf
EndProcedure

Procedure InitModelWindow()   ;Initializing Window Templates
  Protected I.i
  For I=0 To ArraySize(ModelGadget())
    If ModelGadget(I)\Type = 0   ;OpenWindow
      With ModelGadget(I)
        ;Draw Area Width and Height with associated Spin Gadgets
        \DftWidth = UserScreen_Width
        \DftHeight = UserScreen_Height
        SetGadgetState(#PosGadgetWidth, \DftWidth)
        SetGadgetState(#PosGadgetHeight, \DftHeight)
        SetGadgetState(#SetDrawWidth, \DftWidth)
        SetGadgetState(#SetDrawHeight,  \DftHeight)
        ;DrawArea Size max Width and max Height
        DrawAreaSize(\DftWidth, \DftHeight)
        ;Save window information in the gadget List. Element 0
        AddMapElement(SVDListGadget(), Str(#MainWindow))
        SVDListGadget()\Gadget=#MainWindow
        SVDListGadget()\Model="OpenWindow"
        SVDListGadget()\Type=0
        SVDListGadget()\Name="#"+\Name+"_0"
        If Mid(\Caption, 7) <> ""   ;"#Text:blabla"
          SVDListGadget()\Caption=\Caption
        Else
          SVDListGadget()\Caption="#Text:" + \Name+"_0"
        EndIf
        SVDListGadget()\Option1=\Option1
        SVDListGadget()\Option2=\Option2
        SVDListGadget()\Option3=\Option3
        SVDListGadget()\FrontColor=\FrontColor
        SVDListGadget()\BackColor=\BackColor
        SVDListGadget()\ToolTip=\ToolTip
        SVDListGadget()\Constants=\Constants
        SVDListGadget()\ModelType=0
        ;Add Window to List Gadgets ComboBox. Element 0 for the Window Draw Area
        AddGadgetItem(#ListGadgets, -1, SVDListGadget()\Name)
        SetGadgetState(#ListGadgets, 0)
        SetGadgetItemData(#ListGadgets, 0, 0)

        AddGadgetItem(#TreeControls, -1, SVDListGadget()\Name, ImageID(\Image), 0)
        SetGadgetState(#TreeControls, 0)
        SetGadgetItemData(#TreeControls, 0, 0)
      EndWith
      Break
    EndIf
  Next

EndProcedure

Procedure InitModelgadget()   ;Initializing Gadget Templates
  Protected Buffer.s, GadgetCtrlFound.b, I.i, J.i
  Restore ModelGadgets
  ReDim ModelGadget(#CountModelGadget)
  For I=0 To #CountModelGadget
    With ModelGadget(I)
      For J=1 To 14
        Read.s Buffer
        Select J
          Case 1  : \Model=Buffer
          Case 2  : \Order=Val(Buffer)
          Case 3  : \Type=Val(Buffer)
          Case 4  : \DftWidth=Val(Buffer)
          Case 5  : \DftHeight=Val(Buffer)
          Case 6  : \Name=Buffer
          Case 7  : \Caption=Buffer
          Case 8  : \Option1=Buffer
          Case 9  : \Option2=Buffer
          Case 10 : \Option3=Buffer
          Case 11 : \FrontColor=Buffer
          Case 12 : \BackColor=Buffer
          Case 13 : \ToolTip=Buffer
          Case 14 : \Constants=Buffer
        EndSelect
      Next
    Next
  EndWith
  ;JSON file Gadget sorted by Order (could be by Gadget Name or by Gadget type)
  SortStructuredArray(ModelGadget(), #PB_Sort_Ascending, OffsetOf(ModelGadgetProperty\Order), TypeOf(ModelGadgetProperty\Order))
  ;SortStructuredArray(ModelGadget(), #PB_Sort_Ascending, OffsetOf(ModelGadgetProperty\Model), TypeOf(ModelGadgetProperty\Model))
  ;SortStructuredArray(ModelGadget(), #PB_Sort_Ascending, OffsetOf(ModelGadgetProperty\Type), TypeOf(ModelGadgetProperty\Type))
  SaveJSONModelGadget()
  For I=0 To #CountModelGadget
    With ModelGadget(I)
      Select \Type
        Case 0        ;OpenWindow
          \Image=CatchImage(#PB_Any,?Vd_Window)
          InitModelWindow()   ;Draw Area Width and Height and Save Window information
        Case 50               ;Custom Gadget
          \Image=CatchImage(#PB_Any,?Vd_Custom)
          AddGadgetItem(#CreateControlsList, -1, \Model, ImageID(\Image))
          MenuItem(I, \Model, ImageID(\Image))   ;Add to popup menu
        Default
          GadgetCtrlFound = #False
          For J = 1 To ArraySize(GadgetCtrlArray())   ;Load Popup Menu Image and ListIcon Controls Gadgets with Image
            If GadgetCtrlArray(J)\GadgetCtrlName = LCase(\Model)
              GadgetCtrlFound = #True
              \Image=GadgetCtrlArray(J)\GadgetCtrlImage
              AddGadgetItem(#CreateControlsList, -1, \Model, ImageID(\Image))
              MenuItem(I, \Model, ImageID(\Image))   ;Add to popup menu
            EndIf
          Next
          If GadgetCtrlFound = #False   ;If image not found, use Vd_Unknow.png
            \Image=GadgetCtrlArray(0)\GadgetCtrlImage
            AddGadgetItem(#CreateControlsList, -1, \Model, ImageID(\Image))
            MenuItem(I, \Model, ImageID(\Image))   ;Add to popup menu
          EndIf
      EndSelect
    Next
  EndWith
EndProcedure

Procedure InitJSONModelGadget()
  Protected GadgetCtrlFound.b, I.i, J.i
  If CreateJSON(#JSONFile)
    LoadJSON(#JSONFile, "SweetyVD.json")
    ExtractJSONArray(JSONValue(#JSONFile), ModelGadget())
    ; Load Image from GadgetCtrlArray and load Popup Menu Image and ListIcon Controls Gadgets
    For I=0 To ArraySize(ModelGadget())
      With ModelGadget(I)
        Select \Type
          Case 0
            \Image=CatchImage(#PB_Any,?Vd_Window)
            InitModelWindow()   ;Draw Area Width and Height and Save Window information
          Case 50               ;Custom Gadget
            \Image=CatchImage(#PB_Any,?Vd_Custom)
            AddGadgetItem(#CreateControlsList, -1, \Model, ImageID(\Image))
            MenuItem(I, \Model, ImageID(\Image))   ;Add to popup menu
          Default
            GadgetCtrlFound = #False
            For J = 1 To ArraySize(GadgetCtrlArray())   ;Load Popup Menu Image and ListIcon Controls Gadgets with Image
              If GadgetCtrlArray(J)\GadgetCtrlName = LCase(\Model)
                GadgetCtrlFound = #True
                \Image=GadgetCtrlArray(J)\GadgetCtrlImage
                AddGadgetItem(#CreateControlsList, -1, \Model, ImageID(\Image))
                MenuItem(I, \Model, ImageID(\Image))   ;Add to popup menu
              EndIf
            Next
            If GadgetCtrlFound = #False   ;If image not found, use Vd_Unknow.png
              \Image=GadgetCtrlArray(0)\GadgetCtrlImage
              AddGadgetItem(#CreateControlsList, -1, \Model, ImageID(\Image))
              MenuItem(I, \Model, ImageID(\Image))   ;Add to popup menu
            EndIf
        EndSelect
      Next
    EndWith
  EndIf
EndProcedure

Procedure SaveJSONModelGadget()
  CreateJSON(#JSONFile)   ;Create JSON file
  InsertJSONArray(JSONValue(#JSONFile), ModelGadget())   ;Insert ModelGadget list in JSON file
  SaveJSON(#JSONFile, "SweetyVD.json", #PB_JSON_PrettyPrint)                   ;Save JSON file
EndProcedure

Procedure RenameGadgetForm(IdGadget.i)
  If OpenWindow(#RenameGadgetWindow, WindowX(#MainWindow)+GadgetX(#ScrollDrawArea)+1, WindowY(#MainWindow)+GadgetY(#GadgetList)+GadgetY(#ListGadgets)+4, 172, 72, "Rename Gadget",#PB_Window_TitleBar)
    StickyWindow(#RenameGadgetWindow, #True)
    AddKeyboardShortcut(#RenameGadgetWindow, #PB_Shortcut_Escape, #Shortcut_Escape)
    AddKeyboardShortcut(#RenameGadgetWindow, #PB_Shortcut_Return, #Shortcut_Return)
    TextGadget(#RenameGadgetSharp, 2, 7, 10, 20, "#")
    StringGadget(#RenameGadgetString, 14, 4, 154, 22, "")
    If FindMapElement(SVDListGadget(), Str(IdGadget))
      SetGadgetText(#RenameGadgetString, Mid(SVDListGadget()\Name,2))
    EndIf
    TextGadget(#RenameGadgetMsg, 2, 30, 168, 16, "")
    ButtonGadget(#RenameGadgetOK, 63, 50, 50, 18, "OK")
    ButtonGadget(#RenameGadgetCancel, 118, 50, 50, 18, "Cancel")
    SetActiveGadget(#RenameGadgetString)
  EndIf
EndProcedure

Procedure RenameGadget(IdGadget.i)
  Protected RenameGadgetString.s, InvalidName.b, I.i
  RenameGadgetString = GetGadgetText(#RenameGadgetString)
  If RenameGadgetString = ""
    SetGadgetText(#RenameGadgetMsg, "Enter a Name")
    SetGadgetText(#RenameGadgetString, Mid(RenameGadgetString,2))
    InvalidName = #True
  ElseIf Left(RenameGadgetString, 1) = "#"
    SetGadgetText(#RenameGadgetMsg, "# as 1st Char removed")
    SetGadgetText(#RenameGadgetString, Mid(RenameGadgetString,2))
    InvalidName = #True
  Else
    ForEach SVDListGadget()   ;Name already used
      If SVDListGadget()\Gadget <> IdGadget And SVDListGadget()\Name = "#" + RenameGadgetString + "_"
        SetGadgetText(#RenameGadgetMsg, "Name already used")
        InvalidName = #True
        Break
      EndIf
    Next
    If InvalidName = #False
      For I=0 To ArraySize(ModelGadget())
        If ModelGadget(I)\Name = Left(RenameGadgetString, Len(ModelGadget(I)\Name))   ;Name defined in Model Gadget: SweetyVD.json
          SetGadgetText(#RenameGadgetMsg, "Name is reserved (Model)")
          InvalidName = #True
          Break
        EndIf
      Next
    EndIf
  EndIf
  If InvalidName = #False
    If FindMapElement(SVDListGadget(), Str(IdGadget))
      SVDListGadget()\Name = "#" + RenameGadgetString
      SetGadgetItemText(#TreeControls, GetGadgetState(#TreeControls), RenameGadgetString)
      SetGadgetItemText(#ListGadgets, GetGadgetState(#ListGadgets), RenameGadgetString)
    EndIf
    RemoveKeyboardShortcut(#RenameGadgetWindow, #PB_Shortcut_Escape)
    RemoveKeyboardShortcut(#RenameGadgetWindow, #PB_Shortcut_Return)
    CloseWindow(#RenameGadgetWindow)
  Else
    SetActiveGadget(#RenameGadgetString)
  EndIf
EndProcedure

Procedure CreateGadgets(Model.s)
  Protected IdGadget.i, ModelType.i, DrawGadget.b, TmpCaption.s, Mini.i, Maxi.i, StepValue.i, I.i
  InitProperties()
  OpenGadgetList(#ScrollDrawArea)   ;Required when changing apps(ex: test generated code) to reopen the GadgetList
  For I=0 To ArraySize(ModelGadget())
    If ModelGadget(I)\Model = Model
      With ModelGadget(I)

        \CountGadget=\CountGadget+1   ;Updating the gadget counter by model

        ParentPosDim()   ;#ScrollDrawArea
        X = GridMatch(X, DragSpace, MinX, MaxX-\DftWidth)   ;Align on Grid and remains inside the grid
        Y = GridMatch(Y, DragSpace, MinY, MaxY-\DftHeight)
        ;Default values from the gadget models table
        Select Left(\Caption, 5)
          Case "#Text", "#TabN"
            If Mid(\Caption, 7) <> ""   ;If empty, nothing and no comma for the default value
              TmpCaption=Mid(\Caption, 7)   ;"#Text:blabla"
            Else
              TmpCaption=\Name+"_"+Str(\CountGadget)   ;Caption=#Text:blabla => "blabla", or ""
            EndIf
          Case "#Date"
            TmpCaption=Mid(\Caption, 7)   ;#Date:%dd/%mm/%yyyy
          Case "#Dir$"
            TmpCaption=Mid(\Caption, 7)   ;"#Dir$:C:\blabla\"
          Case "#Url$"
            TmpCaption=Mid(\Caption, 7)   ;"#Url$:https://www.purebasic.fr/"
          Default : TmpCaption=""
        EndSelect
        ModelType=2
        DrawGadget=#False

        Select Model   ;Create Gadget depending on model
          Case "ButtonGadget" : IdGadget=ButtonGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, TmpCaption)
          Case "ButtonImageGadget" : IdGadget=ButtonImageGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, 0)
          Case "CalendarGadget" : IdGadget=  CalendarGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, 0)
          Case "CanvasGadget"
            IdGadget=CanvasGadget(#PB_Any, X, Y, \DftWidth, \DftHeight)
            If StartDrawing(CanvasOutput(IdGadget))
              DrawText(5, 5, \Name+"_"+Str(\CountGadget), #Blue, #White)
              StopDrawing()
            EndIf
          Case "CheckBoxGadget" : IdGadget=CheckBoxGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, TmpCaption)
          Case "ComboBoxGadget"
            IdGadget=ComboBoxGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, #PB_ComboBox_Editable)
            AddGadgetItem(Idgadget,-1,TmpCaption)
          Case "ContainerGadget"
            ModelType=1
            DrawGadget=#True
            IdDrawGadgets=IdDrawGadgets+1
            IdGadget=IdDrawGadgets
            ;IdGadget=ContainerGadget(#PB_Any, X, Y, \DftWidth, \DftHeight)
            ;CloseGadgetList()
          Case "DateGadget" : IdGadget=DateGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, TmpCaption)
          Case "EditorGadget"
            IdGadget=EditorGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, #PB_Editor_ReadOnly)
            AddGadgetItem(IdGadget, 0, \Name+"_"+Str(\CountGadget))
          Case "ExplorerComboGadget" : IdGadget =ExplorerComboGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, "")
          Case "ExplorerListGadget" : IdGadget=ExplorerListGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, "")
          Case "ExplorerListGadget" : IdGadget=ExplorerListGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, "")
          Case "FrameGadget"
            DrawGadget=#True
            IdDrawGadgets=IdDrawGadgets+1
            IdGadget=IdDrawGadgets
            ;IdGadget=FrameGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, TmpCaption)
          Case "HyperLinkGadget" : IdGadget=HyperLinkGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, TmpCaption, RGB(0,0,128))
          Case "ImageGadget"   ;We cheat with a Canvas instead of an ImageGadget
            IdGadget=CanvasGadget(#PB_Any, X, Y, \DftWidth, \DftHeight)
            If StartDrawing(CanvasOutput(IdGadget))
              DrawText(5, 5, \Name+"_"+Str(\CountGadget), #Blue, #White)
              StopDrawing()
            EndIf
          Case "IPAddressGadget"
            IdGadget=  IPAddressGadget(#PB_Any, X, Y, \DftWidth, \DftHeight)
            SetGadgetState(IdGadget, MakeIPAddress(127, 0, 0, 1))
          Case "ListIconGadget" : IdGadget=ListIconGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, TmpCaption, 100)
          Case "ListViewGadget" : IdGadget=ListViewGadget(#PB_Any, X, Y, \DftWidth, \DftHeight)
          Case "OpenGLGadget" : IdGadget=OpenGLGadget(#PB_Any, X, Y, \DftWidth, \DftHeight)
          Case "OptionGadget" : IdGadget=OptionGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, TmpCaption)
          Case "PanelGadget"
            ModelType=1
            DrawGadget=#True
            IdDrawGadgets=IdDrawGadgets+1
            IdGadget=IdDrawGadgets
            ;IdGadget=PanelGadget(#PB_Any, X, Y, \DftWidth, \DftHeight)
            ;AddGadgetItem(IdGadget, -1, TmpCaption)
            ;DisableGadget(IdGadget,#True)
            ;CloseGadgetList()
          Case "ProgressBarGadget"
            Mini = Val(Mid(\Option1, 7)) : Maxi = Val(Mid(\Option2, 7))
            IdGadget=ProgressBarGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, Mini, Maxi)
            SetGadgetState(IdGadget, Mini+(Maxi-Mini)*2/3)
          Case "ScintillaGadget"
            If InitScintilla()
              IdGadget=ScintillaGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, 0)
            EndIf
          Case "ScrollAreaGadget"
            ModelType=1
            DrawGadget=#True
            IdDrawGadgets=IdDrawGadgets+1
            IdGadget=IdDrawGadgets
            ;InnerWidth, InnerHeight
            Mini = Val(Mid(\Option1, 7)) : Maxi = Val(Mid(\Option2, 7)) : StepValue = Val(Mid(\Option3, 7))
            ;IdGadget=ScrollAreaGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, Mini, Maxi, StepValue)
            ;CloseGadgetList()
          Case "ScrollBarGadget"
            Mini = Val(Mid(\Option1, 7)) : Maxi = Val(Mid(\Option2, 7))
            IdGadget=ScrollBarGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, Mini, Maxi, 0)
          Case "SpinGadget"
            Mini = Val(Mid(\Option1, 7)) : Maxi = Val(Mid(\Option2, 7))
            IdGadget=SpinGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, Mini, Maxi, #PB_Spin_Numeric)
            SetGadgetState(IdGadget, Mini+(Maxi-Mini)*2/3)
          Case "StringGadget"
            IdGadget=StringGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, TmpCaption, #PB_String_ReadOnly)
          Case "TextGadget" : IdGadget=TextGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, TmpCaption)
          Case "TrackBarGadget"
            Mini = Val(Mid(\Option1, 7)) : Maxi = Val(Mid(\Option2, 7))
            IdGadget=TrackBarGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, Mini, Maxi)
            SetGadgetState(IdGadget, Mini+(Maxi-Mini)*2/3)
          Case "TreeGadget" : IdGadget=TreeGadget(#PB_Any, X, Y, \DftWidth, \DftHeight)
          Case "WebGadget" : IdGadget=WebGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, TmpCaption)
          Case "TabBarGadget"
            IdGadget=TabBarGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, #TabBarGadget_BottomLine|#TabBarGadget_CloseButton, #MainWindow)
            AddTabBarGadgetItem(IdGadget, #PB_Default, TmpCaption)
          Default
            If Model <> "" And \Name <> "" And \DftWidth > 0 And \DftHeight > 0
              IdGadget=CanvasGadget(#PB_Any, X, Y, \DftWidth, \DftHeight)
              If StartDrawing(CanvasOutput(IdGadget))
                DrawText(5, 5, \Name+"_"+Str(\CountGadget), #Blue, #White)
                StopDrawing()
              EndIf
            EndIf
        EndSelect

        CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
          If DrawGadget = #False : DisableGadget(IdGadget, #True) : EndIf
        CompilerEndIf
        ;Save gadget information in the gadget map List
        AddMapElement(SVDListGadget(), Str(IdGadget))
        SVDListGadget()\Gadget=Idgadget
        SVDListGadget()\Model=Model
        SVDListGadget()\Type=\Type
        SVDListGadget()\Name="#"+\Name+"_"+Str(\CountGadget)
        SVDListGadget()\ParentGadget = #ScrollDrawArea
        SVDListGadget()\ParentElement = 0
        SVDListGadget()\X =X
        SVDListGadget()\Y=Y
        SVDListGadget()\Width=\DftWidth
        SVDListGadget()\Height=\DftHeight
        SVDListGadget()\DrawGadget = DrawGadget
        ;Default values from the gadget models table
        Select Left(\Caption, 5)
          Case "#Text" : SVDListGadget()\Caption = "#Text:" + TmpCaption
          Case "#Date" : SVDListGadget()\Caption = "#Date:" + TmpCaption
          Case "#Dir$" : SVDListGadget()\Caption = "#Dir$:" + TmpCaption
          Case "#Url$" : SVDListGadget()\Caption = "#Url$:" + TmpCaption
          Case "#TabN" : SVDListGadget()\Caption = "#TabN:" + TmpCaption
          Default : SVDListGadget()\Caption=\Caption
        EndSelect

        SVDListGadget()\Option1=\Option1
        SVDListGadget()\Option2=\Option2
        SVDListGadget()\Option3=\Option3
        SVDListGadget()\FrontColor=\FrontColor
        SVDListGadget()\BackColor=\BackColor
        SVDListGadget()\ToolTip=\ToolTip
        SVDListGadget()\Constants=\Constants

        SVDListGadget()\ModelType=ModelType
        SVDListGadget()\DrawGadget=DrawGadget

        ;Add Gadget to List Gadgets ComboBox with IdGadget as Data. Element 0 is reserved for Window Draw Area
        AddGadgetItem(#ListGadgets, -1, SVDListGadget()\Name)
        SetGadgetState(#ListGadgets, CountGadgetItems(#ListGadgets)-1)
        SetGadgetItemData(#ListGadgets, CountGadgetItems(#ListGadgets)-1, IdGadget)

        AddGadgetItem(#TreeControls, -1, SVDListGadget()\Name, ImageID(\Image), 1)
        SetGadgetState(#TreeControls, CountGadgetItems(#TreeControls)-1)
        SetGadgetItemData(#TreeControls, CountGadgetItems(#TreeControls)-1, IdGadget)
        ;Add Drag Handle Gadget in module
        If DrawGadget = #False
          AddSVDGadget(IdGadget, Model)
        Else
          AddSVDDrawGadget(IdGadget, Model)
        EndIf
      EndWith
      Break
    EndIf
  Next
EndProcedure

Procedure InitWindowSelected()
  SetGadgetState(#ListGadgets, #MainWindow)
  SetGadgetState(#TreeControls, #MainWindow)
  SetGadgetState(#PosGadgetX, 0) : SetGadgetState(#PosGadgetY, 0)
  SetGadgetState(#PosGadgetWidth, GetGadgetState(#SetDrawWidth)) : SetGadgetState(#PosGadgetHeight, GetGadgetState(#SetDrawHeight))
  LoadGadgetProperties(#MainWindow)
  DisableGadget(#DeleteGadgetButton,#True)
  HideGadget(#HideGadget, #True) : HideGadget(#DisableGadget, #True) : HideGadget(#LockGadget, #True)
  DisableGadget(#PosGadgetX, #True) : DisableGadget(#PosGadgetY, #True)
  ;HideGadget(#ParentText, #True) : HideGadget(#ParentString, #True) : HideGadget(#ParentPick, #True)
  HideGadget(#FontText, #True) : HideGadget(#FontString, #True) : HideGadget(#FontPick, #True)
  ;HideGadget(#AddMenu, #False) : HideGadget(#AddPopupMenu, #False) : HideGadget(#AddToolBar, #False) : HideGadget(#AddStatusBar, #False)
EndProcedure

Procedure InitProperties()
  ;HideGadget(#AddMenu, #True) : HideGadget(#AddPopupMenu, #True) : HideGadget(#AddToolBar, #True) : HideGadget(#AddStatusBar, #True)
  DisableGadget(#CaptionString,#True)
  DisableGadget(#ToolTipString,#False)
  DisableGadget(#DeleteGadgetButton,#False)
  HideGadget(#HideGadget, #False) : HideGadget(#DisableGadget, #False) : HideGadget(#LockGadget, #False)
  ;HideGadget(#ParentText, #False) : HideGadget(#ParentString, #False) : HideGadget(#ParentPick, #False)
  HideGadget(#ParentText, #True) : HideGadget(#ParentString, #True) : HideGadget(#ParentPick, #True)

  HideGadget(#MiniText, #True) : HideGadget(#MiniString, #True)
  HideGadget(#MaxiText, #True) : HideGadget(#MaxiString, #True)
  HideGadget(#ImageText, #True) : HideGadget(#ImageString, #True) : HideGadget(#ImagePick, #True)
  HideGadget(#FontText, #False) : HideGadget(#FontString, #False) : HideGadget(#FontPick, #False)

  HideGadget(#FrontColorText, #True) : HideGadget(#FrontColorPick, #True)
  HideGadget(#BackColorText, #True) : HideGadget(#BackColorPick, #True)

  SetGadgetText(#CaptionText, "") : SetGadgetText(#CaptionString, "")
  SetGadgetText(#ToolTipText, "ToolTip") : SetGadgetText(#ToolTipString, "")
  SetGadgetText(#MiniText, "Mini") : SetGadgetText(#MaxiText, "Maxi")
  SetGadgetText(#MiniString, "") : SetGadgetText(#MaxiString, "")
  SetGadgetText(#ImageString, "")
  ClearGadgetItems(#Constants)
EndProcedure

Procedure LoadGadgetProperties(IdGadget.i)
  Protected TmpConstants.s, sFontString.s, I.i
  InitProperties()
  With SVDListGadget()
    If FindMapElement(SVDListGadget(), Str(IdGadget))
      SetGadgetState(#HideGadget, \Hide)
      SetGadgetState(#DisableGadget, \Disable)
      SetGadgetState(#LockGadget, \Lock)
      DisableGadget(#PosGadgetX, \Lock) : DisableGadget(#PosGadgetY, \Lock) : DisableGadget(#PosGadgetWidth, \Lock) : DisableGadget(#PosGadgetHeight, \Lock)

      Select Left(\Caption, 5)
        Case "#Text"
          SetGadgetText(#CaptionText, "Text")
          SetGadgetText(#CaptionString, Mid(\Caption, 7)) : DisableGadget(#CaptionString,#False)
        Case "#Date"
          SetGadgetText(#CaptionText, "Fmt Date")
          SetGadgetText(#CaptionString, Mid(\Caption, 7)) : DisableGadget(#CaptionString,#False)
        Case "#Dir$"
          SetGadgetText(#CaptionText, "Ini Folder")
          SetGadgetText(#CaptionString, Mid(\Caption, 7)) : DisableGadget(#CaptionString,#False)
        Case "#Url$"
          SetGadgetText(#CaptionText, "Url")
          SetGadgetText(#CaptionString, Mid(\Caption, 7)) : DisableGadget(#CaptionString,#False)
        Case "#TabN"
          SetGadgetText(#CaptionText, "Tab name")
          SetGadgetText(#CaptionString, Mid(\Caption, 7)) : DisableGadget(#CaptionString,#False)
      EndSelect

      If \Model = "ScrollAreaGadget" : SetGadgetText(#MiniText, "InnerW") : SetGadgetText(#MaxiText, "InnerH") : EndIf
      If Left(\ToolTip, 5) = "#Nooo"
        SetGadgetText(#ToolTipText, "")
        DisableGadget(#ToolTipString,#True)
      Else
        SetGadgetText(#ToolTipString, \ToolTip)
      EndIf
      Select Left(\Option1, 5)
        Case "#Mini", "#InrW"
          SetGadgetText(#MiniString, Mid(\Option1, 7))
          HideGadget(#MiniText, #False)
          HideGadget(#MiniString, #False)
        Case "#Imag"
          SetGadgetText(#ImageString, Mid(\Option1, 7))
          HideGadget(#ImageText, #False)
          HideGadget(#ImageString, #False)
          HideGadget(#ImagePick, #False)
      EndSelect
      Select Left(\Option2, 5)
        Case "#Maxi", "#InrH"
          SetGadgetText(#MaxiString, Mid(\Option2, 7))
          HideGadget(#MaxiText, #False)
          HideGadget(#MaxiString, #False)
      EndSelect

      If \FontID = 0
        SetGadgetText(#FontString, "")
      Else
        ResetList(FontStructArray())
        While NextElement(FontStructArray())
          If FontStructArray()\FontID = \FontID
            sFontString = FontStructArray()\FontName + " " + Str(FontStructArray()\FontSize)
            If FontStructArray()\FontStyle
              sFontString + " "
              If FontStructArray()\FontStyle & #PB_Font_Bold
                sFontString + "B"
              EndIf
              If FontStructArray()\FontStyle & #PB_Font_Italic
                sFontString + "I"
              EndIf
              If FontStructArray()\FontStyle & #PB_Font_StrikeOut
                sFontString + "S"
              EndIf
              If FontStructArray()\FontStyle & #PB_Font_Underline
                sFontString + "U"
              EndIf
              If FontStructArray()\FontStyle & #PB_Font_HighQuality
                sFontString + "H"
              EndIf
            EndIf
            SetGadgetText(#FontString, sFontString)
            Break
          EndIf
        Wend
      EndIf

      If Left(\FrontColor, 5) <> "#Nooo"
        If \FrontColor = ""
          SetGadgetAttribute(#FrontColorPick, #PB_Button_Image, 0)
        Else
          If StartDrawing(ImageOutput(#FrontColorImg))
            Box(0, 0, OutputWidth(), OutputHeight(), Val(\FrontColor))
            StopDrawing()
            SetGadgetAttribute(#FrontColorPick, #PB_Button_Image, ImageID(#FrontColorImg))
          EndIf
        EndIf
        HideGadget(#FrontColorText, #False)
        HideGadget(#FrontColorPick, #False)
      EndIf
      If Left(\BackColor, 5) <> "#Nooo"
        If \BackColor = ""
          SetGadgetAttribute(#BackColorPick, #PB_Button_Image, 0)
        Else
          If StartDrawing(ImageOutput(#BackColorImg))
            Box(0, 0, OutputWidth(), OutputHeight(), Val(\BackColor))
            StopDrawing()
            SetGadgetAttribute(#BackColorPick, #PB_Button_Image, ImageID(#BackColorImg))
          EndIf
        EndIf
        HideGadget(#BackColorText, #False)
        HideGadget(#BackColorPick, #False)
      EndIf
      ;Constants
      For I = 1 To CountString(\Constants, "|") + 1
        TmpConstants = Trim(StringField(\Constants, I, "|"))
        If TmpConstants <> ""
          If Right(TmpConstants, 3) = "(x)"
            AddGadgetItem(#Constants, -1, Left(TmpConstants, Len(TmpConstants)-3))
            SetGadgetItemState(#Constants, I-1,  #PB_Tree_Checked)
          Else
            AddGadgetItem(#Constants, -1, TmpConstants)
          EndIf
        EndIf
      Next
    EndIf
  EndWith
EndProcedure

Procedure RemoveFont(FontID.i)
  Protected TmpFontID.i
  ResetMap(SVDListGadget())
  With SVDListGadget()
    While NextMapElement(SVDListGadget())
      If \FontID = FontID
        TmpFontID = \FontID
        Break
      EndIf
    Wend
  EndWith
  If TmpFontID = 0
    With FontStructArray()
      ResetList(FontStructArray())
      While NextElement(FontStructArray())
        If \FontID = FontID
          DeleteElement(FontStructArray())
          Break
        EndIf
      Wend
    EndWith
  EndIf
EndProcedure

Procedure SelectFont(IdGadget.i)
  Protected SelectedFont.i, iFontID.i, sFontName.s, iFontSize.i, iFontStyle.i, sFontString.s, I.i
  If FindMapElement(SVDListGadget(), Str(IdGadget))
    If SVDListGadget()\FontID <> 0
      With FontStructArray()
        ResetList(FontStructArray())
        While NextElement(FontStructArray())
          If \FontID = SVDListGadget()\FontID
            sFontName = \FontName
            iFontSize = \FontSize
            iFontStyle = \FontStyle
            Break
          EndIf
        Wend
      EndWith
    EndIf
    SelectedFont = FontRequester(sFontName, iFontSize, 0, 0, iFontStyle)

    If SelectedFont = 0
      If FindMapElement(SVDListGadget(), Str(IdGadget))
        iFontID = SVDListGadget()\FontID
        If iFontID <> 0
          If SVDListGadget()\DrawGadget = #False
            SetGadgetFont(IdGadget, #PB_Default)
          EndIf
          SVDListGadget()\FontID = 0
          RemoveFont(iFontID)
          SetGadgetText(#FontString, "")
        EndIf
      EndIf
    Else
      sFontName = SelectedFontName()
      iFontSize = SelectedFontSize()
      iFontStyle = SelectedFontStyle()
      If sFontName = "" And iFontSize = 0 And iFontStyle = 0
        If FindMapElement(SVDListGadget(), Str(IdGadget))
          iFontID = SVDListGadget()\FontID
          If iFontID <> 0
            If SVDListGadget()\DrawGadget = #False
              SetGadgetFont(IdGadget, #PB_Default)
            EndIf
            SVDListGadget()\FontID = 0
            RemoveFont(iFontID)
            SetGadgetText(#FontString, "")
          EndIf
        EndIf
      Else
        With FontStructArray()
          ResetList(FontStructArray())
          While NextElement(FontStructArray())
            If \FontName = sFontName And \FontSize = iFontSize And \FontStyle = iFontStyle
              iFontID = \FontID
              Break
            EndIf
          Wend
        EndWith
        If iFontID = 0
          CountFontID=CountFontID+1
          AddElement(FontStructArray())
          With FontStructArray()
            iFontID = LoadFont(#PB_Any, sFontName, iFontSize, iFontStyle)
            \FontID = iFontID
            \FontName = sFontName
            \FontSize = iFontSize
            \FontStyle = iFontStyle
          EndWith
        EndIf

        If FindMapElement(SVDListGadget(), Str(IdGadget))
          SVDListGadget()\FontID = iFontID
          sFontString = sFontName + " " + Str(iFontSize)
          If iFontStyle
            sFontString + " "
            If iFontStyle & #PB_Font_Bold
              sFontString + "B"
            EndIf
            If iFontStyle & #PB_Font_Italic
              sFontString + "I"
            EndIf
            If iFontStyle & #PB_Font_StrikeOut
              sFontString + "S"
            EndIf
            If iFontStyle & #PB_Font_Underline
              sFontString + "U"
            EndIf
            If iFontStyle & #PB_Font_HighQuality
              sFontString + "H"
            EndIf
          EndIf
          SetGadgetText(#FontString, sFontString)
          If SVDListGadget()\DrawGadget = #False
            SetGadgetFont(IdGadget, FontID(iFontID))
          EndIf
        EndIf
      EndIf
    EndIf
  EndIf
EndProcedure

Procedure RemoveImage(sImagePath.s)
  Protected TmpImagePath.s
  ResetMap(SVDListGadget())
  With SVDListGadget()
    While NextMapElement(SVDListGadget())
      If Left(\Option1, 5) = "#Imag" And Mid(\Option1, 7) = sImagePath
        If FileSize(sImagePath) > 1
          TmpImagePath = sImagePath
        Else
          \Option1 = "#Imag:0"
        EndIf
        Break
      EndIf
    Wend
  EndWith
  If TmpImagePath = ""
    With ImageBtnPathArray()
      ResetList(ImageBtnPathArray())
      While NextElement(ImageBtnPathArray())
        If \ImagePath = sImagePath
          DeleteElement(ImageBtnPathArray())
          Break
        EndIf
      Wend
    EndWith
  EndIf
EndProcedure

Procedure DrawSelectedImage(IdGadget.i)
  Protected ImagePath.s, OldImagePath.s, TmpImage.i, ImageBtn.i, Rtn.i, I.i
  ImagePath = OpenFileRequester("Select image",GetCurrentDirectory(),"Picture (*.bmp; *.jpg; *.png)|*.bmp;*.jpg;*.png", 1)
  If ImagePath
    TmpImage = LoadImage(#PB_Any, ImagePath)
    If TmpImage
      Rtn = MessageRequester("SweetyVD Information", "Do you want to resize the gadget to the image size ?", #PB_MessageRequester_Info|#PB_MessageRequester_YesNo)
      If Rtn = 6     ;the YES button was chosen (Result=7 for the NO button)
        If GadgetX(IdGadget) + ImageWidth(TmpImage) > UserScreen_Width
          ResizeSVDGadget(IdGadget, UserScreen_Width-ImageWidth(TmpImage), -1, -1, -1)
        EndIf
        ResizeSVDGadget(IdGadget, -1, -1, ImageWidth(TmpImage), -1)
        If GadgetY(IdGadget) + ImageHeight(TmpImage) > UserScreen_Height
          ResizeSVDGadget(IdGadget, -1, UserScreen_Height-ImageHeight(TmpImage), -1, -1)
        EndIf
        ResizeSVDGadget(IdGadget, -1, -1, -1, ImageHeight(TmpImage))
      EndIf
      ResetList(ImageBtnPathArray())
      While NextElement(ImageBtnPathArray())
        If ImageBtnPathArray()\ImagePath = ImagePath
          ImageBtn = ImageBtnPathArray()\ImageBtn
          Break
        EndIf
      Wend
      If ImageBtn = 0
        CountImageBtn=CountImageBtn+1
        AddElement(ImageBtnPathArray())
        ImageBtn = CopyImage(TmpImage, #PB_Any)
        ImageBtnPathArray()\ImageBtn=ImageBtn
        ImageBtnPathArray()\ImagePath=ImagePath
      EndIf
      FreeImage(TmpImage)
      If FindMapElement(SVDListGadget(), Str(IdGadget))
        Select GadgetType(IdGadget)
          Case 19
            SetGadgetAttribute(IdGadget, #PB_Button_Image, ImageID(ImageBtn))
            ResizeGadget(IdGadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore)
          Case 33
            SetGadgetAttribute(IdGadget, #PB_Canvas_Image, ImageID(ImageBtn))
        EndSelect
        SetGadgetText(#ImageString, ImagePath)   ;Or GetFilePart(ImagePath) and the same in LoadGadgetProperties
        SVDListGadget()\Option1 = "#Imag:" + ImagePath
      EndIf
    Else
      If FindMapElement(SVDListGadget(), Str(IdGadget))
        If Left(SVDListGadget()\Option1, 5) = "#Imag"
          OldImagePath = Mid(SVDListGadget()\Option1, 7)
        EndIf
        If OldImagePath <> ""
          Select GadgetType(IdGadget)
            Case 19
              SetGadgetAttribute(IdGadget, #PB_Button_Image, 0)
            Case 33
              If StartDrawing(CanvasOutput(IdGadget))
                Box(0, 0, OutputWidth(), OutputHeight(), $FFFFFF)
                DrawText(5, 5, GetGadgetItemText(#ListGadgets, GetGadgetState(#ListGadgets)), #Blue, #White)
                StopDrawing()
              EndIf
          EndSelect
          SetGadgetText(#ImageString, "0")
          SVDListGadget()\Option1 = "#Imag:0"
          RemoveImage(OldImagePath)
        EndIf
      EndIf
    EndIf
  Else
    If FindMapElement(SVDListGadget(), Str(IdGadget))
      If Left(SVDListGadget()\Option1, 5) = "#Imag"
        OldImagePath = Mid(SVDListGadget()\Option1, 7)
      EndIf
      If OldImagePath <> ""
        Select GadgetType(IdGadget)
          Case 19
            SetGadgetAttribute(IdGadget, #PB_Button_Image, 0)
          Case 33
            If StartDrawing(CanvasOutput(IdGadget))
              Box(0, 0, OutputWidth(), OutputHeight(), $FFFFFF)
              DrawText(5, 5, GetGadgetItemText(#ListGadgets, GetGadgetState(#ListGadgets)), #Blue, #White)
              StopDrawing()
            EndIf
        EndSelect
        SetGadgetText(#ImageString, "0")
        SVDListGadget()\Option1 = "#Imag:0"
        RemoveImage(OldImagePath)
      EndIf
    EndIf
  EndIf
EndProcedure

Procedure ResizeDrawArea(Width.i, Height.i)
  DrawAreaSize(Width, Height)   ;For UserScreen_Width(Height) and UserScreen handle for resizing
  DrawGrid()
EndProcedure

Procedure WindowSize()
  Protected DrawMaxWidth.i, DrawMaxHeight.i, ScrollMargin = 20
  ;Adjust width and height of the scroll drawing area according to window size
  If GetWindowState(#MainWindow) = #PB_Window_Normal
    Designer_Width = WindowWidth(#MainWindow)
    Designer_Height = WindowHeight(#MainWindow)
  EndIf
  If IsGadget(#ScrollDrawArea) And GadgetType(#ScrollDrawArea) = #PB_GadgetType_ScrollArea
    DrawMaxWidth = WindowWidth(#MainWindow) - GadgetX(#ScrollDrawArea) - 10   ;10 from the right border
    If DrawMaxWidth > GetGadgetAttribute(#ScrollDrawArea,#PB_ScrollArea_InnerWidth) + ScrollMargin
      DrawMaxWidth = GetGadgetAttribute(#ScrollDrawArea,#PB_ScrollArea_InnerWidth) + ScrollMargin
    EndIf
    DrawMaxHeight = WindowHeight(#MainWindow) - GadgetY(#ScrollDrawArea) - 10   ;10 from the bottom border
    If DrawMaxHeight > GetGadgetAttribute(#ScrollDrawArea,#PB_ScrollArea_InnerHeight) + ScrollMargin
      DrawMaxHeight = GetGadgetAttribute(#ScrollDrawArea,#PB_ScrollArea_InnerHeight) + ScrollMargin
    EndIf
    ResizeGadget(#SettingContainer, #PB_Ignore, #PB_Ignore, DrawMaxWidth, #PB_Ignore)
    ResizeGadget(#ScrollDrawArea, #PB_Ignore, #PB_Ignore, DrawMaxWidth, DrawMaxHeight)
    ReDrawGadgetHandleBorder()
    ReDrawHandle()
  EndIf
EndProcedure

Procedure OpenMainWindow(Designer_Width, Designer_Height, X = 0, Y = 0)
  Protected GadgetObj.i, Designer_Maximize.b = 0, ScrollArea_MaxWidth.l = 1920, ScrollArea_MaxHeight.l = 1020
  Protected Flags.i = #PB_Window_SizeGadget | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_ScreenCentered | #PB_Window_SystemMenu
  If OpenPreferences("SweetyVD.ini", #PB_Preference_GroupSeparator)
    PreferenceGroup("Designer")
    Designer_Maximize  = ReadPreferenceLong("Designer_Maximize", Designer_Maximize)
    ScrollArea_MaxWidth = ReadPreferenceLong("ScrollArea_MaxWidth", ScrollArea_MaxWidth)
    ScrollArea_MaxHeight = ReadPreferenceLong("ScrollArea_MaxHeight", ScrollArea_MaxHeight)
    ClosePreferences()
  EndIf
  If Designer_Maximize  = 1 : Flags = Flags | #PB_Window_Maximize : EndIf

  OpenWindow(#MainWindow, x, y, Designer_Width, Designer_Height, "SweetyVD (Visual Designer) " + #BuildVersion, Flags)
  CreatePopupImageMenu(#PopUpMenu)
  ButtonGadget(#CodeCreate, 5, 5, 100, 25, "Create Code")
  ButtonGadget(#EnableSVD, 115, 5, 100, 25, "Preview", #PB_Button_Toggle)

  ContainerGadget(#SettingContainer, 220, 5, 650, 30, #PB_Container_Raised)
  TextGadget(#SetDrawSizeText, 5, 4, 30, 20, "Size")
  SpinGadget(#SetDrawWidth, 35, 1, 70, 20, 1, ScrollArea_MaxWidth, #PB_Spin_Numeric)
  TextGadget(#SetDrawSizeTextX, 105, 4, 10, 20, "x", #PB_Text_Center)
  SpinGadget(#SetDrawHeight, 115, 1, 70, 20, 1, ScrollArea_MaxHeight, #PB_Spin_Numeric)
  TextGadget(#DragText, 200, 4, 75, 20, "Drag space")
  SpinGadget(#DragSpace, 275, 1, 50, 20, 1, 20, #PB_Spin_Numeric)  : SetGadgetState(#DragSpace, DragSpace)
  CheckBoxGadget(#ShowGrid, 340, 2, 85, 20, "Show grid") : SetGadgetState(#ShowGrid, ShowGrid)
  SpinGadget(#GridSize, 425, 1, 50, 20, 1, 50, #PB_Spin_Numeric) : SetGadgetState(#GridSize, GridSize)

  CheckBoxGadget(#AddMenu, 490, 2, 55, 20, "Menu")
  CheckBoxGadget(#AddPopupMenu, 545, 2, 60, 20, "Popup")
  CheckBoxGadget(#AddToolBar, 605, 2, 65, 20, "ToolBar")
  CheckBoxGadget(#AddStatusBar, 670, 2, 75, 20, "StatusBar")
  CloseGadgetList()

  CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
    PanelGadget(#PanelControls, 0, 35, 220, 215)
    AddGadgetItem(#PanelControls, -1, " Create Controls ")
    TreeGadget(#CreateControlsList, 0, 0, 200, 170, #PB_Tree_NoLines | #PB_Tree_NoButtons)
    AddGadgetItem(#PanelControls, -1, "  List Controls ")
    TreeGadget(#TreeControls, 0, 0, 200, 170, #PB_Tree_AlwaysShowSelection)
    CloseGadgetList()
  CompilerElse
    PanelGadget(#PanelControls, 5, 35, 210, 205)
    AddGadgetItem(#PanelControls, -1, " Create Controls ")
    TreeGadget(#CreateControlsList, 0, 0, 205, 180, #PB_Tree_NoLines | #PB_Tree_NoButtons)
    AddGadgetItem(#PanelControls, -1, "  List Controls ")
    TreeGadget(#TreeControls, 0, 0, 205, 180, #PB_Tree_AlwaysShowSelection)
    CloseGadgetList()
  CompilerEndIf

  ContainerGadget(#GadgetList, 5, 243, 210, 152, #PB_Container_Raised)
  ComboBoxGadget(#ListGadgets, 2, 2, 154, 22)
  CatchImage(#Img_Rename,?Img_Rename)
  ButtonImageGadget(#RenameGadgetButton, 158, 2, 22, 22, ImageID(#Img_Rename))
  CatchImage(#Img_Delete,?Img_Delete)
  ButtonImageGadget(#DeleteGadgetButton, 182, 2, 22, 22, ImageID(#Img_Delete))
  GadgetToolTip(#DeleteGadgetButton, "Use Shift + Del as keyboard shortcut")
  CheckBoxGadget(#HideGadget, 2, 29, 55, 20, "Hide")
  CheckBoxGadget(#DisableGadget, 60, 29, 70, 20, "Disable")
  CheckBoxGadget(#LockGadget, 130, 29, 55, 20, "Lock")
  SpinGadget(#PosGadgetX, 2, 72, 70, 20, 0, ScrollArea_MaxWidth, #PB_Spin_Numeric) : SetGadgetState(#PosGadgetX, 0)
  SpinGadget(#PosGadgetY, 68, 49, 70, 20, 0, ScrollArea_MaxHeight, #PB_Spin_Numeric) : SetGadgetState(#PosGadgetY, 0)
  SpinGadget(#PosGadgetWidth, 133, 72, 70, 20, 1, ScrollArea_MaxWidth, #PB_Spin_Numeric)
  SpinGadget(#PosGadgetHeight, 68, 95, 70, 20, 1, ScrollArea_MaxHeight, #PB_Spin_Numeric)
  StringGadget(#ParentText, 0, 122, 65, 22, "Parent", #PB_String_ReadOnly)
  StringGadget(#ParentString, 65, 122, 114, 22, "", #PB_String_ReadOnly)
  ButtonGadget(#ParentPick, 179, 122, 26, 22, "...")
  CloseGadgetList()

  ContainerGadget(#PropertiesContainer, 5, 398, 210, 118, #PB_Container_Raised)
  StringGadget(#CaptionText, 0, 2, 65, 22, "Caption", #PB_String_ReadOnly)
  StringGadget(#CaptionString, 65, 2, 141, 22, "")
  StringGadget(#ToolTipText, 0, 24, 65, 22, "ToolTip", #PB_String_ReadOnly)
  StringGadget(#ToolTipString, 65, 24, 141, 22, "")
  StringGadget(#FontText, 0, 46, 65, 22, "Font", #PB_String_ReadOnly)
  StringGadget(#FontString, 65, 46, 114, 22, "", #PB_String_ReadOnly)
  ButtonGadget(#FontPick, 179, 46, 26, 22, "...")
  StringGadget(#MiniText, 0, 68, 52, 22, "Mini", #PB_String_ReadOnly)
  StringGadget(#MiniString, 52, 68, 50, 22, "0", #PB_String_Numeric)
  StringGadget(#MaxiText, 104, 68, 52, 22, "Maxi", #PB_String_ReadOnly)
  StringGadget(#MaxiString, 156, 68, 50, 22, "100", #PB_String_Numeric)
  StringGadget(#ImageText, 0, 68, 65, 22, "Image", #PB_String_ReadOnly)
  StringGadget(#ImageString, 65, 68, 114, 22, "C:\xxxx\PB.jpg", #PB_String_ReadOnly)
  ButtonGadget(#ImagePick, 179, 68, 26, 22, "...") : HideGadget(#ImagePick, #True)
  TextGadget(#FrontColorText, 5, 94, 66, 22, "FrontColor")
  ButtonImageGadget(#FrontColorPick, 71, 92, 22, 18, 0)
  CreateImage(#FrontColorImg, 22, 18)
  TextGadget(#BackColorText, 111, 94, 66, 22, "BackColor")
  ButtonImageGadget(#BackColorPick, 177, 92, 22, 18, 0)
  CreateImage(#BackColorImg, 22, 18)
  CloseGadgetList()
  TreeGadget(#Constants, 5, 523, 210, 130, #PB_Tree_NoLines | #PB_Tree_NoButtons | #PB_Tree_CheckBoxes)

  ScrollAreaGadget(#ScrollDrawArea, 220, 35, WindowWidth(#MainWindow)-220-10, WindowHeight(#MainWindow)-35-10, ScrollArea_MaxWidth + 10, ScrollArea_MaxHeight + 10, 20, #PB_ScrollArea_Single)   ;InnerWidth,InnerHeight + 10 for the resize handle of the drawing window

  EnableGadgetDrop(#CreateControlsList, #PB_Drop_Text, #PB_Drag_Copy)
  EnableGadgetDrop(#ScrollDrawArea, #PB_Drop_Text, #PB_Drag_Copy)

  ;All interface Objects must have #PB_Ignore as data. To not load them later when loading Designer
  PB_Object_EnumerateStart(PB_Gadget_Objects)
  While PB_Object_EnumerateNext(PB_Gadget_Objects, @GadgetObj)
    SetGadgetData(GadgetObj, #PB_Ignore)
  Wend

  If GetGadgetState(#ShowGrid) = #PB_Checkbox_Checked And GetGadgetState(#EnableSVD) = #False
    ShowGrid = #True
  Else
    ShowGrid = #False
  EndIf
  ;*** Important *** Call InitSVD just after the ScrollArea and before creating Gadets on it: default param CountGadget.i = 144
  InitSVD()
EndProcedure

Procedure Init()
  DelOldFiles(GetTemporaryDirectory(), "~SweetyVD*.pb", 2)   ;Cleaning, Keep 2 days temporary files
  StartPrefs()
  PBIDEpath = GetPBIDE()
  LoadFontWML()
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    InitColorPrefs()
  CompilerEndIf
  LoadControls()
  ;Menu, ToolBar, StatusBar default Height
  OpenWindow(#WinBarHeight, 0, 0, 0, 0, "", #PB_Window_Invisible)
  CreateMenu(0, WindowID(#WinBarHeight))
  CreateToolBar(0, WindowID(#WinBarHeight))
  ToolBarStandardButton(0, #PB_ToolBarIcon_New)
  CreateStatusBar(0, WindowID(#WinBarHeight))
  AddStatusBarField(80)
  StatusBarText(0, 0, "StatusBar")
  AddMenuHeight = MenuHeight()
  AddToolBarHeight = ToolBarHeight(0)
  AddStatusBarHeight = StatusBarHeight(0)
  CloseWindow(#WinBarHeight)
EndProcedure

;- Main
Define *PosDim.PosDim
Define IdGadget.i, ImagePath.s, TmpImage.i, SelectedColor.i, TmpConstants.s, I.i
Define Model.s, GadgetsListElement.i, TimerElapsedTime.i = 60000

Init()
OpenMainWindow(Designer_Width, Designer_Height)
WindowSize()

If FileSize("SweetyVD.json") = -1
  InitModelgadget()   ;Initializing Gadget Model Templates from Datasection + Save JSON file
Else
  InitJSONModelGadget()   ;Initializing Gadget Model Templates from JSON file
EndIf
BindEvent(#PB_Event_SizeWindow, @WindowSize())

InitWindowSelected()
EnableSVD()
DrawGrid()
AddWindowTimer(#MainWindow, #TimerId, TimerElapsedTime)
BindEvent(#PB_Event_Timer, @CodeCreateOnTimer())

Repeat   ;- Event Loop
  Select WaitWindowEvent()
    Case #PB_Event_CloseWindow
      Exit()

    Case #PB_Event_GadgetDrop
      If EventGadget() = #ScrollDrawArea
        X=WindowMouseX(#MainWindow)-GadgetX(#ScrollDrawArea) + GetGadgetAttribute(#ScrollDrawArea, #PB_ScrollArea_X) : Y=WindowMouseY(#MainWindow)-GadgetY(#ScrollDrawArea) + GetGadgetAttribute(#ScrollDrawArea, #PB_ScrollArea_Y)  ;Keep the coordinates of the mouse before creating the gadget
        CreateGadgets(EventDropText())
      EndIf

    Case #PB_Event_Menu   ;-> Event Menu
      Select EventMenu()
        Case 1 To ArraySize(ModelGadget())   ;Popup menu for creating gadgets
          Model = GetMenuItemText(#PopUpMenu, EventMenu())
          CreateGadgets(Model)

        Case #Shortcut_Delete   ;AddKeyboardShortcut is added on #PB_EventType_Focus and RemoveKeyboardShortcut on #PB_EventType_LostFocus in module, proc SVD_Callback
          If GetGadgetState(#ListGadgets) > 0
            GadgetsListElement = GetGadgetState(#ListGadgets)
            IdGadget=GetGadgetItemData(#ListGadgets, GadgetsListElement)
            RemoveGadgetItem(#TreeControls, GadgetsListElement)
            RemoveGadgetItem(#ListGadgets, GadgetsListElement)
            DeleteSVDGadget(IdGadget)
            InitWindowSelected()
          EndIf

        Case #Shortcut_Escape
          RemoveKeyboardShortcut(#RenameGadgetWindow, #PB_Shortcut_Escape)
          RemoveKeyboardShortcut(#RenameGadgetWindow, #PB_Shortcut_Return)
          CloseWindow(#RenameGadgetWindow)

        Case #Shortcut_Return
          GadgetsListElement = GetGadgetState(#ListGadgets)
          IdGadget=GetGadgetItemData(#ListGadgets, GadgetsListElement)
          RenameGadget(IdGadget)
      EndSelect

    Case #PB_Event_Gadget   ;-> Event Gadget
      If EventWindow()=#MainWindow
        Select EventGadget()
          Case #EnableSVD
            Select GetGadgetState(#EnableSVD)
              Case #True
                SetGadgetText(#EnableSVD, "Designer")
                UnbindEvent(#PB_Event_Timer, @CodeCreateOnTimer())
                RemoveWindowTimer(#MainWindow, #TimerId)
                ShowGrid = #False
                DrawGrid()
                CompilerIf #PB_Compiler_OS = #PB_OS_Linux : RemoveKeyboardShortcut(#MainWindow, #PB_Shortcut_Insert) : CompilerEndIf   ;Insert key as Right Click replacement under Linux
                HideGadget(#SettingContainer,#True)
                HideGadget(#GadgetList,#True)
                HideGadget(#PropertiesContainer,#True)
                HideGadget(#PanelControls,#True)
                HideGadget(#Constants,#True)
                SetGadgetState(#EnableSVD, #True)
                DisableSVD()

              Case #False   ;EnableSVD Parameters: drawing area, Drag Space
                SetGadgetText(#EnableSVD, "Preview")
                AddWindowTimer(#MainWindow, #TimerId, TimerElapsedTime)   ;Timer 60 s
                BindEvent(#PB_Event_Timer, @CodeCreateOnTimer())
                ShowGrid = GetGadgetState(#ShowGrid)
                DrawGrid()
                CompilerIf #PB_Compiler_OS = #PB_OS_Linux : AddKeyboardShortcut(#MainWindow, #PB_Shortcut_Insert, #Shortcut_Insert) : CompilerEndIf   ;Insert key as Right Click replacement under Linux
                InitWindowSelected()
                HideGadget(#SettingContainer,#False)
                HideGadget(#GadgetList,#False)
                HideGadget(#PropertiesContainer,#False)
                HideGadget(#PanelControls,#False)
                HideGadget(#Constants,#False)
                SetGadgetState(#EnableSVD, #False)
                EnableSVD()
            EndSelect

          Case #CodeCreate   ;Générate code Included in CodeCreate.pb
            CodeCreateForm()

          Case #ListGadgets
            If GetGadgetState(#ListGadgets) = 0
              SetActiveGadget(#DrawArea)
              SetActiveDrawAera()
              InitWindowSelected()
            Else
              IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
              SelectSVDGadget(IdGadget)
            EndIf

          Case #TreeControls
            If GetGadgetState(#TreeControls) = 0
              SetActiveGadget(#DrawArea)
              SetActiveDrawAera()
              InitWindowSelected()
            Else
              IdGadget=GetGadgetItemData(#TreeControls, GetGadgetState(#TreeControls))
              SelectSVDGadget(IdGadget)
            EndIf

          Case #RenameGadgetButton
            GadgetsListElement = GetGadgetState(#ListGadgets)
            IdGadget=GetGadgetItemData(#ListGadgets, GadgetsListElement)
            RenameGadgetForm(IdGadget)

          Case #DeleteGadgetButton
            If GetGadgetState(#ListGadgets) > 0
              GadgetsListElement = GetGadgetState(#ListGadgets)
              IdGadget=GetGadgetItemData(#ListGadgets, GadgetsListElement)
              RemoveGadgetItem(#TreeControls, GadgetsListElement)
              RemoveGadgetItem(#ListGadgets, GadgetsListElement)
              DeleteSVDGadget(IdGadget)
              InitWindowSelected()
            EndIf

          Case #CreateControlsList   ;Element beging at 0 -> Element+1
            Select EventType()
              Case #PB_EventType_LeftDoubleClick
                ParentPosDim()
                X = MinX + DragSpace : Y = MinY + DragSpace   ;coordinates for creating gadget inside #ScrollDrawArea
                Model = GetGadgetItemText(#CreateControlsList, GetGadgetState(#CreateControlsList))
                CreateGadgets(Model)
              Case #PB_EventType_DragStart
                Model = GetGadgetItemText(#CreateControlsList, GetGadgetState(#CreateControlsList))
                DragText(Model)
            EndSelect

          Case #DragSpace : DragSpace = GetGadgetState(#DragSpace)

          Case #ShowGrid : ShowGrid = GetGadgetState(#ShowGrid) : DrawGrid()

          Case #GridSize
            GridSize = GetGadgetState(#GridSize)
            If ShowGrid = #True And GetGadgetState(#EnableSVD) = #False   ;Not to call it the first time on Linux
              DrawGrid()
            EndIf

          Case #AddMenu : AddMenu = GetGadgetState(#AddMenu) : DrawGrid()
          Case #AddPopupMenu : AddPopupMenu = GetGadgetState(#AddPopupMenu)
          Case #AddToolBar : AddToolBar = GetGadgetState(#AddToolBar) : DrawGrid()
          Case #AddStatusBar : AddStatusBar = GetGadgetState(#AddStatusBar) : DrawGrid()

          Case  #SetDrawWidth
            If GetGadgetState(#ListGadgets) = 0 : InitWindowSelected() : EndIf
            If EventType() = #PB_EventType_Change And IsGadget(#ScrollDrawArea)
              ResizeDrawArea(GetGadgetState(#SetDrawWidth), GetGadgetState(#SetDrawHeight))
            EndIf

          Case #SetDrawHeight
            If GetGadgetState(#ListGadgets) = 0 : InitWindowSelected() : EndIf
            If EventType() = #PB_EventType_Change And IsGadget(#ScrollDrawArea)
              ResizeDrawArea(GetGadgetState(#SetDrawWidth), GetGadgetState(#SetDrawHeight))
            EndIf

          Case #HideGadget
            IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
            If FindMapElement(SVDListGadget(), Str(IdGadget))
              SVDListGadget()\Hide = GetGadgetState(#HideGadget)
              HideSVDGadget(IdGadget)
            EndIf

          Case #DisableGadget
            IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
            If FindMapElement(SVDListGadget(), Str(IdGadget))
              SVDListGadget()\Disable = GetGadgetState(#DisableGadget)
              CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
                If SVDListGadget()\DrawGadget = #False : DisableGadget(IdGadget, SVDListGadget()\Disable) : EndIf
              CompilerEndIf
              SelectSVDGadget(IdGadget)
            EndIf

          Case #LockGadget
            IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
            If FindMapElement(SVDListGadget(), Str(IdGadget))
              SVDListGadget()\Lock = GetGadgetState(#LockGadget)
              DisableGadget(#PosGadgetX, SVDListGadget()\Lock)
              DisableGadget(#PosGadgetY, SVDListGadget()\Lock)
              DisableGadget(#PosGadgetWidth, SVDListGadget()\Lock)
              DisableGadget(#PosGadgetHeight, SVDListGadget()\Lock)
            EndIf

          Case #PosGadgetX
            If EventType() = #PB_EventType_Change And GetGadgetState(#ListGadgets) > 0
              IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
              ResizeSVDGadget(IdGadget, GetGadgetState(#PosGadgetX), -1, -1, -1)
            EndIf

          Case #PosGadgetY
            If EventType() = #PB_EventType_Change And GetGadgetState(#ListGadgets) > 0
              IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
              If AddMenu = #True
                ResizeSVDGadget(IdGadget, -1, GetGadgetState(#PosGadgetY)+AddMenuHeight, -1, -1)
              Else
                ResizeSVDGadget(IdGadget, -1, GetGadgetState(#PosGadgetY), -1, -1)
              EndIf
            EndIf

          Case #PosGadgetWidth
            If EventType() = #PB_EventType_Change
              If GetGadgetState(#ListGadgets) = 0
                SetGadgetState(#SetDrawWidth, GetGadgetState(#PosGadgetWidth))
                ResizeDrawArea(GetGadgetState(#SetDrawWidth), GetGadgetState(#SetDrawHeight))
              Else
                IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
                ResizeSVDGadget(IdGadget, -1, -1, GetGadgetState(#PosGadgetWidth), -1)
                If IsGadget(IdGadget) And GadgetType(IdGadget) = 33 And GetGadgetText(#ImageString) <> "0" And GetGadgetText(#ImageString) <> ""
                  TmpImage = LoadImage(#PB_Any, GetGadgetText(#ImageString))
                  If TmpImage
                    ResizeImage(TmpImage, GetGadgetState(#PosGadgetWidth), GetGadgetState(#PosGadgetHeight))
                    SetGadgetAttribute(IdGadget, #PB_Canvas_Image, ImageID(TmpImage))
                    FreeImage(TmpImage)
                  EndIf
                EndIf
              EndIf
            EndIf

          Case #PosGadgetHeight
            If EventType() = #PB_EventType_Change
              If GetGadgetState(#ListGadgets) = 0
                SetGadgetState(#SetDrawHeight, GetGadgetState(#PosGadgetHeight))
                ResizeDrawArea(GetGadgetState(#SetDrawWidth), GetGadgetState(#SetDrawHeight))
              Else
                IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
                ResizeSVDGadget(IdGadget, -1, -1, -1, GetGadgetState(#PosGadgetHeight))
                If IsGadget(IdGadget) And GadgetType(IdGadget) = 33 And GetGadgetText(#ImageString) <> "0" And GetGadgetText(#ImageString) <> ""
                  TmpImage = LoadImage(#PB_Any, GetGadgetText(#ImageString))
                  If TmpImage
                    ResizeImage(TmpImage, GetGadgetState(#PosGadgetWidth), GetGadgetState(#PosGadgetHeight))
                    SetGadgetAttribute(IdGadget, #PB_Canvas_Image, ImageID(TmpImage))
                    FreeImage(TmpImage)
                  EndIf
                EndIf
              EndIf
            EndIf

          Case #ParentPick
            MessageRequester("SweetyVD Information", "Todo, If (and when) free time will allow" +#CRLF$+#CRLF$+ "Source is opened for any contribution ;)", #PB_MessageRequester_Info|#PB_MessageRequester_Ok)

            ;->> Event Gadget Properties
          Case #CaptionString
            If EventType() = #PB_EventType_Change
              IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
              If FindMapElement(SVDListGadget(), Str(IdGadget))
                If IsWindow(IdGadget)
                  SVDListGadget()\Caption = "#Text:" + GetGadgetText(#CaptionString)
                Else
                  SVDListGadget()\Caption = "#Text:" + GetGadgetText(#CaptionString)
                  Select Left(SVDListGadget()\Caption, 5)
                    Case "#Text"
                      If SVDListGadget()\DrawGadget = #False
                        SetGadgetText(IdGadget, GetGadgetText(#CaptionString))
                      Else
                        SetDrawGadgetAttribute(IdGadget)
                      EndIf
                      If SVDListGadget()\Type = 50   ;Custom Gadget (Canvas, GadgetType 33)
                        If StartDrawing(CanvasOutput(IdGadget))
                          Box(0, 0, OutputWidth(), OutputHeight(), $FFFFFF)
                          DrawText(5, 5, GetGadgetText(#CaptionString), #Blue, #White)
                          StopDrawing()
                        EndIf
                      EndIf

                    Case "#Date"
                      SVDListGadget()\Caption = "#Date:" + GetGadgetText(#CaptionString)
                      If GetGadgetText(#CaptionString) <> ""
                        If SVDListGadget()\DrawGadget = #False
                          SetGadgetText(IdGadget, GetGadgetText(#CaptionString))
                        Else
                          SetDrawGadgetAttribute(IdGadget)
                        EndIf
                      EndIf

                    Case "#Dir$"
                      SVDListGadget()\Caption = "#Dir$:" + GetGadgetText(#CaptionString)
                      If SVDListGadget()\DrawGadget = #False
                        SetGadgetText(IdGadget, GetGadgetText(#CaptionString))
                      Else
                        SetDrawGadgetAttribute(IdGadget)
                      EndIf

                    Case "#Url$"
                      SVDListGadget()\Caption = "#Url$:" + GetGadgetText(#CaptionString)
                      If SVDListGadget()\DrawGadget = #False
                        SetGadgetText(IdGadget, GetGadgetText(#CaptionString))
                      Else
                        SetDrawGadgetAttribute(IdGadget)
                      EndIf

                    Case "#TabN"
                      SVDListGadget()\Caption = "#TabN:" + GetGadgetText(#CaptionString)
                      If SVDListGadget()\Type = 40   ;Specific TabBar Gadget
                        SetTabBarGadgetItemText(IdGadget, 0, GetGadgetText(#CaptionString))
                      Else
                        If SVDListGadget()\DrawGadget = #False
                          SetGadgetText(IdGadget, GetGadgetText(#CaptionString))
                        Else
                          SetDrawGadgetAttribute(IdGadget)
                        EndIf
                      EndIf
                  EndSelect
                EndIf
              EndIf
            EndIf

          Case #ToolTipString
            If EventType() = #PB_EventType_Change
              IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
              If FindMapElement(SVDListGadget(), Str(IdGadget))
                SVDListGadget()\ToolTip = GetGadgetText(#ToolTipString)
              EndIf
            EndIf

          Case #MiniString
            If EventType() = #PB_EventType_Change
              IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
              If FindMapElement(SVDListGadget(), Str(IdGadget))
                SVDListGadget()\Option1 = "#Mini:"+GetGadgetText(#MiniString)
                If SVDListGadget()\DrawGadget = #False
                  SetGadgetAttribute(IdGadget, #PB_Spin_Minimum, Val(GetGadgetText(#MiniString)))
                  If SVDListGadget()\Model = "ProgressBarGadget" Or SVDListGadget()\Model = "SpinGadget" Or SVDListGadget()\Model = "TrackBarGadget"
                    SetGadgetState(IdGadget, Val(GetGadgetText(#MiniString))+(Val(GetGadgetText(#MaxiString))-Val(GetGadgetText(#MiniString)))*2/3)
                  EndIf
                Else
                  SetDrawGadgetAttribute(IdGadget)
                EndIf
              EndIf
            EndIf
            ;If EventType() = #PB_EventType_LostFocus   ;No control for easy entry, with Maxi = 0)
            ;If Val(GetGadgetText(#MiniString)) > Val(GetGadgetText(#MaxiString)) : SetGadgetText(#MiniString, GetGadgetText(#MaxiString)) : EndIf
            ;EndIf

          Case #MaxiString
            If EventType() = #PB_EventType_Change
              IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
              If FindMapElement(SVDListGadget(), Str(IdGadget))
                SVDListGadget()\Option2 = "#Maxi:"+GetGadgetText(#MaxiString)
                If SVDListGadget()\DrawGadget = #False
                  SetGadgetAttribute(IdGadget, #PB_Spin_Maximum, Val(GetGadgetText(#MaxiString)))
                  If SVDListGadget()\Model = "ProgressBarGadget" Or SVDListGadget()\Model = "SpinGadget" Or SVDListGadget()\Model = "TrackBarGadget"
                    SetGadgetState(IdGadget, Val(GetGadgetText(#MiniString))+(Val(GetGadgetText(#MaxiString))-Val(GetGadgetText(#MiniString)))*2/3)
                  EndIf
                Else
                  SetDrawGadgetAttribute(IdGadget)
                EndIf
              EndIf
            EndIf

            If EventType() = #PB_EventType_LostFocus
              If Val(GetGadgetText(#MaxiString)) < Val(GetGadgetText(#MiniString))
                SVDListGadget()\Option2 = "#Maxi:"+GetGadgetText(#MiniString)
                If SVDListGadget()\DrawGadget = #False
                  SetGadgetText(#MaxiString, GetGadgetText(#MiniString))
                Else
                  SetDrawGadgetAttribute(IdGadget)
                EndIf
              EndIf
            EndIf

          Case #ImagePick
            IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
            ;FindMapElement(SVDListGadget(), Str(IdGadget))
            If IsGadget(IdGadget) : DrawSelectedImage(IdGadget) : EndIf
            SelectSVDGadget(IdGadget)

          Case #FontPick
            IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
            SelectFont(IdGadget)

          Case #FrontColorPick
            IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
            CompilerIf #PB_Compiler_OS = #PB_OS_Windows
              SelectedColor = FullColorRequester(WindowX(#MainWindow)+220, WindowY(#MainWindow)+245)
            CompilerElse
              SelectedColor = ColorRequester()
            CompilerEndIf
            If SelectedColor = -1
              SetGadgetAttribute(#FrontColorPick, #PB_Button_Image, 0)
              If FindMapElement(SVDListGadget(), Str(IdGadget))
                SVDListGadget()\FrontColor = ""
                If SVDListGadget()\DrawGadget = #False
                  SetGadgetColor(IdGadget, #PB_Gadget_FrontColor, #PB_Default)
                EndIf
              EndIf
            Else
              If StartDrawing(ImageOutput(#FrontColorImg))
                Box(0, 0, OutputWidth(), OutputHeight(), SelectedColor)
                StopDrawing()
                SetGadgetAttribute(#FrontColorPick, #PB_Button_Image, ImageID(#FrontColorImg))
                If FindMapElement(SVDListGadget(), Str(IdGadget))
                  SVDListGadget()\FrontColor = Str(SelectedColor)
                  If SVDListGadget()\DrawGadget = #False
                    SetGadgetColor(IdGadget, #PB_Gadget_FrontColor, SelectedColor)
                  EndIf
                EndIf
              EndIf
            EndIf

          Case #BackColorPick
            IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
            CompilerIf #PB_Compiler_OS = #PB_OS_Windows
              SelectedColor = FullColorRequester(WindowX(#MainWindow)+220, WindowY(#MainWindow)+245)
            CompilerElse
              SelectedColor = ColorRequester()
            CompilerEndIf
            If SelectedColor = -1
              SetGadgetAttribute(#BackColorPick, #PB_Button_Image, 0)
              If FindMapElement(SVDListGadget(), Str(IdGadget))
                SVDListGadget()\BackColor = ""
                If IsWindow(IdGadget)
                  WinBackColor = 0 : DrawGrid()
                Else
                  If SVDListGadget()\DrawGadget = #False
                    SetGadgetColor(IdGadget, #PB_Gadget_BackColor, #PB_Default)
                  EndIf
                EndIf
              EndIf
            Else
              If StartDrawing(ImageOutput(#BackColorImg))
                Box(0, 0, OutputWidth(), OutputHeight(), SelectedColor)
                StopDrawing()
                SetGadgetAttribute(#BackColorPick, #PB_Button_Image, ImageID(#BackColorImg))
                If FindMapElement(SVDListGadget(), Str(IdGadget))
                  SVDListGadget()\BackColor = Str(SelectedColor)
                  If IsWindow(IdGadget)
                    WinBackColor = SelectedColor : DrawGrid()
                  Else
                    If SVDListGadget()\DrawGadget = #False
                      SetGadgetColor(IdGadget, #PB_Gadget_BackColor, SelectedColor)
                    EndIf
                  EndIf
                EndIf
              EndIf
            EndIf

          Case #Constants
            If EventType() = #PB_EventType_Change
              IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
              If FindMapElement(SVDListGadget(), Str(IdGadget))
                TmpConstants = ""
                For I=0 To CountGadgetItems(#Constants)-1
                  If TmpConstants <> ""
                    TmpConstants + "|"
                  EndIf
                  TmpConstants + GetGadgetItemText(#Constants, I)
                  If GetGadgetItemState(#Constants, I) & #PB_Tree_Checked
                    TmpConstants + "(x)"
                  EndIf
                Next
                SVDListGadget()\Constants = TmpConstants
              EndIf
            EndIf

        EndSelect   ;#PB_Event_Gadget #MainWindow
      EndIf

      If EventWindow()=#CodeForm   ;-> Code Create window
        Select EventGadget()
          Case #AboutButton
            CloseWindow(#CodeForm)
            AboutForm()
          Case #CodeCancel
            CloseWindow(#CodeForm)
          Case #CodeNewTab
            CodeCreate("NewTab")
          Case #CodeSave
            CodeCreate("Save")
          Case #CodeClipboard
            CodeCreate("Clipboard")
        EndSelect
      EndIf

      If EventWindow()=#RenameGadgetWindow   ;-> Rename Gadget window
        If EventGadget() = #RenameGadgetCancel
          RemoveKeyboardShortcut(#RenameGadgetWindow, #PB_Shortcut_Escape)
          RemoveKeyboardShortcut(#RenameGadgetWindow, #PB_Shortcut_Return)
          CloseWindow(#RenameGadgetWindow)
        EndIf
        If EventGadget() = #RenameGadgetOK
          GadgetsListElement = GetGadgetState(#ListGadgets)
          IdGadget=GetGadgetItemData(#ListGadgets, GadgetsListElement)
          RenameGadget(IdGadget)
        EndIf
      EndIf

      If EventWindow()=#AboutForm   ;-> About Form window
        Select EventGadget()
          Case #AboutBack
            CloseWindow(#AboutForm)
            CodeCreateForm()
        EndSelect
      EndIf

      Select EventType()   ;-> Receives Module Events
        Case  #SVD_Gadget_Focus
          *PosDim = EventData()
          ;Debug Str(EventGadget())+" : "+Str(*PosDim\X)+" - "+Str(*PosDim\Y)+" - "+Str(*PosDim\Width)+" - "+Str(*PosDim\Height)
          ;Assign the global counter gadget to this new gadget
          For I=0 To CountGadgetItems(#ListGadgets)
            If GetGadgetItemData(#ListGadgets, I) = EventGadget()
              SetGadgetState(#ListGadgets,I)
              SetGadgetState(#TreeControls,I)
              Break
            EndIf
          Next
          SetGadgetState(#PosGadgetX, *PosDim\X)
          If AddMenu = #True
            SetGadgetState(#PosGadgetY, *PosDim\Y-AddMenuHeight)
          Else
            SetGadgetState(#PosGadgetY, *PosDim\Y)
          EndIf
          SetGadgetState(#PosGadgetWidth, *PosDim\Width)
          SetGadgetState(#PosGadgetHeight, *PosDim\Height)
          LoadGadgetProperties(EventGadget())

        Case #SVD_Gadget_LostFocus

        Case #SVD_Gadget_Resize
          If GetGadgetState(#EnableSVD) = #False   ;Designer mode. The TabBar Gadget is resized on click on the preview mode. Thanks JHPJHP
            *PosDim = EventData()
            SetGadgetState(#PosGadgetX, *PosDim\X)
            If AddMenu = #True
              SetGadgetState(#PosGadgetY, *PosDim\Y-AddMenuHeight)
            Else
              SetGadgetState(#PosGadgetY, *PosDim\Y)
            EndIf
            SetGadgetState(#PosGadgetWidth, *PosDim\Width)
            SetGadgetState(#PosGadgetHeight, *PosDim\Height)
            If GetGadgetText(#ImageString) <> "0" And GetGadgetText(#ImageString) <> ""
              If IsGadget(EventGadget()) And GadgetType(EventGadget()) = 33
                TmpImage = LoadImage(#PB_Any, GetGadgetText(#ImageString))
                If TmpImage
                  ResizeImage(TmpImage, *PosDim\Width, *PosDim\Height)
                  SetGadgetAttribute(EventGadget(), #PB_Canvas_Image, ImageID(TmpImage))
                  FreeImage(TmpImage)
                EndIf
              EndIf
            EndIf
          EndIf

        Case  #SVD_Window_Focus
          If GetGadgetState(#EnableSVD) = #False ;And MouseOverDrawArea() = #True
            InitWindowSelected()
          EndIf

        Case #SVD_Window_ReSize
          *PosDim = EventData()
          SetGadgetState(#SetDrawWidth, *PosDim\Width)
          SetGadgetState(#SetDrawHeight, *PosDim\Height)
          If GetGadgetState(#ListGadgets) = 0
            SetGadgetState(#PosGadgetWidth, *PosDim\Width)
            SetGadgetState(#PosGadgetHeight, *PosDim\Height)
          EndIf
          ResizeDrawArea(GetGadgetState(#SetDrawWidth), GetGadgetState(#SetDrawHeight))

        Case #SVD_DrawArea_RightClick
          If GetGadgetState(#EnableSVD) = #False And  MouseOverDrawArea() = #True
            X=WindowMouseX(#MainWindow)-GadgetX(#ScrollDrawArea) + GetGadgetAttribute(#ScrollDrawArea, #PB_ScrollArea_X) : Y=WindowMouseY(#MainWindow)-GadgetY(#ScrollDrawArea) + GetGadgetAttribute(#ScrollDrawArea, #PB_ScrollArea_Y)  ;Keep the coordinates of the mouse before creating the gadget
            DisplayPopupMenu(#PopUpMenu,WindowID(#MainWindow))
          EndIf

        Case #SVD_DrawArea_Focus
          If GetGadgetState(#EnableSVD) = #False ;And MouseOverDrawArea() = #True
            InitWindowSelected()
          EndIf

      EndSelect   ;EventType()
  EndSelect
ForEver

Procedure Exit()
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    ExitColorPrefs()
  CompilerEndIf
  RemoveWindowTimer(#MainWindow, #TimerId)
  FreeArray(ModelGadget())
  ExitPrefs()
  End   ;Do I need to free things?
EndProcedure

DataSection   ;- Data Section (Model)
  #Img_Rename:
  Data.q $0A1A0A0D474E5089,$524448490D000000,$0E0000000E000000,$2D481F0000000608,$47527301000000D1,$0000E91CCEAE0042,$0000414D41670400,$00000561FC0B8FB1,$0000735948700900,$C701C30E0000C30E,$741900000064A86F,$7774666F53745845,$6E69617000657261,$2E342074656E2E74,$F5AF694436312E30
  Data.q $54414449F7010000,$0404040620634F38,$EBB7DCE5359FADA8,$633D6EB06F7EDF07,$FCFC0DC2950AC0CC,$DDF4F198CC67D4FC,$7FF9DAEF77FF77BB,$73C2BAA5FFE8766B,$FA88485F81D8D2A1,$FEFF7FBE9EB399CC,$555557FFFBFDFEFF,$A0675FF86968EFFD,$7DEC041304AA09F8,$8DDEE3D4E939ACA9,$657FEBB6D86FFF57
  Data.q $49FFAA86D6FFE565,$A1F29D3C93FF5E91,$3ECAEFADF54150CA,$3FECF05A923C3E47,$FEF321BAFFA5D453,$FB75084FFCD7D6D7,$0A86550DD1191D1F,$FBE7735CAEFCBC16,$3DB533FE9FE3F723,$C5B33FF17010CFFC,$2263FFC14E76FFBE,$D0334150CAA0BB82,$FF5CE51E3FBBC6A6,$B90CFFABF5605FFA,$A6CFFD9E07B3FEB7
  Data.q $AA13BF28C45FFCD5,$B41CA97B6F84150C,$8BFE1F93C0A3FDFF,$7FF6F6A19FFE786E,$FC676DB9FF8BF896,$05432A836BEE3667,$F87CCCE92A1ED326,$D7BD6CFF83E17D48,$E670979D021433FF,$0B76CCFFFCCD8B3F,$2D37C7FD81026BB1,$9ECC533FED74DFAC,$EF7933FE3BFE0CFF,$C3B33FF73162CFFA,$F967AFFFFE9ADC52
  Data.q $FDA75BDDDBF960F1,$E562C99FF75F7167,$E72D99FFC99D667F,$3B34AFDF0204D6E3,$C5AF7EFFF1DF397D,$1B6D35FF7A1175FF,$E34A876F4D1AB3FF,$3F387E4EF78B7D06,$823B67F554A9FFE8,$DDAD4536C727E7B5,$27A273B9D0EC5479,$E711E8F63BE2DD6E,$4011CAA199FFFFFF,$586E747A6F4B6A35,$B5AB29A6CD6CCD66
  Data.q $7ED369B4A2DD2DA7,$19930170CE674D91,$601229542313500B,$E5ACF0F923000060,$49000000003AC95C
  Data.b $45,$4E,$44,$AE,$42,$60,$82

  #Img_Delete:
  Data.q $A1A0A0D474E5089,$524448490D000000,$E0000000E000000,$2D481F0000000608,$47527301000000D1,$E91CCEAE0042,$414D41670400,$561FC0B8FB1,$735948700900,$C701C30E0000C30E,$741900000064A86F,$7774666F53745845,$6E69617000657261,$2E342074656E2E74,$7A5B033433312E30
  Data.q $5441444991020000,$6153485D526D4F38,$AC1FA22E81FAFE18,$C6E6739D9D72E3B6,$175B34E8EDBFCE9C,$1A0FE51AC2932061,$CF368A9494586EA2,$2EC428933697358E,$41FD855D108298D2,$1B461A071BC2E82C,$A5285D578127538A,$5129A3BEFB78BBFB,$BCFBCF7EF177CDCF,$761CA75448BCFBCF
  Data.q $62EB998C0F3D341B,$1768A3E9A443BAA6,$8E51A3D9429C9C7B,$FEBC8C8BAE4E6AF7,$C93078AA507E5C8E,$5E10FA7A5B16B8EF,$AD7DE90DB98A5CD5,$A5903BC8D48A09F4,$7A4D6626319FF31E,$104A2A5D372AD518,$B0756958BC8BDA11,$5DFA4400F0C7E1F,$B5F68E82E3175513,$FEC798337BD3C7B1
  Data.q $53210C52C84492D2,$5A8A9EE068E54C2E,$DEF1E3723F682D13,$EAB0DD03AB62DAD6,$BD5FDE13708880ED,$5B2F26A768E4F490,$4C0B0429595CE7F,$86E55AE787AF9D3,$F17A9E245245ACB4,$5BBBDFE22A6B1F78,$F04DDBE580E9C560,$682057D5C21AA1AD,$10DA9D2616526336,$F248763DA6D1CA59
  Data.q $AE7DE3C7DCBC4048,$56F961DAB4AE48AE,$8162C843D5352C23,$A25154E9F06CA62F,$EF3919DA0FE917F4,$7CB0B5EC86BEA9D6,$46F20872D6730EDD,$D97B2D2EE0E06D78,$AD83BAFEDB494EAE,$E4D66C9FE355EB95,$AF926CD82C237362,$620C367C021E02F9,$1BB23AA38E5A4EC5,$6DF98ED1CA3D2115
  Data.q $56542C3B66C589E5,$6706F06F08D9B4C2,$6154C3C45C20F30A,$76A19398D9E90C2E,$B28A87EE1C2E42A2,$10B575C20386F844,$58BA8983386198B0,$8C8BA745C99233CA,$C877E0084292910,$FB421B3ECAC71E9,$2C1D636CFAECF479,$D21859FCE0403536,$2217216B2B021B31,$4CD89AD9231DA9B0
  Data.q $3E7144E1B8F30F09,$B4DA8A395BA9B174,$839EB49CDF859F7A,$3C4E5776930E7A67,$FE2E9E45EFA29C89,$4EAFD53ABC09B4EE,$7674882F78055646,$8561AC539BA10AB1,$3EA971753C4E567F,$FAB513D211AD4B27,$E44097C6770976C0,$975227880FF88BA5,$1C285E1BF4202494,$5DDBFE0391
  Data.q $6042AE444E454900,$82

  #Img_About:
  Data.q $A1A0A0D474E5089,$524448490D000000,$1200000012000000,$8ECE560000000608,$4752730100000057,$E91CCEAE0042,$414D41670400,$561FC0B8FB1,$735948700900,$C701C30E0000C30E,$741900000064A86F,$7774666F53745845,$6E69617000657261,$2E342074656E2E74,$7A5B033433312E30
  Data.q $54414449F2010000,$D2D38C05C0634F38,$7D705039E3E3ED58,$CC6C60489A540B3D,$7D3E0F75C3DEE3BA,$FA2007E7D3F0F07A,$500E6D74BC2F1036,$2F2F200888A20996,$FFF78BB3E9EBB1CF,$F1026F88077FFFFF,$A03EC6E9719E2025,$D068003115442B34,$3E6A009D2F4FC79A,$FFDFD378807BC40C
  Data.q $B9A0DD235ECE5BFF,$CD60340CDC5D9E8F,$7FFFF9FD17FFFFBF,$215D0EF3FFFFF7EA,$FBBEEF6060620D1,$FFF7E5321A07CE8F,$F9792FFFFF5F1DFF,$72809BE3CADFBFEF,$ABABF9C573380524,$FFF9F75FFFFD7F7B,$FB1CBBFE7F87F8FF,$1CA034D365A8DFF1,$8FBB998C040D81F1,$CEE83FF7F87F17F7
  Data.q $7ED6CC4340CEFF9F,$4F2A12BB3D95AFFA,$D6FFD0A9BB99F03C,$9AD7FF3EEB21886F,$54345D604ABFFAF6,$F9D8393550E0789A,$57FEDFD3218877C8,$16D82CD14FF07FA8,$B337480FD03C4D2A,$C6F910C81FEEFD5C,$9514FC2FD325FFE7,$B4A40F134A8150B1,$2A52BF4EDBF5656D,$F157C4E52255FF3F
  Data.q $A184A57979778D80,$2E634949460124D2,$1E7B51511E7B2D51,$1229106241B2006,$F46D354473C7DBD8,$736BBCB02DB09AA9,$108B191F72DE4060,$4E3AD340F134A84E,$6F45B2BFE1E3BDDB,$F73CDFFD7BCE97FE,$34A83D5F1D453FDA,$E62C4F4230CD40F1,$82F9FF1B90BE3FEA,$524FFF3BF6E7FC6F
  Data.q $D4503C4D2A08DDC3,$CF94F2DEF31354F3,$F8DB7016104BEB7D,$124D2A1345D54254,$E0E0E294E4E4E160,$6241A5B20610790,$105000C0C074291,$179F04224BF0,$42AE444E45490000,$8260

  #Vd_Unknow:
  Data.q $0A1A0A0D474E5089,$524448490D000000,$1000000010000000,$FFF31F0000000608,$4144496B01000061,$3010A06463DA7854,$CCD4A5CFBB658882,$C4DC4F8BDEE132DC,$1F949864E0111268,$A41187346AE51A98,$DE999D5523EAE279,$ED7AD9444A06F68A,$F3F755F6A4864BC1,$FE9A429518DA6D43
  Data.q $0C335620628AADCF,$396DB9219770BC1C,$EC1EFFFF25360BD0,$1F80C92264646060,$0C4134797030BEDF,$9595958199A7B1F8,$3FE54281103FE181,$7FFFC31313132142,$1FFFF89405A180FF,$E22B017EBFDF6A1C,$03576DF018856AF1,$0B0B23581B2B0B03,$EA81BFBFDFE3580B,$FB7C0818987CE119
  Data.q $0CC276FBF34C09F2,$1CB300C2C4DA07A8,$3E03500CA24811CD,$5F01885E80A16980,$20DFEFFFE492D7B6,$C5E031089E0D102E,$19FBF8600C920A9A,$70F018854F84494C,$81BF1859FA492169,$ADC0620B351D25BD,$1DFAC1C01924D979,$F1146063CEC5CB4C,$9C4197DABABFFDA9,$CC7F3C1E4324805F
  Data.q $A3949401807FD710,$31D7F62D2AEC96BA,$E7EDF34A24125630,$1E54B85D96EA191F,$CCC0514CCB09D1E7,$6067A5444CCC0CD4,$CCC0F94CCC037A66,$0000F80D18918CB4,$EFF21D717890888A,$444E454900000000
  Data.b $AE,$42,$60,$82

  #Vd_Custom:
  Data.q $0A1A0A0D474E5089,$524448490D000000,$1000000010000000,$FFF31F0000000608,$4752730100000061,$0000E91CCEAE0042,$0000414D41670400,$00000561FC0B8FB1,$0000735948700900,$C701C30E0000C30E,$741900000064A86F,$7774666F53745845,$6E69617000657261,$2E342074656E2E74
  Data.q $4FFE60DD35312E30,$5441444927020000,$5113684B93AD4F38,$48A2316A17078614,$373BA08A5C6E2A37,$4685F15882A9B95D,$2890483084A218A2,$F112D051B1569455,$52D2695D0889456D,$4892D62924351749,$64D1E4EE6C6A04D3,$EB18E931B1353692,$2EA15BC5B99BF1E4,$FF3DCCCCBBE07A02
  Data.q $F44BFEE5CE5CCE7F,$B8975F0F5B75F90E,$2855DF79A11A1316,$3DCC5EF675DE261A,$A2819E29F1A3451E,$A823F970CAF526A1,$F83832DAD0CB6AD5,$D1402FCB9EEBFC54,$586D856AD54B4A72,$E7B97459F6F04503,$E7405E5AC514C1B0,$FBFEE2CC1C5C57D0,$525FC5C5492BCB3C,$A95AA4D41F858596
  Data.q $6AC04E9C05F1DDA0,$A71FC7024B51C12D,$9113C337E81064D0,$064BF2756FC549E6,$6596432CB90492A5,$DE1874F2B1E48F74,$A6BE7C76C3331E50,$D2E08C65424918C7,$67C8513FCB94699B,$F6F42ED3CC187F29,$0E3B7038229B3469,$ADBC1C85EF86D871,$C29BD93835E411DB,$372E622AC681237A
  Data.q $AC72817CD2066143,$0C4B368278EB0A67,$B3C1B75B463D4E81,$53FBE717BD4F8389,$B228CDFF60867358,$C6393264198522B3,$F3BC610CAB110195,$76870F823BA7C04E,$E3759EC60565B3C3,$CC29C74BCC5C5385,$D14DF42E33489120,$831AC270139D5303,$6F701DBBBE0C75F1,$49D27345D47C10E6
  Data.q $E8CE242032590EA1,$3DB424C6EDA18BE8,$0F185D268C3E2A04,$E46CF04D9A3E0806,$428878C907787FE0,$0A10FA8D74B1940D,$7DA5A24CB1EC6591,$F97DE197CCFBBD82,$CAD23A4E9C3B3E9C,$CAFE35BA9E77AB28,$0FF44348C0A116F6,$DFDA2A0E6343B03A,$A96D28CB1F5D41F7,$C16FFC4CB395EA01
  Data.q $911380C5A500BF71,$49000000004FC404
  Data.b $45,$4E,$44,$AE,$42,$60,$82

  #Vd_Window:
  Data.q $0A1A0A0D474E5089,$524448490D000000,$1000000010000000,$FFF31F0000000608,$4752730100000061,$0000E91CCEAE0042,$0000414D41670400,$00000561FC0B8FB1,$0000735948700900,$C701C30E0000C30E,$741900000064A86F,$7774666F53745845,$6E69617000657261,$2E342074656E2E74
  Data.q $7A5B033433312E30,$544144490D010000,$FBB6580AA0634F38,$9B0617D348528A5C,$0C0D0943F0B8FF92,$79B3583FE75E477C,$8FFDDFCE077BA4DA,$F637E3065410BC0F,$00610C83620C60BE,$FFFF3BB9FF7FFCDA,$EB780CC31787FBFD,$FF7F79C8006A8216,$400CC31909AAC1FE,$1A477ABD5E0370C6
  Data.q $2203E1C18C1CF17E,$ECF17E124D7F3F9E,$F1F8F018463F1009,$F880F7C7B3F09273,$84931FF7FB80C22E,$6E0370C609BC3C9F,$3AFF747E12407EDF,$FFE6F57CB80DC318,$B9DFEF8D12EF379B,$8E0308F3B5FAFFFE,$44DBF5FAFFFF3E9E,$F4783FFE6E379BE3,$FBFFDA9F1100C430,$922DDAED7FFA9F8F
  Data.q $82F483FF7BBDB6F0,$C5F9C77C41947292,$5128E176BFFCB6EB,$DB63F5FF6DF6E378,$30145332C2F4822E,$B40C08893B05DF49,$01818065335C35F9,$B3553835ADCF4F00,$4E4549000000006C
  Data.b $44,$AE,$42,$60,$82

  ModelGadgets:   ;31 Gadgets Models +window Model
                  ;"Model","Order","GadgetType","Width","Height","Name","Caption","Option1","Option2","Option3","FrontColor","BackColor","ToolTip","Constants"
  Data.s "OpenWindow","0","","640","480","Window","#Text","","","","#Nooo","","#Nooo","Window_SystemMenu(x)|Window_MinimizeGadget(x)|Window_MaximizeGadget(x)|Window_SizeGadget(x)|Window_Invisible|Window_TitleBar|Window_Tool|Window_BorderLess|Window_ScreenCentered(x)|Window_WindowCentered|Window_Maximize|Window_Minimize|Window_NoGadgets"
  Data.s "ButtonGadget","1","1","100","20","Button","#Text","","","","#Nooo","#Nooo","","Button_Right|Button_Left|Button_Default|Button_MultiLine|Button_Toggle"
  Data.s "ButtonImageGadget","2","19","100","20","ButtonImage","","#Imag:0","","","#Nooo","#Nooo","","Button_Toggle"
  Data.s "CalendarGadget","3","20","220","160","Calendar","","#Date:0","","","#Nooo","#Nooo","","Calendar_Borderless"
  Data.s "CanvasGadget","4","33","140","40","Canvas","","","","","#Nooo","#Nooo","",""
  Data.s "CheckBoxGadget","5","4","100","20","Checkbox","#Text","","","","#Nooo","#Nooo","","CheckBox_Right|CheckBox_Center|CheckBox_ThreeState"
  Data.s "ComboBoxGadget","6","8","100","20","Combo","","","","","#Nooo","#Nooo","","ComboBox_Editable|ComboBox_LowerCase|ComboBox_UpperCase|ComboBox_Image"
  Data.s "ContainerGadget","7","11","300","200","Container","","","","","","","","Container_BorderLess|Container_Flat|Container_Raised|Container_Single|Container_Double"
  Data.s "DateGadget","8","21","120","20","Date","#Date","#Date","","","#Nooo","#Nooo","","Date_UpDown|Date_CheckBox"
  Data.s "EditorGadget","9","22","140","40","Editor","","","","","","","",""
  Data.s "ExplorerComboGadget","10","25","120","20","ExplorerCombo","#Dir$","","","","#Nooo","#Nooo","#Nooo","Explorer_DrivesOnly|Explorer_Editable|Explorer_NoMyDocuments"
  Data.s "ExplorerListGadget","11","23","160","80","ExplorerList","#Dir$","","","","","","","Explorer_NoMyDocuments|Explorer_BorderLess|Explorer_AlwaysShowSelection|Explorer_MultiSelect|Explorer_GridLines|Explorer_HeaderDragDrop|Explorer_FullRowSelect|Explorer_NoFiles|Explorer_NoFolders|Explorer_NoParentFolder|Explorer_NoDirect"
  Data.s "ExplorerTreeGadget","12","24","160","80","ExplorerTree","#Dir$","","","","","","","Explorer_BorderLess|Explorer_AlwaysShowSelection|Explorer_NoLines|Explorer_NoButtons|Explorer_NoFiles|Explorer_NoDriveRequester|Explorer_NoMyDocuments|Explorer_AutoSort"
  Data.s "FrameGadget","13","7","200","100","Frame","#Text","","","","#Nooo","#Nooo","#Nooo","Frame_Single|Frame_Double|Frame_Flat"
  Data.s "HyperLinkGadget","14","10","150","20","Hyperlink","#Url$:https://www.purebasic.fr/","#Hard:RGB(0,0,128)","","","","","","HyperLink_Underline"
  Data.s "ImageGadget","15","9","140","40","Image","","#Imag:0","","","#Nooo","#Nooo","","Image_Border"
  Data.s "IPAddressGadget","16","13","100","20","IPAddress","","","","","#Nooo","#Nooo","",""
  Data.s "ListIconGadget","17","12","140","40","ListIcon","","#Titl","#Widh:140","","","","","ListIcon_CheckBoxes|ListIcon_ThreeState|ListIcon_MultiSelect|ListIcon_GridLines|ListIcon_FullRowSelect|ListIcon_HeaderDragDrop|ListIcon_AlwaysShowSelection"
  Data.s "ListViewGadget","18","6","140","40","ListView","","","","","","","","ListView_MultiSelect|ListView_ClickSelect"
  Data.s "OpenGLGadget","19","34","100","20","OpenGL","","","","","#Nooo","#Nooo","","OpenGL_Keyboard"
  Data.s "OptionGadget","20","5","100","20","Option","#Text","","","","#Nooo","#Nooo","",""
  Data.s "PanelGadget","21","28","300","200","Panel","#TabN:Tab1(x)|Tab2|Tab3","","","","#Nooo","#Nooo","",""
  Data.s "ProgressBarGadget","22","14","140","12","ProgressBar","","#Mini:0","#Maxi:100","","","","","ProgressBar_Smooth|ProgressBar_Vertical"
  Data.s "ScintillaGadget","23","31","160","60","Scintilla","","#Hard:0","","","#Nooo","#Nooo","#Nooo",""
  Data.s "ScrollAreaGadget","24","16","300","200","ScrollArea","","#InrW:600","#InrH:400","#Step:10","#Nooo","","#Nooo","ScrollArea_Flat|ScrollArea_Raised|ScrollArea_Single|ScrollArea_BorderLess|ScrollArea_Center"
  Data.s "ScrollBarGadget","25","15","140","16","Scrollbar","","#Mini:0","#Maxi:100","#Long:0","#Nooo","#Nooo","","ScrollBar_Vertical"
  Data.s "SpinGadget","26","26","100","20","Spin","","#Mini:0","#Maxi:100","","","","","Spin_ReadOnly|Spin_Numeric(x)"
  Data.s "StringGadget","27","2","100","20","String","#Text","","","","","","","String_Numeric|String_Password|String_ReadOnly|String_LowerCase|String_UpperCase|String_BorderLess"
  Data.s "TextGadget","28","3","100","20","Text","#Text","","","","","","#Nooo","Text_Center|Text_Right|Text_Border"
  Data.s "TrackBarGadget","29","17","100","20","TrackBar","","#Mini:0","#Maxi:100","","","#Nooo","#Nooo","TrackBar_Ticks|TrackBar_Vertical"
  Data.s "TreeGadget","30","27","100","20","Tree","","","","","","","","Tree_AlwaysShowSelection|Tree_NoLines|Tree_NoButtons|Tree_CheckBoxes|Tree_ThreeState"
  Data.s "WebGadget","31","18","260","125","WebView","#Url$:https://www.purebasic.fr/","","","","#Nooo","#Nooo","#Nooo",""
  Data.s "TabBarGadget","32","40","140","27","TabBar","#TabN","","","","#Nooo","#Nooo","#Nooo","BottomLine(x)|CheckBox|CloseButton(x)|Editable|MirroredTabs|MultiLine|MultiSelect|NewTab|NoTabMoving|PopupButton|ReverseOrdering|SelectedCloseButton|TextCutting|Vertical"
EndDataSection
CompilerEndIf

; IDE Options = PureBasic 5.60 (Windows - x64)
; Folding = -------
; EnableXP
; Executable = SweetyVD.exe
; EnablePurifier