; ---------------------------------------------------------------------------------------
;           Name: SweetyVD
;    Description: Sweety Visual Designer
;     dependency: SweetyVDmodule.pbi (Sweety Visual Designer Module)
;         Author: ChrisR
;           Date: 2017-05-25
;        Version: 2.1.0.0
;     PB-Version: 5.60, 5.61,.., 5.71 (x86/x64) 
;                 On Linux Use PB 5.60 or 5.61, The gadgets are not Drawn over the Canvas with the following versions 5.62, 5.70, 5.71, otherwise it works   
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
  
  #BuildVersion = "2.1.0.0"
  
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
  
  Enumeration
    #MainWindow
    #TimerId
    #PopUpMenu
    #BackDesigner
    #ContainerSetting
    #DragText
    #ShowGrid
    #GridSize
    #SnapGrid
    #AddMenu
    #AddPopupMenu
    #AddToolBar
    #AddStatusBar
    #PreviewDesigner
    #CodeCreatePlay
    #CodeCreateNewTab
    #CodeCreateClipboard
    #CodeCreateSave
    #Group_Button
    #UnGroup_Button
    #Align_Left_Button
    #Align_Left_Text
    #Align_Right_Button
    #Align_Right_Text
    #Align_Top_Button
    #Align_Top_Text
    #Align_Bottom_Button
    #Align_Bottom_Text
    #Make_Same_Width_Button
    #Make_Same_Width_Text
    #Make_Same_Height_Button
    #Make_Same_Height_Text
    #SVDSetting
    #ContainerSize
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
    #ListControls
    #CreateControlsList
    #ContainerProperties
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
    ;Others
    #WinBarHeight
    #Shortcut_F2_Rename
    #Shortcut_F5_Play
    #Shortcut_F6_Preview
    #Shortcut_F7_NewTab
    #Shortcut_CtrlS_Save
    #Shortcut_F8_Clipboard
    #Shortcut_Ctrl_Group
    #Shortcut_Ctrl_UnGroup
    #Shortcut_CtrlLeft_Align
    #Shortcut_CtrlRight_Align
    #Shortcut_CtrlTop_Align
    #Shortcut_CtrlBottom_Align
    #Shortcut_Ctrl_Same_Width
    #Shortcut_Ctrl_Same_Height
    #Shortcut_Insert
    #Shortcut_Escape
    #Shortcut_Return
    #Separator0
    #Separator1
    #Separator2
    #Separator3
    #Separator4
    #Separator5
    #Separator6
    ;JSON Gadget templates file
    #JSONFile
  EndEnumeration
  
  ;Enumeration FormAbout
  ;EndEnumeration
  
  Enumeration 300 ;Rename Gadget Form
    #RenameForm
    #RenameGadgetFrom
    #RenameFormGadgetButton
    #DeleteFormGadgetButton
    #RenameGadgetString
    #RenameGadgetMsg
    #RenameGadgetOK
    #RenameGadgetCancel
    ;Others, Not Gadget
    #RenameGadgetSharp
  EndEnumeration
  
  Enumeration 400 ;Preference Form
    #PrefsForm
    #CodeGeneralText
    #HandlesOnMove
    #UnselectItemsBorder
    #PBPathText
    #PBPathString
    #PBPathPick
    #PBPathImage
    #ExportConfigButton
    #SaveProgress
    #SaveProgressSec
    #SaveProgressText
    #CodeOptionsText
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
    #CodeIncludeText
    #Code_TitleBlock
    #CodeEnumeration
    #CodeVariable
    #CodeConstants
    #CodePBany
    #CodeEventLoop
    #CodeCustomAddition
    #CodeCreateText
    #CodeNewTab
    #CodeSave
    #CodeClipboard
    #CodePlay
    #CodeCancel
    #AboutButton
    ;
    #SeparatorPref1
    #SeparatorPref2
    #AboutForm
    #AboutClose
    #Licence
  EndEnumeration
  
  Enumeration FormImage
    #Img_Designer
    #Img_CreateCode
    #Img_Clipboard
    #Img_CreateSave
    #Img_Preview
    #Img_Rename
    #Img_Delete
    #Img_Setting
    #Img_About
    #Img_Valid
    #Img_Fail
    #Img_Group
    #Img_UnGroup
    #Align_Left
    #Align_Right
    #Align_Top
    #Align_Bottom
    #Make_Same_Width
    #Make_Same_Height
    #Vd_Unknow
  EndEnumeration
  
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
  
  Global bDrawContainerGadget.b = #True
  Global DesignerON.b = #True, CountImageBtn.i, CountFontID.i, IdDrawGadgets.i = 1000000000
  Global SaveProgress.b, SaveProgressSec.i
  Global MonitorRenameFormFocus.b, MonitorPrefsFormFocus.b
  Global SetDrawWidth.i, SetDrawHeight.i
  Global PosX.i, PosY.i
  
  Declare LoadControls()
  Declare CreateGadgets(Model.s)
  Declare InitWindowSelected()
  Declare InitProperties()
  Declare LoadGadgetProperties(IdGadget.i)
  Declare RemoveFont(FontID.i)
  Declare SelectFont(IdGadget.i)
  Declare RemoveImage(sImagePath.s)
  Declare DrawSelectedImage(IdGadget.i)
  Declare ResizeDrawArea(Width.i, Height.i)
  Declare BackDesigner()
  Declare PreviewDesigner()
  Declare HideGroupButton()
  Declare WindowSize()
  Declare OpenMainWindow(Designer_Width, Designer_Height, X = 0, Y = 0)
  Declare Init()
  Declare Exit()
  
  UsePNGImageDecoder()
  UseJPEGImageDecoder()
  
  ;-Dependency: SweetyVD Module
  XIncludeFile "SweetyVDmodule.pbi" : UseModule SVDesigner
  
  IncludePath "Include"
  XIncludeFile "GetPBIDE.pb"
  XIncludeFile "LoadFontWML.pb"
  XIncludeFile "DelOldFiles.pb"
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    XIncludeFile "FullColorRequester.pb"
  CompilerEndIf
  XIncludeFile "SweetyVDPref.pb"
  XIncludeFile "ModelGadget.pb"
  XIncludeFile "RenameVDGadget.pb"
  XIncludeFile "TabBarGadget.pbi"
  ;Code Create Form and Code creation
  XIncludeFile "CodeCreate.pb"
  
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
  
  Procedure CreateGadgets(Model.s)
    Protected IdGadget.i, ModelType.i, DrawGadget.b, TmpCaption.s, Mini.i, Maxi.i, StepValue.i, I.i
    Protected iDftWidth.i, iDftHeight.i
    InitProperties()
    OpenGadgetList(#ScrollDrawArea)   ;Required when changing apps(ex: test generated code) to reopen the GadgetList
    For I=0 To ArraySize(ModelGadget())
      If ModelGadget(I)\Model = Model
        With ModelGadget(I)
          
          \CountGadget=\CountGadget+1   ;Updating the gadget counter by model
          
          ParentPosDim()   ;#ScrollDrawArea
          PosX = GridMatch(PosX, DragSpace, MinX, MaxX-\DftWidth)   ;Align on Grid and remains inside the grid
          PosY = GridMatch(PosY, DragSpace, MinY, MaxY-\DftHeight)
          iDftWidth = \DftWidth
          iDftHeight = \DftHeight
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
            Case "ButtonGadget"
              IdGadget=ButtonGadget(#PB_Any, PosX, PosY, iDftWidth, iDftHeight, TmpCaption)
            Case "ButtonImageGadget" : IdGadget=ButtonImageGadget(#PB_Any, PosX, PosY, iDftWidth, iDftHeight, 0)
            Case "CalendarGadget" : IdGadget=  CalendarGadget(#PB_Any, PosX, PosY, iDftWidth, iDftHeight, 0)
            Case "CanvasGadget"
              IdGadget=CanvasGadget(#PB_Any, PosX, PosY, iDftWidth, iDftHeight)
              If StartDrawing(CanvasOutput(IdGadget))
                DrawText(5, 5, \Name+"_"+Str(\CountGadget), #Blue, #White)
                StopDrawing()
              EndIf
            Case "CheckBoxGadget" : IdGadget=CheckBoxGadget(#PB_Any, PosX, PosY, iDftWidth, iDftHeight, TmpCaption)
            Case "ComboBoxGadget"
              IdGadget=ComboBoxGadget(#PB_Any, PosX, PosY, iDftWidth, iDftHeight, #PB_ComboBox_Editable)
              AddGadgetItem(Idgadget,-1,TmpCaption)
            Case "ContainerGadget"
              If bDrawContainerGadget
                ModelType=1
                DrawGadget=#True
                IdDrawGadgets=IdDrawGadgets+1
                IdGadget=IdDrawGadgets
              Else
                IdGadget=ContainerGadget(#PB_Any, PosX, PosY, iDftWidth, iDftHeight)
                CloseGadgetList()
              EndIf
            Case "DateGadget" : IdGadget=DateGadget(#PB_Any, PosX, PosY, iDftWidth, iDftHeight, TmpCaption)
            Case "EditorGadget"
              IdGadget=EditorGadget(#PB_Any, PosX, PosY, iDftWidth, iDftHeight)
              AddGadgetItem(IdGadget, 0, \Name+"_"+Str(\CountGadget))
            Case "ExplorerComboGadget" : IdGadget =ExplorerComboGadget(#PB_Any, PosX, PosY, iDftWidth, iDftHeight, "")
            Case "ExplorerListGadget" : IdGadget=ExplorerListGadget(#PB_Any, PosX, PosY, iDftWidth, iDftHeight, "")
            Case "ExplorerTreeGadget" : IdGadget=ExplorerTreeGadget(#PB_Any, PosX, PosY, iDftWidth, iDftHeight, "")
            Case "FrameGadget"
              If bDrawContainerGadget
                DrawGadget=#True
                IdDrawGadgets=IdDrawGadgets+1
                IdGadget=IdDrawGadgets
              Else
                IdGadget=FrameGadget(#PB_Any, PosX, PosY, iDftWidth, iDftHeight, TmpCaption)
              EndIf
            Case "HyperLinkGadget" : IdGadget=HyperLinkGadget(#PB_Any, PosX, PosY, iDftWidth, iDftHeight, TmpCaption, RGB(0,0,128))
            Case "ImageGadget"   ;We cheat with a Canvas instead of an ImageGadget
              IdGadget=ImageGadget(#PB_Any, PosX, PosY, iDftWidth, iDftHeight, 0)
              ;               IdGadget=CanvasGadget(#PB_Any, PosX, PosY, iDftWidth, iDftHeight)
              ;               If StartDrawing(CanvasOutput(IdGadget))
              ;                 DrawText(5, 5, \Name+"_"+Str(\CountGadget), #Blue, #White)
              ;                 StopDrawing()
              ;               EndIf
            Case "IPAddressGadget"
              IdGadget=  IPAddressGadget(#PB_Any, PosX, PosY, iDftWidth, iDftHeight)
              SetGadgetState(IdGadget, MakeIPAddress(127, 0, 0, 1))
            Case "ListIconGadget" : IdGadget=ListIconGadget(#PB_Any, PosX, PosY, iDftWidth, iDftHeight, TmpCaption, 100)
              AddGadgetItem (IdGadget,-1, "Element1")
            Case "ListViewGadget"
              IdGadget=ListViewGadget(#PB_Any, PosX, PosY, iDftWidth, iDftHeight)
              AddGadgetItem (IdGadget,-1, \Name+"_"+Str(\CountGadget) + " (Element1)")
            Case "OpenGLGadget" : IdGadget=OpenGLGadget(#PB_Any, PosX, PosY, iDftWidth, iDftHeight)
            Case "OptionGadget" : IdGadget=OptionGadget(#PB_Any, PosX, PosY, iDftWidth, iDftHeight, TmpCaption)
            Case "PanelGadget"
              If bDrawContainerGadget
                ModelType=1
                DrawGadget=#True
                IdDrawGadgets=IdDrawGadgets+1
                IdGadget=IdDrawGadgets
              Else
                IdGadget=PanelGadget(#PB_Any, PosX, PosY, iDftWidth, iDftHeight)
                AddGadgetItem(IdGadget, -1, TmpCaption)
                DisableGadget(IdGadget,#True)
                CloseGadgetList()
              EndIf
            Case "ProgressBarGadget"
              Mini = Val(Mid(\Option1, 7)) : Maxi = Val(Mid(\Option2, 7))
              IdGadget=ProgressBarGadget(#PB_Any, PosX, PosY, iDftWidth, iDftHeight, Mini, Maxi)
              SetGadgetState(IdGadget, Mini+(Maxi-Mini)*2/3)
            Case "ScintillaGadget"
              If InitScintilla()
                IdGadget=ScintillaGadget(#PB_Any, PosX, PosY, iDftWidth, iDftHeight, 0)
              EndIf
            Case "ScrollAreaGadget"
              Mini = Val(Mid(\Option1, 7)) : Maxi = Val(Mid(\Option2, 7)) : StepValue = Val(Mid(\Option3, 7))   ;InnerWidth, InnerHeight
              If bDrawContainerGadget
                ModelType=1
                DrawGadget=#True
                IdDrawGadgets=IdDrawGadgets+1
                IdGadget=IdDrawGadgets
              Else
                IdGadget=ScrollAreaGadget(#PB_Any, PosX, PosY, iDftWidth, iDftHeight, Mini, Maxi, StepValue)
                CloseGadgetList()
              EndIf
            Case "ScrollBarGadget"
              Mini = Val(Mid(\Option1, 7)) : Maxi = Val(Mid(\Option2, 7))
              IdGadget=ScrollBarGadget(#PB_Any, PosX, PosY, iDftWidth, iDftHeight, Mini, Maxi, 0)
            Case "SpinGadget"
              Mini = Val(Mid(\Option1, 7)) : Maxi = Val(Mid(\Option2, 7))
              IdGadget=SpinGadget(#PB_Any, PosX, PosY, iDftWidth, iDftHeight, Mini, Maxi, #PB_Spin_Numeric)
              SetGadgetState(IdGadget, Mini+(Maxi-Mini)*2/3)
            Case "StringGadget"
              IdGadget=StringGadget(#PB_Any, PosX, PosY, iDftWidth, iDftHeight, TmpCaption, #PB_String_ReadOnly)
            Case "TextGadget" : IdGadget=TextGadget(#PB_Any, PosX, PosY, iDftWidth, iDftHeight, TmpCaption)
            Case "TrackBarGadget"
              Mini = Val(Mid(\Option1, 7)) : Maxi = Val(Mid(\Option2, 7))
              IdGadget=TrackBarGadget(#PB_Any, PosX, PosY, iDftWidth, iDftHeight, Mini, Maxi)
              SetGadgetState(IdGadget, Mini+(Maxi-Mini)*2/3)
            Case "TreeGadget"
              IdGadget=TreeGadget(#PB_Any, PosX, PosY, iDftWidth, iDftHeight)
              AddGadgetItem(IdGadget,-1,"Node",0,0) : AddGadgetItem(IdGadget,-1,"Sub-element",0,1) : AddGadgetItem(IdGadget,-1,"Element",0,0)
              SetGadgetItemState(IdGadget, 0, #PB_Tree_Expanded)
            Case "WebGadget" : IdGadget=WebGadget(#PB_Any, PosX, PosY, iDftWidth, iDftHeight, TmpCaption)
            Case "TabBarGadget"
              IdGadget=TabBarGadget(#PB_Any, PosX, PosY, iDftWidth, iDftHeight, #TabBarGadget_BottomLine|#TabBarGadget_CloseButton, #MainWindow)
              AddTabBarGadgetItem(IdGadget, #PB_Default, TmpCaption)
            Default
              If Model <> "" And \Name <> "" And iDftWidth > 0 And iDftHeight > 0
                IdGadget=CanvasGadget(#PB_Any, PosX, PosY, iDftWidth, iDftHeight)
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
          SVDListGadget()\Selected = 0
          SVDListGadget()\ParentGadget = #ScrollDrawArea
          SVDListGadget()\ParentElement = 0
          SVDListGadget()\X =PosX
          SVDListGadget()\Y=PosY
          SVDListGadget()\Width=iDftWidth
          SVDListGadget()\Height=iDftHeight
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
          AddGadgetItem(#ListGadgets, -1, Mid(SVDListGadget()\Name, 2))
          SetGadgetState(#ListGadgets, CountGadgetItems(#ListGadgets)-1)
          SetGadgetItemData(#ListGadgets, CountGadgetItems(#ListGadgets)-1, IdGadget)
          
          AddGadgetItem(#ListControls, -1, Mid(SVDListGadget()\Name, 2), ImageID(\Image), 1)
          SetGadgetState(#ListControls, CountGadgetItems(#ListControls)-1)
          SetGadgetItemData(#ListControls, CountGadgetItems(#ListControls)-1, IdGadget)
          ;Add Drag Handle Gadget in module
          If DrawGadget = #False
            AddSVDGadget(IdGadget)
          Else
            AddSVDDrawGadget(IdGadget)
          EndIf
        EndWith
        Break
      EndIf
    Next
  EndProcedure
  
  Procedure InitWindowSelected()
    SetGadgetState(#ListGadgets, #MainWindow)
    SetGadgetState(#ListControls, #MainWindow)
    SetGadgetText(#PosGadgetX, "0") : SetGadgetText(#PosGadgetY, "0")
    SetGadgetText(#PosGadgetWidth, Str(SetDrawWidth)) : SetGadgetText(#PosGadgetHeight, Str(SetDrawHeight))
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
              If SVDListGadget()\Model = "CanvasGadget"
                DrawCanvasGadget(IdGadget)
              Else
                SetGadgetFont(IdGadget, FontID(iFontID))
              EndIf
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
            \Image = 0
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
            If IsImage(\ImageBtn)
              FreeImage(\ImageBtn)
            EndIf
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
          Else
            ResizeSVDGadget(IdGadget, #PB_Ignore, #PB_Ignore, ImageWidth(TmpImage), #PB_Ignore)
          EndIf
          If GadgetY(IdGadget) + ImageHeight(TmpImage) > UserScreen_Height
            ResizeSVDGadget(IdGadget, #PB_Ignore, UserScreen_Height-ImageHeight(TmpImage), #PB_Ignore, #PB_Ignore)
          Else
            ResizeSVDGadget(IdGadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, ImageHeight(TmpImage))
          EndIf
        EndIf
        ResetList(ImageBtnPathArray())   ;Set Index before first element
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
          SetGadgetText(#ImageString, ImagePath)
          SVDListGadget()\Option1 = "#Imag:" + ImagePath
          SVDListGadget()\Image = ImageBtn
          Select GadgetType(IdGadget)
            Case #PB_GadgetType_ButtonImage
              SetGadgetAttribute(IdGadget, #PB_Button_Image, ImageID(ImageBtn))
            Case #PB_GadgetType_Canvas
              DrawCanvasGadget(SVDListGadget()\Gadget)
            Case #PB_GadgetType_Image
              SetGadgetState(IdGadget, ImageID(ImageBtn))
          EndSelect
          
        EndIf
      Else
        If FindMapElement(SVDListGadget(), Str(IdGadget))
          If Left(SVDListGadget()\Option1, 5) = "#Imag"
            OldImagePath = Mid(SVDListGadget()\Option1, 7)
          EndIf
          If OldImagePath <> ""
            SetGadgetText(#ImageString, "0")
            SVDListGadget()\Option1 = "#Imag:0"
            SVDListGadget()\Image = 0
            Select GadgetType(IdGadget)
              Case #PB_GadgetType_ButtonImage
                SetGadgetAttribute(IdGadget, #PB_Button_Image, 0)
              Case #PB_GadgetType_Canvas
                DrawCanvasGadget(SVDListGadget()\Gadget)
              Case #PB_GadgetType_Image
                SetGadgetState(IdGadget, 0)
            EndSelect
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
          SetGadgetText(#ImageString, "0")
          SVDListGadget()\Option1 = "#Imag:0"
          SVDListGadget()\Image = 0
          Select GadgetType(IdGadget)
            Case #PB_GadgetType_ButtonImage
              SetGadgetAttribute(IdGadget, #PB_Button_Image, 0)
            Case #PB_GadgetType_Canvas
              DrawCanvasGadget(SVDListGadget()\Gadget)
            Case #PB_GadgetType_Image
              SetGadgetState(IdGadget, 0)
          EndSelect
          RemoveImage(OldImagePath)
        EndIf
      EndIf
    EndIf
  EndProcedure
  
  Procedure ResizeDrawArea(Width.i, Height.i)
    DrawAreaSize(Width, Height)   ;For UserScreen_Width(Height) and UserScreen handle for resizing
    DrawFullDrawingArea()
  EndProcedure
  
  Procedure PreviewDesigner()
    RemoveWindowTimer(#MainWindow, #TimerId)
    UnbindEvent(#PB_Event_Timer, @CodeCreateOnTimer())
    ShowGrid = #False
    DrawFullDrawingArea()
    CompilerIf #PB_Compiler_OS = #PB_OS_Linux : RemoveKeyboardShortcut(#MainWindow, #PB_Shortcut_Insert) : CompilerEndIf   ;Insert key as Right Click replacement under Linux
    If GetGadgetState(#SVDSetting) = 1
      PrefsFormLostFocus()
    EndIf
    HideGadget(#BackDesigner, #False)
    HideGadget(#ContainerSetting,#True)
    HideGadget(#ContainerSize,#True)
    HideGadget(#ContainerProperties,#True)
    HideGadget(#PanelControls,#True)
    HideGadget(#Constants,#True)
    DesignerON = #False
    DisableSVD()
  EndProcedure
  
  Procedure BackDesigner()
    If SaveProgress = #True
      AddWindowTimer(#MainWindow, #TimerId, SaveProgressSec*1000)   ;Timer 60 s
      BindEvent(#PB_Event_Timer, @CodeCreateOnTimer())
    EndIf
    ShowGrid = GetGadgetState(#ShowGrid)
    DrawFullDrawingArea()
    CompilerIf #PB_Compiler_OS = #PB_OS_Linux : AddKeyboardShortcut(#MainWindow, #PB_Shortcut_Insert, #Shortcut_Insert) : CompilerEndIf   ;Insert key as Right Click replacement under Linux
    InitWindowSelected()
    HideGadget(#BackDesigner, #True)
    HideGadget(#ContainerSetting,#False)
    HideGadget(#ContainerSize,#False)
    HideGadget(#ContainerProperties,#False)
    HideGadget(#PanelControls,#False)
    HideGadget(#Constants,#False)
    DesignerON = #True
    EnableSVD()
  EndProcedure
  
  Procedure HideGroupButton()
    Protected HideButton.i = #False
    If GroupGadget = #False
      HideButton.i = #True
      RemoveKeyboardShortcut(#MainWindow, #PB_Shortcut_Control|#PB_Shortcut_G)
      RemoveKeyboardShortcut(#MainWindow, #PB_Shortcut_Control|#PB_Shortcut_Shift|#PB_Shortcut_G)
      RemoveKeyboardShortcut(#MainWindow, #PB_Shortcut_Control|#PB_Shortcut_Left)
      RemoveKeyboardShortcut(#MainWindow, #PB_Shortcut_Control|#PB_Shortcut_Right)
      RemoveKeyboardShortcut(#MainWindow, #PB_Shortcut_Control|#PB_Shortcut_Up)
      RemoveKeyboardShortcut(#MainWindow, #PB_Shortcut_Control|#PB_Shortcut_Down)
      RemoveKeyboardShortcut(#MainWindow, #PB_Shortcut_Control|#PB_Shortcut_W)
      RemoveKeyboardShortcut(#MainWindow, #PB_Shortcut_Control|#PB_Shortcut_H)
    Else
      AddKeyboardShortcut(#MainWindow, #PB_Shortcut_Control|#PB_Shortcut_G, #Shortcut_Ctrl_Group)
      AddKeyboardShortcut(#MainWindow, #PB_Shortcut_Control|#PB_Shortcut_Shift|#PB_Shortcut_G, #Shortcut_Ctrl_UnGroup)
      AddKeyboardShortcut(#MainWindow, #PB_Shortcut_Control|#PB_Shortcut_Left, #Shortcut_CtrlLeft_Align)
      AddKeyboardShortcut(#MainWindow, #PB_Shortcut_Control|#PB_Shortcut_Right, #Shortcut_CtrlRight_Align)
      AddKeyboardShortcut(#MainWindow, #PB_Shortcut_Control|#PB_Shortcut_Up, #Shortcut_CtrlTop_Align)
      AddKeyboardShortcut(#MainWindow, #PB_Shortcut_Control|#PB_Shortcut_Down, #Shortcut_CtrlBottom_Align)
      AddKeyboardShortcut(#MainWindow, #PB_Shortcut_Control|#PB_Shortcut_W, #Shortcut_Ctrl_Same_Width)
      AddKeyboardShortcut(#MainWindow, #PB_Shortcut_Control|#PB_Shortcut_H, #Shortcut_Ctrl_Same_Height)
    EndIf
    HideGadget(#Group_Button,HideButton)
    HideGadget(#UnGroup_Button, HideButton)
    HideGadget(#Separator5, HideButton)
    HideGadget(#Align_Left_Button, HideButton)
    HideGadget(#Align_Left_Text, HideButton)
    HideGadget(#Align_Right_Button, HideButton)
    HideGadget(#Align_Right_Text, HideButton)
    HideGadget(#Align_Top_Button, HideButton)
    HideGadget(#Align_Top_Text, HideButton)
    HideGadget(#Align_Bottom_Button, HideButton)
    HideGadget(#Align_Bottom_Text, HideButton)
    HideGadget(#Make_Same_Width_Button, HideButton)
    HideGadget(#Make_Same_Width_Text, HideButton)
    HideGadget(#Make_Same_Height_Button, HideButton)
    HideGadget(#Make_Same_Height_Text, HideButton)
    HideGadget(#Separator6, HideButton)
  EndProcedure
  
  Procedure WindowSize()
    Protected DrawMaxWidth.i, DrawMaxHeight.i, ScrollMargin.i = 20, HeightControlsFlags.i, PosY.i
    ;Adjust width and height of the scroll drawing area according to window size
    If GetWindowState(#MainWindow) = #PB_Window_Normal
      Designer_Width = WindowWidth(#MainWindow)
      Designer_Height = WindowHeight(#MainWindow)
    EndIf
    If IsGadget(#ScrollDrawArea) And GadgetType(#ScrollDrawArea) = #PB_GadgetType_ScrollArea
      DrawMaxWidth = WindowWidth(#MainWindow) - GadgetX(#ScrollDrawArea) - 5   ;5 from the right border
      If DrawMaxWidth > GetGadgetAttribute(#ScrollDrawArea,#PB_ScrollArea_InnerWidth) + ScrollMargin
        DrawMaxWidth = GetGadgetAttribute(#ScrollDrawArea,#PB_ScrollArea_InnerWidth) + ScrollMargin
      EndIf
      DrawMaxHeight = WindowHeight(#MainWindow) - GadgetY(#ScrollDrawArea) - 10   ;10 from the bottom border
      If DrawMaxHeight > GetGadgetAttribute(#ScrollDrawArea,#PB_ScrollArea_InnerHeight) + ScrollMargin
        DrawMaxHeight = GetGadgetAttribute(#ScrollDrawArea,#PB_ScrollArea_InnerHeight) + ScrollMargin
      EndIf
      If MonitorPrefsFormFocus = #True
        ; PrefsFormLostFocus() or change the Width
        ;DrawMaxWidth -GadgetWidth(#PrefsForm)-5
        PrefsFormLostFocus()
      EndIf
      ResizeGadget(#ScrollDrawArea, #PB_Ignore, #PB_Ignore, DrawMaxWidth, DrawMaxHeight)
      ResizeGadget(#PrefsForm, WindowWidth(#MainWindow)-GadgetWidth(#PrefsForm)-5, #PB_Ignore, #PB_Ignore, WindowHeight(#MainWindow)-GadgetHeight(#ContainerSetting)-10)
      
      ResizeGadget(#ContainerSetting, #PB_Ignore, #PB_Ignore, WindowWidth(#MainWindow) - GadgetX(#ContainerSetting), #PB_Ignore)
      ResizeGadget(#SVDSetting, WindowWidth(#MainWindow) - GadgetX(#ContainerSetting) - GadgetWidth(#SVDSetting), #PB_Ignore, #PB_Ignore, #PB_Ignore)
      
      ; Size: position of Controls, Size, Properties and Flags
      ;  5       Controls       30      Size    5   Properties    5      Flags     10
      ; |-|-------------------|---|------------|-|---------------|-|--------------|--|
      
      HeightControlsFlags = WindowHeight(#MainWindow) - GadgetY(#PanelControls) - 30 - GadgetHeight(#ContainerSize) - 5 - GadgetHeight(#ContainerProperties) - 5 - 10
      ; --- Tree Create and List Controls ---
      CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
        PosY = Round(HeightControlsFlags * 0.55, #PB_Round_Up)
        ResizeGadget(#PanelControls, #PB_Ignore, #PB_Ignore, #PB_Ignore, PosY + 46)
        ResizeGadget(#CreateControlsList, #PB_Ignore, #PB_Ignore, #PB_Ignore, PosY)
        ResizeGadget(#ListControls, #PB_Ignore, #PB_Ignore, #PB_Ignore, PosY)
        PosY = GadgetY(#PanelControls) + PosY + 40
      CompilerElse
        PosY = Round(HeightControlsFlags * 0.58, #PB_Round_Up)
        ResizeGadget(#PanelControls, #PB_Ignore, #PB_Ignore, #PB_Ignore, PosY + 26)
        ResizeGadget(#CreateControlsList, #PB_Ignore, #PB_Ignore, #PB_Ignore, PosY)
        ResizeGadget(#ListControls, #PB_Ignore, #PB_Ignore, #PB_Ignore, PosY)
        PosY = GadgetY(#PanelControls) + PosY + 30
      CompilerEndIf
      ResizeGadget(#ContainerSize, #PB_Ignore, PosY, #PB_Ignore, #PB_Ignore)
      ResizeGadget(#RenameForm, #PB_Ignore, PosY, #PB_Ignore, #PB_Ignore)
      PosY = PosY + GadgetHeight(#ContainerSize) + 5
      ResizeGadget(#ContainerProperties, #PB_Ignore, PosY, #PB_Ignore, #PB_Ignore)
      PosY = PosY + GadgetHeight(#ContainerProperties) + 5
      ResizeGadget(#Constants, #PB_Ignore, PosY, #PB_Ignore, WindowHeight(#MainWindow) - PosY - 10)
      
      ResizePaintAllGadgetAndDragHandle()
      ResizePaintHandleCorner()
    EndIf
  EndProcedure
  
  Procedure OpenMainWindow(Designer_Width, Designer_Height, X = 0, Y = 0)
    Protected GadgetObj.i, PropertiesPanelWidth.i = 210, SettingPanelHeight.i = 48, Designer_Maximize.b = 0, ScrollArea_MaxWidth.l = 1920, ScrollArea_MaxHeight.l = 1020
    Protected Flags.i = #PB_Window_SizeGadget | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_ScreenCentered | #PB_Window_SystemMenu
    If OpenPreferences("SweetyVD.ini", #PB_Preference_GroupSeparator)
      PreferenceGroup("Designer")
      Designer_Maximize  = ReadPreferenceLong("Designer_Maximize", Designer_Maximize)
      ScrollArea_MaxWidth = ReadPreferenceLong("ScrollArea_MaxWidth", ScrollArea_MaxWidth)
      ScrollArea_MaxHeight = ReadPreferenceLong("ScrollArea_MaxHeight", ScrollArea_MaxHeight)
      ClosePreferences()
    EndIf
    If Designer_Maximize = 1 : Flags = Flags | #PB_Window_Maximize : EndIf
    
    OpenWindow(#MainWindow, x, y, Designer_Width, Designer_Height, "SweetyVD (Visual Designer) " + #BuildVersion, Flags)
    WindowBounds(#MainWindow, 960, 620, #PB_Ignore, #PB_Ignore)
    CreatePopupImageMenu(#PopUpMenu)
    
    ;    CatchImage(#Img_Designer,?Img_Designer)
    ButtonGadget(#BackDesigner, 30, 12, 140, 20, "Back to Designer")
    HideGadget(#BackDesigner, #True)
    
    ; --- Setting ---
    ContainerGadget(#ContainerSetting, PropertiesPanelWidth+10, 0, 780, SettingPanelHeight, #PB_Container_BorderLess)
    CanvasGadget(#Separator0, 0, 3, 1, 42, #PB_Canvas_Border) : DisableGadget(#Separator0, #True)
    If StartDrawing(CanvasOutput(#Separator0)) : Box(0, 0, OutputWidth(), OutputHeight(), $B0B0B0) : StopDrawing() : EndIf
    
    AddKeyboardShortcut(#MainWindow, #PB_Shortcut_F5, #Shortcut_F5_Play)
    AddKeyboardShortcut(#MainWindow, #PB_Shortcut_F6, #Shortcut_F6_Preview)
    AddKeyboardShortcut(#MainWindow, #PB_Shortcut_F7, #Shortcut_F7_NewTab)
    AddKeyboardShortcut(#MainWindow, #PB_Shortcut_Control|#PB_Shortcut_S, #Shortcut_CtrlS_Save)
    AddKeyboardShortcut(#MainWindow, #PB_Shortcut_F8, #Shortcut_F8_Clipboard)
    
    CatchImage(#Img_Designer,?Img_Designer)
    ButtonImageGadget(#CodeCreatePlay, 8, 1, 26, 22,ImageID(#Img_Designer))
    GadgetToolTip(#CodeCreatePlay, "Play Design (F5)")
    
    CatchImage(#Img_Preview,?Img_Preview)
    ButtonImageGadget(#PreviewDesigner, 8, 24, 26, 22, ImageID(#Img_Preview))
    GadgetToolTip(#PreviewDesigner, "Preview Design (F6)")
    
    ;I didn't look any further but I have problems on Linux and probably MacOS when I come back from the Preview (Procedure EnableSVD()). Better to hide that option.
    CompilerIf #PB_Compiler_OS <> #PB_OS_Windows 
      HideGadget(#PreviewDesigner, #True)
    CompilerEndIf
    
    CanvasGadget(#Separator1, 42, 3, 1, 42, #PB_Canvas_Border) : DisableGadget(#Separator1, #True)
    If StartDrawing(CanvasOutput(#Separator1)) : Box(0, 0, OutputWidth(), OutputHeight(), $B0B0B0) : StopDrawing() : EndIf
    
    TextGadget(#CodeCreateText, 62, 6, 85, 18, "Create Code")
    SetGadgetColor(#CodeCreateText, #PB_Gadget_FrontColor, $282850)
    ;SetGadgetFont(#CodeCreateText, FontID(#FontBWML))
    
    CatchImage(#Img_CreateSave,?Img_CreateSave)
    ButtonImageGadget(#CodeCreateSave, 148, 1, 22, 22, ImageID(#Img_CreateSave))
    GadgetToolTip(#CodeCreateSave, "Save Code As (Ctrl+S)")
    
    ;     CatchImage(#Img_CreateCode,?Img_CreateCode)
    ButtonGadget(#CodeCreateNewTab, 50, 24, 65, 20, "New Tab")
    GadgetToolTip(#CodeCreateNewTab, "Open the Code in a New PureBasic Tab (F7)")
    
    ;		  CatchImage(#Img_Clipboard,?Img_Clipboard)
    ButtonGadget(#CodeCreateClipboard, 120, 24, 65, 20, "ClipBoard")
    GadgetToolTip(#CodeCreateClipboard, "Copy the Code to the Clipboard (F8)")
    
    CanvasGadget(#Separator2, 193, 3, 1, 42, #PB_Canvas_Border) : DisableGadget(#Separator2, #True)
    If StartDrawing(CanvasOutput(#Separator2)) : Box(0, 0, OutputWidth(), OutputHeight(), $B0B0B0) : StopDrawing() : EndIf
    
    CheckBoxGadget(#AddMenu, 201, 4, 55, 20, "Menu")
    CheckBoxGadget(#AddPopupMenu, 201, 24, 55, 20, "Popup")
    CheckBoxGadget(#AddToolBar, 261, 4, 65, 20, "ToolBar")
    CheckBoxGadget(#AddStatusBar, 261, 24, 82, 20, "StatusBar")
    
    CanvasGadget(#Separator3, 344, 3, 1, 42, #PB_Canvas_Border) : DisableGadget(#Separator3, #True)
    If StartDrawing(CanvasOutput(#Separator3)) : Box(0, 0, OutputWidth(), OutputHeight(), $B0B0B0) : StopDrawing() : EndIf
    
    CheckBoxGadget(#ShowGrid, 352, 4, 52, 20, "Grid") : SetGadgetState(#ShowGrid, ShowGrid)
    SpinGadget(#GridSize, 409, 4, 50, 20, 1, 50, #PB_Spin_Numeric) : SetGadgetState(#GridSize, GridSize)
    CheckBoxGadget(#SnapGrid, 352, 24, 90, 20, "Snap to grid") : SetGadgetState(#SnapGrid, SnapGrid)
    
    CanvasGadget(#Separator4, 463, 3, 1, 42, #PB_Canvas_Border) : DisableGadget(#Separator4, #True)
    If StartDrawing(CanvasOutput(#Separator4)) : Box(0, 0, OutputWidth(), OutputHeight(), $B0B0B0) : StopDrawing() : EndIf
    
    CatchImage(#Img_Group,?Img_Group)
    ButtonImageGadget(#Group_Button, 473, 1, 22, 22,ImageID(#Img_Group))
    GadgetToolTip(#Group_Button, "Group the Selected Gadgets  (Ctrl+G)")
    
    CatchImage(#Img_UnGroup,?Img_UnGroup)
    ButtonImageGadget(#UnGroup_Button, 473, 24, 22, 22,ImageID(#Img_UnGroup))
    GadgetToolTip(#UnGroup_Button, "Ungroup All Gadgets Grouped with the Active Gadget (Ctrl+Shift+G)")
    
    CanvasGadget(#Separator5, 503, 3, 1, 42, #PB_Canvas_Border) : DisableGadget(#Separator5, #True)
    If StartDrawing(CanvasOutput(#Separator5)) : Box(0, 0, OutputWidth(), OutputHeight(), $B0B0B0) : StopDrawing() : EndIf
    
    CatchImage(#Align_Left,?Align_Left)
    ButtonImageGadget(#Align_Left_Button, 511, 1, 22, 22,ImageID(#Align_Left))
    GadgetToolTip(#Align_Left_Button, "Align Left (Ctrl+Left)")
    TextGadget(#Align_Left_Text, 532, 6, 34, 18, "Left")
    
    CatchImage(#Align_Right,?Align_Right)
    ButtonImageGadget(#Align_Right_Button, 511, 24, 22, 22,ImageID(#Align_Right))
    GadgetToolTip(#Align_Right_Button, "Align Right (Ctrl+Right)")
    TextGadget(#Align_Right_Text, 532, 28, 34, 18, "Right")
    
    CatchImage(#Align_Top,?Align_Top)
    ButtonImageGadget(#Align_Top_Button,571, 1, 22, 22,ImageID(#Align_Top))
    GadgetToolTip(#Align_Top_Button, "Align Top (Ctrl+Top)")
    TextGadget(#Align_Top_Text, 595, 6, 45, 18, "Top")
    
    CatchImage(#Align_Bottom,?Align_Bottom)
    ButtonImageGadget(#Align_Bottom_Button, 571, 24, 22, 22,ImageID(#Align_Bottom))
    GadgetToolTip(#Align_Bottom_Button, "Align Bottom (Ctrl+Bottom)")
    TextGadget(#Align_Bottom_Text, 595, 28, 45, 18, "Bottom")
    
    CatchImage(#Make_Same_Width,?Make_Same_Width)
    ButtonImageGadget(#Make_Same_Width_Button, 642, 1, 22, 22,ImageID(#Make_Same_Width))
    GadgetToolTip(#Make_Same_Width_Button, "Make Same Width (Ctrl+W)")
    TextGadget(#Make_Same_Width_Text, 666, 6, 42, 18, "Width")
    
    CatchImage(#Make_Same_Height,?Make_Same_Height)
    ButtonImageGadget(#Make_Same_Height_Button, 642, 24, 22, 22,ImageID(#Make_Same_Height))
    GadgetToolTip(#Make_Same_Height_Button, "Make Same Height (Ctrl+H)")
    TextGadget(#Make_Same_Height_Text, 666, 28, 42, 18, "Height")
    
    CanvasGadget(#Separator6, 716, 3, 1, 42, #PB_Canvas_Border) : DisableGadget(#Separator6, #True)
    If StartDrawing(CanvasOutput(#Separator6)) : Box(0, 0, OutputWidth(), OutputHeight(), $B0B0B0) : StopDrawing() : EndIf
    
    HideGroupButton()
    
    CatchImage(#Img_Setting,?Img_Setting)
    ButtonImageGadget(#SVDSetting, 744, 16, 30, 32, ImageID(#Img_Setting), #PB_Button_Toggle) : SetGadgetState(#SVDSetting, 0)
    GadgetToolTip(#SVDSetting, "Setting Panel (Esc=Close)")
    CloseGadgetList()
    
    PrefsForm()
    
    ; --- Tree Create and List Controls ---
    CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
      PanelGadget(#PanelControls, 0, 4, PropertiesPanelWidth+10, 230)
      AddGadgetItem(#PanelControls, -1, " Create Controls ")
      TreeGadget(#CreateControlsList, 0, 0, PropertiesPan elWidth-20, 184, #PB_Tree_NoLines | #PB_Tree_NoButtons)
      AddGadgetItem(#PanelControls, -1, "  List Controls ")
      TreeGadget(#ListControls, 0, 0, PropertiesPanelWidth-20, 184, #PB_Tree_AlwaysShowSelection)
      CloseGadgetList()
    CompilerElse
      PanelGadget(#PanelControls, 5, 4, PropertiesPanelWidth, 220)
      AddGadgetItem(#PanelControls, -1, " Create Controls ")
      TreeGadget(#CreateControlsList, 0, 0, PropertiesPanelWidth-5, 194, #PB_Tree_NoLines | #PB_Tree_NoButtons)
      AddGadgetItem(#PanelControls, -1, "  List Controls ")
      TreeGadget(#ListControls, 0, 0, PropertiesPanelWidth-5, 194, #PB_Tree_AlwaysShowSelection)
      CloseGadgetList()
    CompilerEndIf
    
    ; --- Gadget List Size ---
    ContainerGadget(#ContainerSize, 5, 228, PropertiesPanelWidth, 108, #PB_Container_Raised)
    ComboBoxGadget(#ListGadgets, 2, 2, 154, 22)
    CatchImage(#Img_Rename,?Img_Rename)
    ButtonImageGadget(#RenameGadgetButton, 158, 2, 22, 22, ImageID(#Img_Rename))
    GadgetToolTip(#RenameGadgetButton, "Rename Selected Gadget (F2, Enter=OK, Esc=Cancel")
    AddKeyboardShortcut(#MainWindow, #PB_Shortcut_F2, #Shortcut_F2_Rename)
    CatchImage(#Img_Delete,?Img_Delete)
    ButtonImageGadget(#DeleteGadgetButton, 182, 2, 22, 22, ImageID(#Img_Delete))
    GadgetToolTip(#DeleteGadgetButton, "Delete Selected Gadget (Del)")
    CheckBoxGadget(#HideGadget, 6, 27, 55, 20, "Hide")
    CheckBoxGadget(#DisableGadget, 68, 27, 70, 20, "Disable")
    CheckBoxGadget(#LockGadget, 144, 27, 55, 20, "Lock")
    GadgetToolTip(#LockGadget, "A Lock Gadget Cannot be Moved or Resized")
    StringGadget(#PosGadgetX, 9, 64, 60, 20, "", #PB_String_Numeric) : SetGadgetAttribute(#PosGadgetX, #PB_String_MaximumLength, 4) : SetGadgetText(#PosGadgetX, "0")
    StringGadget(#PosGadgetY, 74, 49, 60, 20, "", #PB_String_Numeric) : SetGadgetAttribute(#PosGadgetY, #PB_String_MaximumLength, 4) : SetGadgetText(#PosGadgetY, "0")
    StringGadget(#PosGadgetWidth, 139, 64, 60, 20, "", #PB_String_Numeric) : SetGadgetAttribute(#PosGadgetWidth, #PB_String_MaximumLength, 4)
    StringGadget(#PosGadgetHeight, 74, 79, 60, 20, "", #PB_String_Numeric) : SetGadgetAttribute(#PosGadgetHeight, #PB_String_MaximumLength, 4)
    CloseGadgetList()
    
    RenameGadgetForm()
    
    ; --- #Properties (Caption,Tooltip...) ---
    ContainerGadget(#ContainerProperties, 5, 357, PropertiesPanelWidth, 148, #PB_Container_Raised)
    ;StringGadget(#CaptionText, 0, 2, 65, 22, "Caption", #PB_String_ReadOnly)
    TextGadget(#CaptionText, 0, 4, 65, 22, "Caption")
    StringGadget(#CaptionString, 65, 2, 141, 22, "")
    
    ;StringGadget(#ToolTipText, 0, 25, 65, 22, "ToolTip", #PB_String_ReadOnly)
    TextGadget(#ToolTipText, 0, 27, 65, 22, "ToolTip")
    StringGadget(#ToolTipString, 65, 25, 141, 22, "")
    
    ;StringGadget(#FontText, 0, 48, 65, 22, "Font", #PB_String_ReadOnly)
    TextGadget(#FontText, 0, 50, 65, 22, "Font")
    StringGadget(#FontString, 65, 48, 114, 22, "", #PB_String_ReadOnly)
    ButtonGadget(#FontPick, 179, 48, 26, 22, "...")
    
    ;StringGadget(#MiniText, 0, 71, 44, 22, "Mini", #PB_String_ReadOnly)   ;+4
    TextGadget(#MiniText, 0, 73, 36, 22, "Mini")
    StringGadget(#MiniString, 65, 71, 50, 22, "0", #PB_String_Numeric)
    ;StringGadget(#MaxiText, 112, 71, 44, 22, "Maxi", #PB_String_ReadOnly)
    TextGadget(#MaxiText, 120, 73, 36, 22, "Maxi")
    StringGadget(#MaxiString, 156, 71, 50, 22, "100", #PB_String_Numeric)
    
    ;StringGadget(#ImageText, 0, 71, 65, 22, "Image", #PB_String_ReadOnly)
    TextGadget(#ImageText, 0, 73, 65, 22, "Image")
    StringGadget(#ImageString, 65, 71, 114, 22, "C:\xxxx\PB.jpg", #PB_String_ReadOnly)
    ButtonGadget(#ImagePick, 179, 71, 26, 22, "...") : HideGadget(#ImagePick, #True)
    
    TextGadget(#FrontColorText, 0, 98, 66, 22, "FrontColor")   ;+5
    ButtonImageGadget(#FrontColorPick, 66, 96, 22, 18, 0)
    CreateImage(#FrontColorImg, 22, 18)
    
    TextGadget(#BackColorText, 111, 98, 66, 22, "BackColor")
    ButtonImageGadget(#BackColorPick, 177, 96, 22, 18, 0)
    CreateImage(#BackColorImg, 22, 18)
    
    ;StringGadget(#ParentText, 0, 117, 65, 22, "Parent", #PB_String_ReadOnly)   ;+6
    TextGadget(#ParentText, 0, 119, 65, 22, "Parent")
    StringGadget(#ParentString, 65, 117, 114, 22, "", #PB_String_ReadOnly)
    ButtonGadget(#ParentPick, 179, 117, 26, 22, "...")
    CloseGadgetList()
    
    ; --- Flags or Constant ---
    TreeGadget(#Constants, 5, 510, PropertiesPanelWidth, 140, #PB_Tree_NoLines | #PB_Tree_NoButtons | #PB_Tree_CheckBoxes)
    
    ScrollAreaGadget(#ScrollDrawArea, PropertiesPanelWidth+10, SettingPanelHeight, WindowWidth(#MainWindow)-PropertiesPanelWidth, WindowHeight(#MainWindow)-SettingPanelHeight, ScrollArea_MaxWidth + 10, ScrollArea_MaxHeight + 10, 20, #PB_ScrollArea_Single)   ;InnerWidth,InnerHeight + 10 for the resize handle of the drawing window
    
    EnableGadgetDrop(#ScrollDrawArea, #PB_Drop_Text, #PB_Drag_Copy)
    
    ;All interface Objects must have #PB_Ignore as data. To not load them later when loading Designer
    PB_Object_EnumerateStart(PB_Gadget_Objects)
    While PB_Object_EnumerateNext(PB_Gadget_Objects, @GadgetObj)
      SetGadgetData(GadgetObj, #PB_Ignore)
    Wend
    
    If GetGadgetState(#ShowGrid) = #PB_Checkbox_Checked And DesignerON = #True
      ShowGrid = #True
    Else
      ShowGrid = #False
    EndIf
    If GetGadgetState(#SnapGrid) = #PB_Checkbox_Checked And DesignerON = #True
      DragSpace = GetGadgetState(#GridSize)
    Else
      DragSpace = 1
    EndIf
    
    ;*** Important *** Call InitSVD just after the ScrollArea and before creating Gadets on it: default param CountGadget.i = 144
    InitSVD()
  EndProcedure
  
  Procedure Init()
    DelOldFiles(GetTemporaryDirectory(), "~SweetyVD*.pb", 2)   ;Cleaning, Keep 2 days temporary files
    StartPrefs()
    LoadFontWML()
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
  ;-
  ;- Main
  Define *PosDim.PosDim
  Define IdGadget.i, ImagePath.s, TmpFontID.i, TmpImage.i, SelectedColor.i, TmpConstants.s, I.i
  Define Model.s, ModelImage.i, GadgetsListElement.i
  Define DeleteGadgetSelected.b
  Define SetGadgetX.i, SetGadgetY.i, SetGadgetWidth.i, SetGadgetHeight.i
  
  Init()
  OpenMainWindow(Designer_Width, Designer_Height)
  SmartWindowRefresh(#MainWindow, #True)
  WindowSize()
  
  If FileSize("SweetyVD.json") = -1
    InitModelgadget()   ;Initializing Gadget Model Templates from Datasection + Save JSON file
  Else
    InitJSONModelGadget()   ;Initializing Gadget Model Templates from JSON file
  EndIf
  BindEvent(#PB_Event_SizeWindow, @WindowSize())
  
  InitWindowSelected()
  EnableSVD()
  DrawFullDrawingArea()
  If SaveProgress = #True
    AddWindowTimer(#MainWindow, #TimerId, SaveProgressSec*1000)
    BindEvent(#PB_Event_Timer, @CodeCreateOnTimer())
  EndIf
  
  Repeat   ;- Event Loop
    Select WaitWindowEvent()
      Case #PB_Event_CloseWindow
        Exit()
        
      Case #PB_Event_GadgetDrop
        If EventGadget() = #ScrollDrawArea
          PosX=WindowMouseX(#MainWindow)-GadgetX(#ScrollDrawArea) + GetGadgetAttribute(#ScrollDrawArea, #PB_ScrollArea_X) : PosY=WindowMouseY(#MainWindow)-GadgetY(#ScrollDrawArea) + GetGadgetAttribute(#ScrollDrawArea, #PB_ScrollArea_Y)  ;Keep the coordinates of the mouse before creating the gadget
          CreateGadgets(EventDropText())
        EndIf
        
      Case #PB_Event_Menu   ;-> Event Menu
        Select EventMenu()
          Case 1 To ArraySize(ModelGadget())   ;Popup menu for creating gadgets
            Model = GetMenuItemText(#PopUpMenu, EventMenu())
            CreateGadgets(Model)
            
          Case #Shortcut_Delete   ;AddKeyboardShortcut is added on #PB_EventType_Focus and RemoveKeyboardShortcut on #PB_EventType_LostFocus in module, proc SVD_Callback
            DeleteGadgetSelected.b = #False   ;double check - RemoveKeyboardShortcut(0, #PB_Shortcut_Delete) is done on #PB_EventType_LostFocus
            If GetGadgetState(#ListGadgets) > 0
              GadgetsListElement = GetGadgetState(#ListGadgets)
              IdGadget=GetGadgetItemData(#ListGadgets, GadgetsListElement)
              If GetActiveGadget() = #DrawArea
                DeleteGadgetSelected = #True
              Else
                If FindMapElement(SVDListGadget(), Str(IdGadget))
                  If SVDListGadget()\DragHandle = GetActiveGadget()
                    DeleteGadgetSelected = #True
                  EndIf
                EndIf
              EndIf
              If DeleteGadgetSelected = #True
                RemoveGadgetItem(#ListControls, GadgetsListElement)
                RemoveGadgetItem(#ListGadgets, GadgetsListElement)
                ;Delete Image and Font if not used in others gadget (delete Gadget in SVDListGadget() first)
                ImagePath = "" : TmpFontID = 0
                If FindMapElement(SVDListGadget(), Str(IdGadget))
                  If Left(SVDListGadget()\Option1, 5) = "#Imag" And Mid(SVDListGadget()\Option1, 7) <> "0"
                    ImagePath = Mid(SVDListGadget()\Option1, 7)
                  EndIf
                  If SVDListGadget()\FontID <> 0
                    TmpFontID = SVDListGadget()\FontID
                  EndIf
                EndIf
                DeleteSVDGadget(IdGadget)
                If ImagePath <> "" : RemoveImage(ImagePath) : EndIf
                If TmpFontID <> 0 : RemoveFont(TmpFontID) : EndIf
                InitWindowSelected()
              Else
                RemoveKeyboardShortcut(0, #PB_Shortcut_Delete)   ;Windows: SendInput_(1, @InputData(n), SizeOf(INPUT)) - #VK_DELETE
              EndIf
            EndIf
            
          Case #Shortcut_F2_Rename
            RenameFormFocus()
            
          Case #Shortcut_F5_Play
            CodeCreate("Play")
          Case #Shortcut_F6_Preview
            PreviewDesigner()
            ;PostEvent(#PB_Event_Gadget, 0, #PreviewDesigner, #PB_EventType_Change)
          Case #Shortcut_F7_NewTab
            CodeCreate("NewTab")
          Case #Shortcut_CtrlS_Save
            CodeCreate("Save")
          Case #Shortcut_F8_Clipboard
            CodeCreate("Clipboard")
            
          Case #Shortcut_Ctrl_Group
            If GetGadgetState(#ListGadgets) > 0
              IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
              Group_Selected()
            EndIf
          Case #Shortcut_Ctrl_UnGroup
            If GetGadgetState(#ListGadgets) > 0
              IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
              UnGroup_Selected(IdGadget)
            EndIf
          Case #Shortcut_CtrlLeft_Align
            If GetGadgetState(#ListGadgets) > 0
              IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
              Align_Left(IdGadget)
            EndIf
          Case #Shortcut_CtrlRight_Align
            If GetGadgetState(#ListGadgets) > 0
              IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
              Align_Right(IdGadget)
            EndIf
          Case #Shortcut_CtrlTop_Align
            If GetGadgetState(#ListGadgets) > 0
              IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
              Align_Top(IdGadget)
            EndIf
          Case #Shortcut_CtrlBottom_Align
            If GetGadgetState(#ListGadgets) > 0
              IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
              Align_Bottom(IdGadget)
            EndIf
          Case #Shortcut_Ctrl_Same_Width
            If GetGadgetState(#ListGadgets) > 0
              IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
              Make_Same_Width(IdGadget)
            EndIf
          Case #Shortcut_Ctrl_Same_Height
            If GetGadgetState(#ListGadgets) > 0
              IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
              Make_Same_Height(IdGadget)
            EndIf
            
          Case #Shortcut_Escape
            If MonitorRenameFormFocus = #True
              RenameFormLostFocus()
            EndIf
            If MonitorPrefsFormFocus = #True
              PrefsFormLostFocus()
            EndIf
            
          Case #Shortcut_Return
            If MonitorRenameFormFocus = #True   ;RenameFormLostFocus()
              GadgetsListElement = GetGadgetState(#ListGadgets)
              IdGadget=GetGadgetItemData(#ListGadgets, GadgetsListElement)
              RenameGadget(IdGadget)   ;Check, Update and  call RenameFormLostFocus()
            EndIf
            
          Case #SaveProgressSec
            ;Allows to Lostfocus on #SaveProgressSec. With Remove Enter Shorcut, SaveProgressSec and stop/start timer If SaveProgress = #True
            SetActiveGadget(#PrefsForm)
            ;Optional, resume Focus to Change the value again
            ;SetActiveGadget(#SaveProgressSec)
            
            ;Allows to Lostfocus = Update Value and Resize Draw Area or Gadget. Remove Enter Shorcut and SetActiveGadget same Gadget or in clockwise direction
          Case #PosGadgetX
            ;SetActiveGadget(#PosGadgetY)
            SetActiveGadget(#ContainerSize) : SetActiveGadget(#PosGadgetX)
          Case #PosGadgetY
            ;SetActiveGadget(#PosGadgetWidth)
            SetActiveGadget(#ContainerSize) : SetActiveGadget(#PosGadgetY)
          Case #PosGadgetWidth
            ;SetActiveGadget(#PosGadgetHeight)
            SetActiveGadget(#ContainerSize) : SetActiveGadget(#PosGadgetWidth)
          Case #PosGadgetHeight
            ;If GetGadgetState(#ListGadgets) = 0 : SetActiveGadget(#PosGadgetWidth): Else : SetActiveGadget(#PosGadgetX) : EndIf
            SetActiveGadget(#ContainerSize) : SetActiveGadget(#PosGadgetHeight)
            
        EndSelect
        
        
        ;-> Event Gadget
      Case #PB_Event_Gadget
        ; Lost Focus on Rename Form (GadgetData <> #RenameForm). EventType() added for others Canvas Gadget (MouseMove, MouseEnter, MouseLeave and LostFocus)
        If MonitorRenameFormFocus = #True And EventType() <> #PB_EventType_MouseMove And EventType() <> #PB_EventType_MouseEnter And EventType() <> #PB_EventType_MouseLeave And EventType() <> #PB_EventType_LostFocus And
           IsGadget(EventGadget()) And GetGadgetData(EventGadget()) <> #RenameForm
          ;Debug "Gadget " + EventGadget() + " EventType " + Str(EventType()) + " Parent Gadget(Data) "+Str(GetGadgetData(EventGadget())) + " ActiveGadget " + GetActiveGadget()
          RenameFormLostFocus()
        EndIf
        
        If EventWindow()=#MainWindow
          Select EventGadget()
              
            Case #CodeCreatePlay
              CodeCreate("Play")
            Case #CodeCreateNewTab   ;Générate code Included in CodeCreate.pb
              CodeCreate("NewTab")
            Case #CodeCreateClipboard
              CodeCreate("Clipboard")
            Case #CodeCreateSave
              CodeCreate("Save")
              
            Case #PreviewDesigner
              PreviewDesigner()
              
            Case #BackDesigner
              BackDesigner()
              
            Case #SVDSetting
              If GetGadgetState(#SVDSetting) = 1
                If IsWindow(#AboutForm) : CloseWindow(#AboutForm) : EndIf
                PrefsFormFocus()
              Else
                If IsWindow(#AboutForm) : CloseWindow(#AboutForm) : EndIf
                PrefsFormLostFocus()
              EndIf
              
            Case #ListGadgets
              If GetGadgetState(#ListGadgets) = 0
                InitWindowSelected()
                SetSelectedGadget(0)
              Else
                IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
                SetSelectedGadget(IdGadget)
              EndIf
              
            Case #ListControls
              If EventType() = #PB_EventType_Change   ;To do once could be done also with EventType() = #PB_EventType_LeftClick or #PB_EventType_RightClick
                If GetGadgetState(#ListControls) = 0
                  InitWindowSelected()
                  SetSelectedGadget(0)
                Else
                  IdGadget=GetGadgetItemData(#ListControls, GetGadgetState(#ListControls))
                  SetSelectedGadget(IdGadget)
                EndIf
              EndIf
              
            Case #RenameGadgetButton
              RenameFormFocus()
              
            Case #RenameGadgetCancel
              RenameFormLostFocus()
              
            Case #RenameGadgetOK
              GadgetsListElement = GetGadgetState(#ListGadgets)
              IdGadget=GetGadgetItemData(#ListGadgets, GadgetsListElement)
              RenameGadget(IdGadget)
              
            Case #DeleteGadgetButton
              If GetGadgetState(#ListGadgets) > 0
                GadgetsListElement = GetGadgetState(#ListGadgets)
                IdGadget=GetGadgetItemData(#ListGadgets, GadgetsListElement)
                RemoveGadgetItem(#ListControls, GadgetsListElement)
                RemoveGadgetItem(#ListGadgets, GadgetsListElement)
                ;Delete Image and Font if not used in others gadget (delete Gadget in SVDListGadget() first)
                ImagePath = "" : TmpFontID =0
                If FindMapElement(SVDListGadget(), Str(IdGadget))
                  If Left(SVDListGadget()\Option1, 5) = "#Imag" And Mid(SVDListGadget()\Option1, 7) <> "0"
                    ImagePath = Mid(SVDListGadget()\Option1, 7)
                  EndIf
                  If SVDListGadget()\FontID <> 0
                    TmpFontID = SVDListGadget()\FontID
                  EndIf
                EndIf
                DeleteSVDGadget(IdGadget)
                If ImagePath <> "" : RemoveImage(ImagePath) : EndIf
                If TmpFontID <> 0 : RemoveFont(TmpFontID) : EndIf
                InitWindowSelected()
              EndIf
              
            Case #CreateControlsList   ;Element beging at 0 -> Element+1
              Select EventType()
                Case #PB_EventType_LeftDoubleClick
                  ParentPosDim()
                  PosX = MinX + DragSpace : PosY = MinY + DragSpace   ;coordinates for creating gadget inside #ScrollDrawArea
                  Model = GetGadgetItemText(#CreateControlsList, GetGadgetState(#CreateControlsList))
                  CreateGadgets(Model)
                Case #PB_EventType_DragStart
                  SetActiveGadget(#CreateControlsList)   ;To LostFocus on #PosGadgetX,#PosGadgetY,#PosGadgetWidth,#PosGadgetHeight Otherwise the gadget is resized with this data
                  Model = GetGadgetItemText(#CreateControlsList, GetGadgetState(#CreateControlsList))
                  ;ModelImage = GetGadgetItemData(#CreateControlsList, GetGadgetState(#CreateControlsList))
                  DragText(Model)
              EndSelect
              
            Case #ShowGrid : ShowGrid = GetGadgetState(#ShowGrid) : DrawFullDrawingArea()
              
            Case #GridSize
              GridSize = GetGadgetState(#GridSize)
              If GetGadgetState(#SnapGrid) = #True
                DragSpace = GetGadgetState(#GridSize)
              Else
                DragSpace = 1
              EndIf
              If ShowGrid = #True And DesignerON = #True   ;Not to call it the first time on Linux
                DrawFullDrawingArea()
              EndIf
              
            Case #SnapGrid
              SnapGrid = GetGadgetState(#SnapGrid)
              If SnapGrid = #True
                DragSpace = GetGadgetState(#GridSize)
              Else
                DragSpace = 1
              EndIf
              
            Case #Group_Button
              If GetGadgetState(#ListGadgets) > 0
                IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
                Group_Selected()
              EndIf
              
            Case #UnGroup_Button
              If GetGadgetState(#ListGadgets) > 0
                IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
                UnGroup_Selected(IdGadget)
              EndIf
              
            Case #Align_Left_Button
              If GetGadgetState(#ListGadgets) > 0
                IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
                Align_Left(IdGadget)
              EndIf
              
            Case #Align_Right_Button
              If GetGadgetState(#ListGadgets) > 0
                IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
                Align_Right(IdGadget)
              EndIf
              
            Case #Align_Top_Button
              If GetGadgetState(#ListGadgets) > 0
                IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
                Align_Top(IdGadget)
              EndIf
              
            Case #Align_Bottom_Button
              If GetGadgetState(#ListGadgets) > 0
                IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
                Align_Bottom(IdGadget)
              EndIf
              
            Case #Make_Same_Width_Button
              If GetGadgetState(#ListGadgets) > 0
                IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
                Make_Same_Width(IdGadget)
              EndIf
              
            Case #Make_Same_Height_Button
              If GetGadgetState(#ListGadgets) > 0
                IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
                Make_Same_Height(IdGadget)
              EndIf
              
            Case #AddMenu : AddMenu = GetGadgetState(#AddMenu) : DrawFullDrawingArea()
            Case #AddPopupMenu : AddPopupMenu = GetGadgetState(#AddPopupMenu)
            Case #AddToolBar : AddToolBar = GetGadgetState(#AddToolBar) : DrawFullDrawingArea()
            Case #AddStatusBar : AddStatusBar = GetGadgetState(#AddStatusBar) : DrawFullDrawingArea()
              
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
                SetSelectedGadget(IdGadget)
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
              If EventType() = #PB_EventType_Focus
                AddKeyboardShortcut(#MainWindow, #PB_Shortcut_Return, #PosGadgetX)
              EndIf
              If EventType() =  #PB_EventType_LostFocus
                RemoveKeyboardShortcut(#MainWindow, #PB_Shortcut_Return)
                SetGadgetX = Val(GetGadgetText(#PosGadgetX))
                SetGadgetX = GridMatch(SetGadgetX, 1, 0, MaxX-Val(GetGadgetText(#PosGadgetWidth)))
                If GetGadgetState(#ListGadgets) > 0
                  IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
                  ResizeSVDGadget(IdGadget, SetGadgetX, #PB_Ignore, #PB_Ignore, #PB_Ignore)
                  ;SetSelectedGadget(IdGadget)
                EndIf
                SetGadgetText(#PosGadgetX, Str(SetGadgetX))
              EndIf
              
            Case #PosGadgetY
              If EventType() = #PB_EventType_Focus
                AddKeyboardShortcut(#MainWindow, #PB_Shortcut_Return, #PosGadgetY)
              EndIf
              If EventType() =  #PB_EventType_LostFocus
                RemoveKeyboardShortcut(#MainWindow, #PB_Shortcut_Return)
                SetGadgetY = Val(GetGadgetText(#PosGadgetY))
                SetGadgetY = GridMatch(SetGadgetY, 1, 0, MaxY-Val(GetGadgetText(#PosGadgetHeight)))
                If GetGadgetState(#ListGadgets) > 0
                  IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
                  If AddMenu = #True
                    ResizeSVDGadget(IdGadget, #PB_Ignore, SetGadgetY+AddMenuHeight, #PB_Ignore, #PB_Ignore)
                  Else
                    ResizeSVDGadget(IdGadget, #PB_Ignore, SetGadgetY, #PB_Ignore, #PB_Ignore)
                  EndIf
                  ;SetSelectedGadget(IdGadget)
                EndIf
                SetGadgetText(#PosGadgetY, Str(SetGadgetY))
              EndIf
              
            Case #PosGadgetWidth
              If EventType() = #PB_EventType_Focus
                AddKeyboardShortcut(#MainWindow, #PB_Shortcut_Return, #PosGadgetWidth)
              EndIf
              If EventType() =  #PB_EventType_LostFocus
                RemoveKeyboardShortcut(#MainWindow, #PB_Shortcut_Return)
                SetGadgetWidth = Val(GetGadgetText(#PosGadgetWidth))
                If GetGadgetState(#ListGadgets) = 0
                  SetGadgetWidth = GridMatch(SetGadgetWidth, 1, 0, GetGadgetAttribute(#ScrollDrawArea,#PB_ScrollArea_InnerWidth)-10)
                  SetDrawWidth = SetGadgetWidth
                  ResizeDrawArea(SetGadgetWidth, SetDrawHeight)
                Else
                  SetGadgetWidth = GridMatch(SetGadgetWidth, 1, 0, MaxX-Val(GetGadgetText(#PosGadgetX)))
                  IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
                  ;Resize Image is done in module, with the selected area size for Canvas And reduce, zoom-, for Image Gadgets
                  ResizeSVDGadget(IdGadget, #PB_Ignore, #PB_Ignore, SetGadgetWidth, #PB_Ignore)
                  ;SetSelectedGadget(IdGadget)
                EndIf
                SetGadgetText(#PosGadgetWidth, Str(SetGadgetWidth))
              EndIf
              
            Case #PosGadgetHeight
              If EventType() = #PB_EventType_Focus
                AddKeyboardShortcut(#MainWindow, #PB_Shortcut_Return, #PosGadgetHeight)
              EndIf
              If EventType() =  #PB_EventType_LostFocus
                RemoveKeyboardShortcut(#MainWindow, #PB_Shortcut_Return)
                SetGadgetHeight = Val(GetGadgetText(#PosGadgetHeight))
                If GetGadgetState(#ListGadgets) = 0
                  SetGadgetHeight = GridMatch(SetGadgetHeight, 1, 0, GetGadgetAttribute(#ScrollDrawArea,#PB_ScrollArea_InnerHeight)-10)
                  SetDrawHeight = SetGadgetHeight
                  ResizeDrawArea(SetDrawWidth, SetDrawHeight)
                Else
                  SetGadgetHeight = GridMatch(SetGadgetHeight, 1, 0, MaxY-Val(GetGadgetText(#PosGadgetY)))
                  IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
                  ;Resize Image is done in module, with the selected area size for Canvas And reduce, zoom-, for Image Gadgets
                  ResizeSVDGadget(IdGadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, SetGadgetHeight)
                  ;SetSelectedGadget(IdGadget)
                EndIf
                SetGadgetText(#PosGadgetHeight, Str(SetGadgetHeight))
              EndIf
              
            Case #ParentPick
              MessageRequester("SweetyVD Information", "Todo, If (and when) free time will allow" +#CRLF$+#CRLF$+ "Source is opened for any contribution ;)", #PB_MessageRequester_Info|#PB_MessageRequester_Ok)
              
              ;-> > Event Gadget Properties
            Case #CaptionString
              If EventType() = #PB_EventType_Change
                IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
                If FindMapElement(SVDListGadget(), Str(IdGadget))
                  If IsWindow(IdGadget)
                    SVDListGadget()\Caption = "#Text:" + GetGadgetText(#CaptionString)
                  Else
                    Select Left(SVDListGadget()\Caption, 5)
                      Case "#Text"
                        SVDListGadget()\Caption = "#Text:" + GetGadgetText(#CaptionString)
                        If SVDListGadget()\DrawGadget = #False
                          If SVDListGadget()\Model = "ListIconGadget"
                            SetGadgetItemText(IdGadget, -1, GetGadgetText(#CaptionString))
                          ElseIf SVDListGadget()\Model = "CanvasGadget"
                          ElseIf SVDListGadget()\Type = 50   ;;Custom Gadget
                          Else
                            SetGadgetText(IdGadget, GetGadgetText(#CaptionString))
                          EndIf
                        Else
                          SetDrawGadgetAttribute(IdGadget)
                        EndIf
                        
                        If SVDListGadget()\Type = 50  ;Custom Gadget
                          If StartDrawing(CanvasOutput(IdGadget))
                            ;Box(0, 0, OutputWidth(), OutputHeight(), $FFFFFF)
                            DrawingMode(#PB_2DDrawing_Transparent)
                            DrawText(5, 5, GetGadgetText(#CaptionString), #Blue, #White)
                            StopDrawing()
                          EndIf
                        EndIf
                        If SVDListGadget()\Type = 33   ;Canvas
                          DrawCanvasGadget(SVDListGadget()\Gadget)
                          ;PostEvent(#PB_Event_Gadget, 0, SVDListGadget()\Gadget, #PB_EventType_Resize)
                        EndIf
                        
                      Case "#Date"
                        SVDListGadget()\Caption = "#Date:" + GetGadgetText(#CaptionString)
                        If SVDListGadget()\DrawGadget = #False
                          SetGadgetText(IdGadget, GetGadgetText(#CaptionString))
                        Else
                          SetDrawGadgetAttribute(IdGadget)
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
                  SVDListGadget()\Option1 = "#Mini:" + GetGadgetText(#MiniString)
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
              SetSelectedGadget(IdGadget)
              
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
                GadgetToolTip(#FrontColorPick, "")
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
                  GadgetToolTip(#FrontColorPick, "Color: RGB(" + Str(Red(SelectedColor)) + ", " + Str(Green(SelectedColor)) + ", " + Str(Blue(SelectedColor)) + ")" +
                                                 "  hex: $" + RSet(Hex(Blue(SelectedColor)), 2, "0") + RSet(Hex(Green(SelectedColor)), 2, "0") + RSet(Hex(Red(SelectedColor)), 2, "0"))
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
                GadgetToolTip(#BackColorPick, "")
                If FindMapElement(SVDListGadget(), Str(IdGadget))
                  SVDListGadget()\BackColor = ""
                  If IsWindow(IdGadget)
                    WinBackColor = 0 : DrawFullDrawingArea()
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
                  GadgetToolTip(#BackColorPick, "Color: RGB(" + Str(Red(SelectedColor)) + ", " + Str(Green(SelectedColor)) + ", " + Str(Blue(SelectedColor)) + ")" +
                                                "  hex: $" + RSet(Hex(Blue(SelectedColor)), 2, "0") + RSet(Hex(Green(SelectedColor)), 2, "0") + RSet(Hex(Red(SelectedColor)), 2, "0"))
                  If FindMapElement(SVDListGadget(), Str(IdGadget))
                    SVDListGadget()\BackColor = Str(SelectedColor)
                    If IsWindow(IdGadget)
                      WinBackColor = SelectedColor : DrawFullDrawingArea()
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
              
              ;-> Preference Form
            Case #HandlesOnMove
              DisplayHandleCornerOnMove = GetGadgetState(#HandlesOnMove)
              
            Case #UnselectItemsBorder
              DisplayUnselectedItemsBorder = GetGadgetState(#UnselectItemsBorder)
              IdGadget=GetGadgetItemData(#ListControls, GetGadgetState(#ListControls))
              SetSelectedGadget(IdGadget)
              
            Case #PBPathPick
              PBIDEpath = OpenFileRequester("Select the Path to Purebasic.exe", PBIDEpath, "PureBasic Path (PureBasic.exe)|PureBasic.exe", 0)
              SetGadgetText(#PBPathString, PBIDEpath)
              If FileSize(PBIDEpath) > 1
                SetGadgetState(#PBPathImage, ImageID(#Img_Valid))
              Else
                SetGadgetState(#PBPathImage, ImageID(#Img_Fail))
              EndIf
              
            Case #ExportConfigButton
              SaveJSONModelGadget()
              If FileSize("SweetyVD.json") > 1
                MessageRequester("SweetyVD Information", "Template Model Configuration has been Successfully Exported to SweetyVD.json", #PB_MessageRequester_Info|#PB_MessageRequester_Ok)
              Else
                MessageRequester("SweetyVD Warning", "Failed to Export Template Configuration to SweetyVD.json", #PB_MessageRequester_Warning|#PB_MessageRequester_Ok)
              EndIf
              
            Case #SaveProgress
              SaveProgress = GetGadgetState(#SaveProgress)
              If SaveProgress = #True
                AddWindowTimer(#MainWindow, #TimerId, SaveProgressSec*1000)   ;Timer 60 s
                BindEvent(#PB_Event_Timer, @CodeCreateOnTimer())
              Else
                RemoveWindowTimer(#MainWindow, #TimerId)
                UnbindEvent(#PB_Event_Timer, @CodeCreateOnTimer())
              EndIf
              
            Case #SaveProgressSec
              If EventType() = #PB_EventType_Focus
                AddKeyboardShortcut(#MainWindow, #PB_Shortcut_Return, #SaveProgressSec)
              EndIf
              If EventType() = #PB_EventType_LostFocus
                RemoveKeyboardShortcut(#MainWindow, #PB_Shortcut_Return)
                SaveProgressSec = Val(GetGadgetText(#SaveProgressSec))
                If SaveProgressSec < 10   ; Minimum Value
                  SaveProgressSec = 10
                  SetGadgetText(#SaveProgressSec, Str(SaveProgressSec))
                EndIf
                If SaveProgress = #True
                  RemoveWindowTimer(#MainWindow, #TimerId)
                  UnbindEvent(#PB_Event_Timer, @CodeCreateOnTimer())
                  AddWindowTimer(#MainWindow, #TimerId, SaveProgressSec*1000)   ;Timer 60 s
                  BindEvent(#PB_Event_Timer, @CodeCreateOnTimer())
                EndIf
              EndIf
              
            Case #CodeCancel
              PrefsFormLostFocus()
            Case #CodePlay
              CodeCreate("Play")
            Case #CodeNewTab
              CodeCreate("NewTab")
            Case #CodeSave
              CodeCreate("Save")
            Case #CodeClipboard
              CodeCreate("Clipboard")
            Case #AboutButton
              PrefsFormLostFocus()
              AboutForm()
              
          EndSelect   ;#PB_Event_Gadget #MainWindow
        EndIf
        
        If EventWindow()=#AboutForm   ;-> About Form window
          Select EventGadget()
            Case #AboutClose
              CloseWindow(#AboutForm)
          EndSelect
        EndIf
        
        Select EventType()   ;-> Receives Module Events
          Case #SVD_Gadget_Focus
            *PosDim = EventData()
            ;Debug Str(EventGadget())+" : "+Str(*PosDim\X)+" - "+Str(*PosDim\Y)+" - "+Str(*PosDim\Width)+" - "+Str(*PosDim\Height)
            ;Assign the global counter gadget to this new gadget
            For I=0 To CountGadgetItems(#ListGadgets)
              If GetGadgetItemData(#ListGadgets, I) = EventGadget()
                SetGadgetState(#ListGadgets,I)
                SetGadgetState(#ListControls,I)
                Break
              EndIf
            Next
            SetGadgetText(#PosGadgetX, Str(*PosDim\X))
            If AddMenu = #True
              SetGadgetText(#PosGadgetY, Str(*PosDim\Y-AddMenuHeight))
            Else
              SetGadgetText(#PosGadgetY, Str(*PosDim\Y))
            EndIf
            SetGadgetText(#PosGadgetWidth, Str(*PosDim\Width))
            SetGadgetText(#PosGadgetHeight, Str(*PosDim\Height))
            LoadGadgetProperties(EventGadget())
            
          Case #SVD_Gadget_LostFocus
            
          Case #SVD_Gadget_Resize
            If DesignerON = #True   ;Designer mode. The TabBar Gadget is resized on click on the preview mode. Thanks JHPJHP
              *PosDim = EventData()
              SetGadgetText(#PosGadgetX, Str(*PosDim\X))
              If AddMenu = #True
                SetGadgetText(#PosGadgetY, Str(*PosDim\Y-AddMenuHeight))
              Else
                SetGadgetText(#PosGadgetY, Str(*PosDim\Y))
              EndIf
              SetGadgetText(#PosGadgetWidth, Str(*PosDim\Width))
              SetGadgetText(#PosGadgetHeight, Str(*PosDim\Height))
            EndIf
            
          Case  #SVD_Window_Focus
            If DesignerON = #True ;And MouseOverDrawArea() = #True
              InitWindowSelected()
            EndIf
            
          Case #SVD_Window_ReSize
            *PosDim = EventData()
            SetDrawWidth  = *PosDim\Width
            SetDrawHeight = *PosDim\Height
            If GetGadgetState(#ListGadgets) = 0
              SetGadgetText(#PosGadgetWidth, Str(SetDrawWidth))
              SetGadgetText(#PosGadgetHeight, Str(SetDrawHeight))
            EndIf
            ResizeDrawArea(SetDrawWidth, SetDrawHeight)
            
          Case #SVD_DrawArea_RightClick
            If DesignerON = #True And  MouseOverDrawArea() = #True
              PosX=WindowMouseX(#MainWindow)-GadgetX(#ScrollDrawArea) + GetGadgetAttribute(#ScrollDrawArea, #PB_ScrollArea_X) : PosY=WindowMouseY(#MainWindow)-GadgetY(#ScrollDrawArea) + GetGadgetAttribute(#ScrollDrawArea, #PB_ScrollArea_Y)  ;Keep the coordinates of the mouse before creating the gadget
              DisplayPopupMenu(#PopUpMenu, WindowID(#MainWindow))
            EndIf
            
          Case #SVD_DrawArea_Focus
            If DesignerON = #True ;And MouseOverDrawArea() = #True
              InitWindowSelected()
            EndIf
            
          Case #SVD_Group
            HideGroupButton()
            
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
    End
  EndProcedure
  
  DataSection   ;- Include Images
    IncludePath "Images"
    Img_Designer:     : IncludeBinary "Designer.png"
    Img_CreateCode:   : IncludeBinary "CreateCode.png"
    Img_Clipboard:    : IncludeBinary "Clipboard.png"
    Img_CreateSave:   : IncludeBinary "Save.png"
    Img_Preview:      : IncludeBinary "Preview.png"
    Img_Rename:       : IncludeBinary "Rename.png"
    Img_Delete:       : IncludeBinary "Delete.png"
    Img_Setting:      : IncludeBinary "Setting.png"
    Img_Valid:        : IncludeBinary "Valid.png"
    Img_Fail:         : IncludeBinary "Fail.png"
    Img_About:        : IncludeBinary "About.png"
    Img_Group:        : IncludeBinary "Group.png"
    Img_UnGroup:      : IncludeBinary "UnGroup.png"
    Align_Left:       : IncludeBinary "Align_Left.png"
    Align_Right:      : IncludeBinary "Align_Right.png"
    Align_Top:        : IncludeBinary "Align_Top.png"
    Align_Bottom:     : IncludeBinary "Align_Bottom.png"
    Make_Same_Width:  : IncludeBinary "Make_Same_Width.png"
    Make_Same_Height: : IncludeBinary "Make_Same_Height.png"
    Vd_Unknow:        : IncludeBinary "Vd_Unknow.png"
    Vd_Custom:        : IncludeBinary "Vd_Custom.png"
    Vd_Window:        : IncludeBinary "Vd_Window.png"
    
  EndDataSection
CompilerEndIf

; IDE Options = PureBasic 5.71 LTS (Windows - x64)
; Folding = ------
; EnableXP
; UseIcon = Include\SweetyVD.ico
; Executable = SweetyVD_x64.exe
; Compiler = PureBasic 5.71 LTS (Windows - x64)
; EnablePurifier