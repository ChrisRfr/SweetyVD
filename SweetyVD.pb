; ---------------------------------------------------------------------------------------
;           Name: SweetyVD
;    Description: Sweety Visual Designer
;     dependency: SweetyVDmodule.pbi (Sweety Visual Designer Module)
;         Author: ChrisR
;           Date: 2017-04-06
;        Version: 1.8.2
;     PB-Version: 5.4* LTS, 5.5*, 5.60 (x86/x64)
;             OS: Windows, Linux, Mac
;         Credit: STARGÅTE: Transformation of gadgets at runtime
;         Credit: Falsam: Tiny Visual Designer (TVD)
;  English-Forum: http://www.purebasic.fr/english/viewtopic.php?f=27&t=68187
;   French-Forum: http://www.purebasic.fr/french/viewtopic.php?f=3&t=16527
; ---------------------------------------------------------------------------------------
; Note Linux: In order to use the WebGadget you have to utilize WebKitGTK
;   See Shardik's post http://www.purebasic.fr/english/viewtopic.php?f=15&t=54049
;   To install the Gtk3 libraries on Debian/Ubuntu: sudo apt-get install libwebkitgtk-3.0-0
; ---------------------------------------------------------------------------------------
; v1.6.1 2017-03-31: Disable Tootip for TextGadget
; ---------------------------------------------------------------------------------------
; v1.7.0 2017-04-03: Popup Image Menu + List Gadgets with image added, double-click or drag and drop
; ---------------------------------------------------------------------------------------
; v1.8.0 2017-04-04: Resize the Window Draw Area with mouse
; ---------------------------------------------------------------------------------------
; v1.8.2 2017-04-06: Fixed empty caption.
;   Choose between constants or #PB_Any when creating the code
; ---------------------------------------------------------------------------------------

CompilerIf #PB_Compiler_IsMainFile
  EnableExplicit
  
  ;Import internal function
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    Import ""
  CompilerElseIf #PB_Compiler_OS = #PB_OS_Linux
    CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
      ImportC "/usr/lib/i386-linux-gnu/libwebkitgtk-3.0.so.0"   ; Ubuntu/Kubuntu/Xubuntu x86 with GTK3
    CompilerElse
      ImportC "/usr/lib/x86_64-linux-gnu/libwebkitgtk-3.0.so.0" ; Ubuntu/Kubuntu/Xubuntu x64 with GTK3
    CompilerEndIf
  CompilerElse
    ImportC ""
  CompilerEndIf
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
  
  #PB_MessageRequester_Error=16
  #PB_MessageRequester_Warning=48
  #PB_MessageRequester_Info=64
  
  Enumeration
    #MainWindow
    #PopUpMenu
    #EnableSVD
    #CodeCreate
    #SettingContainer
    #SetDrawSizeText
    #SetDrawWidth
    #SetDrawSizeTextX
    #SetDrawHeight
    #DragText
    #DragSVD
    #ShowGrid
    #GridSpacing
    #GadgetList
    #ListGadgets
    #DeleteGadgetButton
    #PosGadgetX
    #PosGadgetY
    #PosGadgetWidth
    #PosGadgetHeight
    ;Properties
    #PropertiesContainer
    #ControlsListIcon
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
    #FrontColorText
    #FrontColorPick
    #FrontColorImg
    #BackColorText
    #BackColorPick
    #BackColorImg
    #Constants
    ;Code Generator Windows
    #CodeForm
    #CodePerform
    #CodeCancel
    #CodeIncTitle
    #CodeIncEnum
    #CodeFrame
    #CodeConstants
    #CodePBany
    #CodeAddStatusBar
    #CodeIncEvent
    #AboutButton
    #Shortcut_Insert
    #AboutForm
    #AboutBack
    #Licence
    ;For testing
    #TextGadget
    #EditorGadget
    #ComboBox
    #ButtonGadget
    #CheckBoxGadget
    #TrackBarGadget
    #SpinGadget
    #TestButtonGadget
  EndEnumeration
  
  Enumeration FormImage
    #Vd_Unknow
    #Img_Delete
    #Img_About
  EndEnumeration
  
  Enumeration Font
    #FontWML
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
  Global Dim ImageBtnPathArray.ImageBtnPath(0)
  
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
    Constants.s                   ;Available Constants (Ex: "#PB_Text_Center,#PB_Text_Right,#PB_Text_Border")
    CountGadget.i                 ;Gadget Counter by Model
  EndStructure
  Global Dim ModelGadget.ModelGadgetProperty(31)
  
  Structure StructureGadget       ;Structure of gadgets. 0 is reserved for the window Draw Area
    Idgadget.i                    ;Id gadget
    IdModel.i                     ;Id model
    Name.s                        ;Name
    Caption.s                     ;Caption Or Gadget content
    ToolTip.s                     ;ToolTip
    Option1.s                     ;Option1
    Option2.s                     ;Option2
    Option3.s                     ;Option2
    FrontColor.s                  ;FrontColor
    BackColor.s                   ;FrontColor
    Constants.s                   ;Available Constants (Ex: "#PB_Text_Center,#PB_Text_Right,#PB_Text_Border")
    ModelType.i                   ;0=Window, 2=Gadget, 9=Gadget Deleted
    Key.s                         ;ModelType + GadgetY(IdGadget) + GadgetX(IdGadget)
  EndStructure
  Global Dim Gadgets.StructureGadget(0), CountGadgets.i, CountImageBtn.i
  
  Global X.i, Y.i
  
  Declare.f AjustFontSize(Size.l)
  Declare LoadFontWML()
  Declare LoadControls()
  Declare ClickHoverGridArea(Window.i)
  Declare GadgetHoverCheck(Window.i, Gadget.i)
  Declare InitModelWindow()
  Declare InitModelgadget()
  Declare CreateGadgets(IdModel.i)
  Declare LoadPBObjectEnum()
  Declare AboutForm()
  Declare CodeGenerateForm()
  Declare InitWindowSelected()
  Declare InitProperties()
  Declare LoadGadgetProperties(IdGadget.i)
  Declare DrawSelectedImage(IdGadget.i, ImagePath.s)
  Declare ResizeDrawArea(Width.i, Height.i)
  Declare WindowSize()
  Declare OpenMainWindow(X = 0, Y = 0, Width = 800, Height = 580)
  Declare SVDGadgetTest()
  Declare Exit()
  
  UsePNGImageDecoder()
  UseJPEGImageDecoder()
  
  Procedure.f AjustFontSize(lSize.l)   ;Windows DPI aware by using the font size based on the number of pixels per inch along the screen
    Define.i iimage
    Static.f fPpp
    CompilerIf #PB_Compiler_OS = #PB_OS_MacOS   ;How to with Mac retina display
      ProcedureReturn lSize
    CompilerElse
      If fPpp = 0
        iimage = CreateImage(#PB_Any,1,1)
        If IsImage(iimage)
          If StartVectorDrawing(ImageVectorOutput(iimage))
            fPpp = VectorResolutionX()
            StopVectorDrawing()
          EndIf
          FreeImage(iimage)
        EndIf
      EndIf
      ProcedureReturn (lSize * 96) / fPpp
    CompilerEndIf
  EndProcedure
  
  Procedure LoadFontWML()   ;Most common fonts on Windows, Mac, and linux/Unix OS with +- a similar size: Verdana, Arial, courrier New.
    If LoadFont(#FontWML, "Verdana", AjustFontSize(8))
      SetGadgetFont(#PB_Default, FontID(#FontWML))   ; Set the loaded Verdana 8 font as new default font for all Gadgets
    ElseIf LoadFont(#FontWML, "Arial", AjustFontSize(8))
      SetGadgetFont(#PB_Default, FontID(#FontWML))   ; Set the loaded Arial 8 font as new default font for all Gadgets
    EndIf                                            ;If not loaded: SetGadgetFont(#PB_Default, #PB_Default): set the font settings back to original standard font
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
  
  Procedure  ClickHoverGridArea(Window.i)
    Protected X = ParentWidth + GadgetX(#ScrollDrawArea) - GetGadgetAttribute(#ScrollDrawArea, #PB_ScrollArea_X), Y = ParentHeight + GadgetY(#ScrollDrawArea) - GetGadgetAttribute(#ScrollDrawArea, #PB_ScrollArea_Y)
    Protected Mx = WindowMouseX(0), My = WindowMouseY(0)
    If Mx > GadgetX(#ScrollDrawArea) And Mx < X And My > GadgetY(#ScrollDrawArea) And My < Y
      ProcedureReturn 1   ;Mouse is on Gadget
    EndIf
    ProcedureReturn 0   ;Mouse is not on Gadget
  EndProcedure
  
  Procedure GadgetHoverCheck(Window.i, Gadget.i)
    Protected X, Y
    Protected Mx = WindowMouseX(Window), My = WindowMouseY(Window)
    If IsGadget(Gadget)
      X = GadgetX(Gadget) : Y = GadgetY(Gadget)
      If Mx > X And Mx < (X + GadgetWidth(Gadget)) And My > Y And My < (Y + GadgetHeight(Gadget) )
        ProcedureReturn 1   ;Mouse is on Gadget
      EndIf
    EndIf
    ProcedureReturn 0   ;Mouse is not on Gadget
  EndProcedure
  
  Procedure InitModelWindow()   ;Initializing Window Templates
    Protected Buffer.s
    With ModelGadget(0)
      ;Draw Area Width and Height with associated Spin Gadgets
      SetGadgetState(#PosGadgetWidth, \DftWidth)
      SetGadgetState(#PosGadgetHeight, \DftHeight)
      SetGadgetState(#SetDrawWidth, \DftWidth)
      SetGadgetState(#SetDrawHeight,  \DftHeight)
      ;DrawArea Size max Width and max Height
      DrawAreaSize(\DftWidth, \DftHeight)
      ;Save window information in the gadget List. Element 0
      Gadgets(0)\IdGadget=#MainWindow
      Gadgets(0)\IdModel=0
      Gadgets(0)\Name="#"+\Name+"_0"
      If Mid(\Caption, 7) <> ""   ;"#Text:blabla"
        Gadgets(0)\Caption=\Caption
      Else
        Gadgets(0)\Caption="#Text:" + \Name+"_0"
      EndIf
      Gadgets(0)\Option1=\Option1
      Gadgets(0)\Option2=\Option2
      Gadgets(0)\Option3=\Option3
      Gadgets(0)\FrontColor=\FrontColor
      Gadgets(0)\BackColor=\BackColor
      Gadgets(0)\ToolTip=\ToolTip
      Gadgets(0)\Constants=\Constants
      Gadgets(0)\ModelType=0   ;0=Window
                               ;Add Window to List Gadgets ComboBox. Element 0 for the Window Draw Area
      AddGadgetItem(#ListGadgets, -1, Gadgets(0)\Name)
      SetGadgetState(#ListGadgets, 0)
      SetGadgetItemData(#ListGadgets, 0, 0)
    EndWith
  EndProcedure
  
  Procedure InitModelgadget()   ;Initializing Gadget Templates
    Protected Buffer.s, GadgetCtrlFound.b, I.i, J.i
    Restore ModelGadgets
    For I=0 To 31
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
        If I = 0
          InitModelWindow()   ;Draw Area Width and Height and Save Window information
        Else
          GadgetCtrlFound = #False
          For J = 1 To ArraySize(GadgetCtrlArray())   ;Load Popup Menu Image and ListIcon Controls Gadgets with Image
            If GadgetCtrlArray(J)\GadgetCtrlName = LCase(\Model)
              GadgetCtrlFound = #True
              AddGadgetItem(#ControlsListIcon, -1, \Model, ImageID(GadgetCtrlArray(J)\GadgetCtrlImage))
              MenuItem(I, \Model, ImageID(GadgetCtrlArray(J)\GadgetCtrlImage))   ;Add to popup menu
            EndIf
          Next
          If GadgetCtrlFound = #False   ;If image not found, use Vd_Unknow.png
            AddGadgetItem(#ControlsListIcon, -1, \Model, ImageID(GadgetCtrlArray(0)\GadgetCtrlImage))
            MenuItem(I, \Model, ImageID(GadgetCtrlArray(0)\GadgetCtrlImage))   ;Add to popup menu
          EndIf
        EndIf
      Next
    EndWith
  EndProcedure
  
  Procedure CreateGadgets(IdModel.i)
    Protected IdGadget.i, TmpCaption.s, Mini.i, Maxi.i, StepValue.i
    InitProperties()
    OpenGadgetList(#ScrollDrawArea)   ;Required when changing apps(ex: test generate code) to reopen the GadgetList
    With ModelGadget(IdModel)
      \CountGadget=\CountGadget+1   ;Updating the gadget counter by model
      CountGadgets=CountGadgets+1
      ReDim Gadgets(CountGadgets)
      
      X = GridMatch(X, MyGrid, 0, ParentWidth-\DftWidth)   ;Align on Grid and remains inside the grid
      Y = GridMatch(Y, MyGrid, 0, ParentHeight-\DftHeight)
      ;Default values from the gadget models table
      Select Left(\Caption, 5)
        Case "#Text"
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
      
      Select IdModel   ;Create Gadget depending on model
        Case 1  : IdGadget=ButtonGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, TmpCaption)
        Case 2  : IdGadget=ButtonImageGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, 0)
        Case 3  : IdGadget=  CalendarGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, 0)
        Case 4
          IdGadget=CanvasGadget(#PB_Any, X, Y, \DftWidth, \DftHeight)
          If StartDrawing(CanvasOutput(IdGadget))
            DrawText(5, 5, \Name+"_"+Str(\CountGadget), #Blue, #White)
            StopDrawing()
          EndIf
        Case 5  : IdGadget=CheckBoxGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, TmpCaption)
        Case 6
          IdGadget=ComboBoxGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, #PB_ComboBox_Editable)
          AddGadgetItem(Idgadget,-1,TmpCaption)
        Case 7
          IdGadget=ContainerGadget(#PB_Any, X, Y, \DftWidth, \DftHeight)
          CloseGadgetList()
        Case 8  : IdGadget=DateGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, TmpCaption)
        Case 9
          IdGadget=EditorGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, #PB_Editor_ReadOnly)
          AddGadgetItem(IdGadget, 0, \Name+"_"+Str(\CountGadget))
        Case 10 : IdGadget =ExplorerComboGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, "")
        Case 11 : IdGadget=ExplorerListGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, "")
        Case 12 : IdGadget=ExplorerTreeGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, "")
        Case 13
          IdGadget=FrameGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, TmpCaption)
        Case 14 : IdGadget=HyperLinkGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, TmpCaption, RGB(0,0,128))
        Case 15   ;We cheat with a Canvas instead of an ImageGadget
          IdGadget=CanvasGadget(#PB_Any, X, Y, \DftWidth, \DftHeight)
          If StartDrawing(CanvasOutput(IdGadget))
            DrawText(5, 5, \Name+"_"+Str(\CountGadget), #Blue, #White)
            StopDrawing()
          EndIf
        Case 16
          IdGadget=  IPAddressGadget(#PB_Any, X, Y, \DftWidth, \DftHeight)
          SetGadgetState(IdGadget, MakeIPAddress(127, 0, 0, 1))
        Case 17 : IdGadget=ListIconGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, TmpCaption, 100)
        Case 18 : IdGadget=ListViewGadget(#PB_Any, X, Y, \DftWidth, \DftHeight)
        Case 19 : IdGadget=OpenGLGadget(#PB_Any, X, Y, \DftWidth, \DftHeight)
        Case 20 : IdGadget=OptionGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, TmpCaption)
        Case 21
          IdGadget=PanelGadget(#PB_Any, X, Y, \DftWidth, \DftHeight)
          CloseGadgetList()
        Case 22
          Mini = Val(Mid(\Option1, 7)) : Maxi = Val(Mid(\Option2, 7))
          IdGadget=ProgressBarGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, Mini, Maxi)
          SetGadgetState(IdGadget, Mini+(Maxi-Mini)*2/3)
        Case 23
          If InitScintilla()
            IdGadget=ScintillaGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, 0)
          EndIf
        Case 24
          Mini = Val(Mid(\Option1, 7)) : Maxi = Val(Mid(\Option2, 7)) : StepValue = Val(Mid(\Option3, 7))   ;InnerWidth, InnerHeight
          IdGadget=ScrollAreaGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, Mini, Maxi, StepValue)
          CloseGadgetList()
        Case 25
          Mini = Val(Mid(\Option1, 7)) : Maxi = Val(Mid(\Option2, 7))
          IdGadget=ScrollBarGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, Mini, Maxi, 0)
        Case 26
          Mini = Val(Mid(\Option1, 7)) : Maxi = Val(Mid(\Option2, 7))
          IdGadget=SpinGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, Mini, Maxi, #PB_Spin_Numeric)
          SetGadgetState(IdGadget, Mini+(Maxi-Mini)*2/3)
        Case 27
          IdGadget=StringGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, TmpCaption, #PB_String_ReadOnly)
        Case 28 : IdGadget=TextGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, TmpCaption)
        Case 29
          Mini = Val(Mid(\Option1, 7)) : Maxi = Val(Mid(\Option2, 7))
          IdGadget=TrackBarGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, Mini, Maxi)
          SetGadgetState(IdGadget, Mini+(Maxi-Mini)*2/3)
        Case 30 : IdGadget=TreeGadget(#PB_Any, X, Y, \DftWidth, \DftHeight)
        Case 31 : IdGadget=WebGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, TmpCaption)
      EndSelect
      
      SetGadgetData(IdGadget, CountGadgets)   ;Add Gadget Counter to Gadget Data
      
      ;Save gadget information in the gadget List
      Gadgets(CountGadgets)\IdGadget=Idgadget
      Gadgets(CountGadgets)\IdModel=IdModel
      Gadgets(CountGadgets)\Name="#"+\Name+"_"+Str(\CountGadget)
      ;Default values from the gadget models table
      Select Left(\Caption, 5)
        Case "#Text" : Gadgets(CountGadgets)\Caption = "#Text:" + TmpCaption
        Case "#Date" : Gadgets(CountGadgets)\Caption = "#Date:" + TmpCaption
        Case "#Dir$" : Gadgets(CountGadgets)\Caption = "#Dir$:" + TmpCaption
        Case "#Url$" : Gadgets(CountGadgets)\Caption = "#Url$:" + TmpCaption
        Default : Gadgets(CountGadgets)\Caption=\Caption
      EndSelect
      
      Gadgets(CountGadgets)\Option1=\Option1
      Gadgets(CountGadgets)\Option2=\Option2
      Gadgets(CountGadgets)\Option3=\Option3
      Gadgets(CountGadgets)\FrontColor=\FrontColor
      Gadgets(CountGadgets)\BackColor=\BackColor
      Gadgets(CountGadgets)\ToolTip=\ToolTip
      Gadgets(CountGadgets)\Constants=\Constants
      Gadgets(CountGadgets)\ModelType=2   ;2=Gadget
      
      ;Add Gadget to List Gadgets ComboBox with IdGadget as Data. Element 0 is reserved for Window Draw Area
      AddGadgetItem(#ListGadgets, -1, Gadgets(CountGadgets)\Name)
      SetGadgetState(#ListGadgets, CountGadgetItems(#ListGadgets)-1)
      SetGadgetItemData(#ListGadgets, CountGadgetItems(#ListGadgets)-1, IdGadget)
      ;Add Drag Handle Gadget in module
      AddSVDGadget(IdGadget)
    EndWith
  EndProcedure
  
  Procedure LoadPBObjectEnum()
    Protected GadgetObj.i, I.i
    ;Create Gadgets from PB Object Enumeration. To see if there is a way to load them from SweetyVD.exe !
    PB_Object_EnumerateStart(PB_Gadget_Objects)
    While PB_Object_EnumerateNext(PB_Gadget_Objects, @GadgetObj)
      If GetGadgetData(GadgetObj) <> #PB_Ignore
        For I = 0 To ArraySize(ModelGadget())
          With ModelGadget(I)
            If \Type = GadgetType(GadgetObj)
              
              \CountGadget=\CountGadget+1   ;   ;Updating the gadget counter by model
              CountGadgets=CountGadgets+1
              ReDim Gadgets(CountGadgets)
              
              SetGadgetData(GadgetObj, CountGadgets)   ;)   ;Add Gadget Counter to Gadget Data
              
              ;Save gadget information in the gadget List
              Gadgets(CountGadgets)\IdGadget=GadgetObj
              Gadgets(CountGadgets)\IdModel=I
              Gadgets(CountGadgets)\Name="#"+\Name+"_"+Str(\CountGadget)
              ;Default values from the gadget models table
              If \Caption = "#Nooo"
                Gadgets(CountGadgets)\Caption=\Caption
              Else
                Gadgets(CountGadgets)\Caption=\Name+"_"+Str(\CountGadget)
              EndIf
              Gadgets(CountGadgets)\Option1=\Option1
              Gadgets(CountGadgets)\Option2=\Option2
              Gadgets(CountGadgets)\Option3=\Option3
              Gadgets(CountGadgets)\FrontColor=\FrontColor
              Gadgets(CountGadgets)\BackColor=\BackColor
              Gadgets(CountGadgets)\Constants=\Constants
              Gadgets(CountGadgets)\ModelType=2   ;2=Gadget
              
              ;Add Gadget to List Gadgets ComboBox with IdGadget as Data. Element 0 is reserved for Window Draw Area
              AddGadgetItem(#ListGadgets, -1, Gadgets(CountGadgets)\Name)
              SetGadgetState(#ListGadgets, CountGadgetItems(#ListGadgets)-1)
              SetGadgetItemData(#ListGadgets, CountGadgetItems(#ListGadgets)-1, GadgetObj)
              Break
            EndIf
          Next
        EndWith
      EndIf
    Wend
  EndProcedure
  
  Procedure AboutForm()
    If OpenWindow(#AboutForm, WindowX(#MainWindow)+GadgetX(#CodeCreate), WindowY(#MainWindow)+70 , 310, 220, "SweetyVD: Licence",#PB_Window_TitleBar)
      ButtonGadget(#AboutBack, 255, 198, 50, 18, "Back")
      EditorGadget(#Licence, 5, 5, 300, 190, #PB_Editor_ReadOnly)
      SetGadgetColor(#Licence, #PB_Gadget_BackColor,RGB(225,230,235))
      AddGadgetItem(#Licence,-1,"SweetyVD is an open and Freeware tool")
      AddGadgetItem(#Licence,-1,"and is Free of all Cost.")
      AddGadgetItem(#Licence,-1,"")
      AddGadgetItem(#Licence,-1,"You may use an unlimited number")
      AddGadgetItem(#Licence,-1,"of copies of this tool.")
      AddGadgetItem(#Licence,-1,"")
      AddGadgetItem(#Licence,-1,"You may freely distribute SweetyVD.")
      AddGadgetItem(#Licence,-1,"But you can Not sell it.")
      AddGadgetItem(#Licence,-1,"")
      AddGadgetItem(#Licence,-1,"SweetyVD is provided "+#DQUOTE$+"As IS"+#DQUOTE$+" without warranty.")
      AddGadgetItem(#Licence,-1,"The use of the Software is at your own Risk.")
      AddGadgetItem(#Licence,-1,"")
      AddGadgetItem(#Licence,-1,"Thanks to Give Credit Where It's Due.")
      AddGadgetItem(#Licence,-1,Chr(169)+"2017 ChrisR")
    EndIf
  EndProcedure
  
  Procedure CodeGenerateForm()
    Protected AnyGadgets.b = #False, I.i
    For I = 1 To ArraySize(Gadgets())   ;At least one Gadget is required
      If Gadgets(I)\Idgadget > 0 And Gadgets(I)\ModelType=2
        AnyGadgets = #True
        Break
      EndIf
    Next
    
    If AnyGadgets   ;If at least one Gadget
      If OpenWindow(#CodeForm, WindowX(#MainWindow)+GadgetX(#CodeCreate), WindowY(#MainWindow)+70 , 230 , 180, "SweetyVD: PureBasic code Generation",#PB_Window_TitleBar)
        CheckBoxGadget(#CodeIncTitle, 30, 5, 160, 25, "IncludeTitle block") : SetGadgetState(#CodeIncTitle, #PB_Checkbox_Checked)
        CheckBoxGadget(#CodeIncEnum, 30, 30, 160, 25, "Include enumeration") : SetGadgetState(#CodeIncEnum, #PB_Checkbox_Checked)
        FrameGadget(#CodeFrame, 26, 53, 180, 35, "")
        OptionGadget(#CodeConstants, 31, 63, 85, 20, "Constants") : SetGadgetState(#CodeConstants,#True)
        OptionGadget(#CodePBany, 116, 63, 70, 20, "#PB_Any")
        CheckBoxGadget(#CodeAddStatusBar, 30, 90, 160, 25, "Add a Status Bar")
        CheckBoxGadget(#CodeIncEvent, 30, 115, 160, 25, "Include the event loop") : SetGadgetState(#CodeIncEvent, #PB_Checkbox_Checked)
        CatchImage(#Img_About,?Img_About)
        ButtonImageGadget(#AboutButton, 198, 5, 25, 25, ImageID(#Img_About))
        ButtonGadget(#CodePerform, 20, 145, 80, 25, "Generate", #PB_Button_Toggle) : SetGadgetState(#CodePerform, #True)
        ButtonGadget(#CodeCancel, 130, 145, 80, 25, "Cancel")
      EndIf
    Else
      MessageRequester("SweetyVD Information", "Let me play with at least one Gadget. Please  ;)", #PB_MessageRequester_Warning|#PB_MessageRequester_Ok)
    EndIf
  EndProcedure
  
  Procedure CodeGenerate()
    Protected Dim Buffer.StructureGadget(0)
    Protected IdGadget.i, SavModelType = -1
    Protected ImageExtPath.s, ImageExtFullPath.s, TmpImagePath.s
    Protected Code.s, Model.s, Name.s, X.s, Y.s, Width.s, Height.s, Caption.s, Caption7.s
    Protected Mini.i, Maxi.i, TmpConstants.s, FirstPass.b, INDENT$ = "  ", I.i, J.i
    
    CopyArray(Gadgets(), Buffer())   ;Sort: Creation of the Model key (Window or Gadget) + Position X + Position Y
    For I=0 To ArraySize(Buffer())
      With Buffer(I)
        If \ModelType = 9   ;Gadget Deleted
          \Key = Str(\ModelType) + RSet("0", 5, "0") + RSet("0", 5, "0")
        ElseIf \ModelType = 2
          \Key = Str(\ModelType) + RSet(Str(GadgetY(\Idgadget)), 5, "0") + RSet(Str(GadgetX(\Idgadget)), 5, "0")
        Else
          \Key = Str(\ModelType) + RSet("0", 5, "0") + RSet("0", 5, "0")
        EndIf
      EndWith
    Next
    SortStructuredArray(Buffer(), #PB_Sort_Ascending, OffsetOf(StructureGadget\Key), TypeOf(StructureGadget\Key))
    
    If GetGadgetState(#CodeIncTitle) = #True   ;-Include Title block
      Code = "; -----------------------------------------------------------------------------" +#CRLF$
      Code + ";           Name:" +#CRLF$
      Code + ";    Description:" +#CRLF$
      Code + ";         Author:" +#CRLF$
      Code + ";           Date: " + FormatDate("%yyyy-%mm-%dd", Date()) +#CRLF$
      Code + ";        Version:" +#CRLF$
      Code + ";     PB-Version:" +#CRLF$
      Code + ";             OS:" +#CRLF$
      Code + ";         Credit:" +#CRLF$
      Code + ";   French-Forum:" +#CRLF$
      Code + "; -----------------------------------------------------------------------------" +#CRLF$+#CRLF$
    Else
      Code = #CRLF$
    EndIf
    Code + "EnableExplicit" +#CRLF$+#CRLF$
    
    If GetGadgetState(#CodeIncEnum) = #True   ;-Include Enumeration
      For I=0 To ArraySize(Buffer())
        With Buffer(I)
          If \ModelType = 9 : Break : EndIf   ;Gadget Deleted
          Select \ModelType
            Case 0
              If \ModelType <> SavModelType
                SavModelType = \ModelType
                If GetGadgetState(#CodeConstants) : Code + "Enumeration Window" +#CRLF$ : EndIf
              EndIf
              
            Case 2
              If \ModelType <> SavModelType
                SavModelType = \ModelType
                If GetGadgetState(#CodeAddStatusBar) = #True
                  If GetGadgetState(#CodeConstants)
                    Code + "EndEnumeration" +#CRLF$+#CRLF$
                    Code + "Enumeration StatusBar" +#CRLF$+INDENT$+ "#StatusBar_0" +#CRLF$
                  Else
                    Code +#CRLF$+ "Global StatusBar_0" +#CRLF$
                  EndIf
                EndIf
                If GetGadgetState(#CodeConstants)
                  Code + "EndEnumeration" +#CRLF$+#CRLF$
                  Code + "Enumeration Gadgets" +#CRLF$
                Else
                  Code +#CRLF$
                EndIf
              EndIf
          EndSelect
          
          If GetGadgetState(#CodeConstants)
            Code +INDENT$+ \Name +#CRLF$
          Else
            Code + "Global " + Mid(\Name,2) +#CRLF$
          EndIf
        EndWith
      Next
      If GetGadgetState(#CodeConstants)
        Code + "EndEnumeration" +#CRLF$+#CRLF$
      Else
        Code +#CRLF$
      EndIf
      
      If ArraySize(ImageBtnPathArray()) > 0   ;Image Enumeration
        If GetGadgetState(#CodeConstants) : Code + "Enumeration FormImage"+#CRLF$ :EndIf
        For I = 1 To ArraySize(ImageBtnPathArray())
          If FileSize(ImageBtnPathArray(I)\ImagePath)
            If GetGadgetState(#CodeConstants)
              Code +INDENT$+ "#Img_Window_" + Str(I) +#CRLF$
            Else
              Code + "Global Img_Window_" + Str(I) +#CRLF$
            EndIf
          EndIf
        Next
        If GetGadgetState(#CodeConstants)
          Code + "EndEnumeration" +#CRLF$+#CRLF$
        Else
          Code +#CRLF$
        EndIf
        
        For I=1 To ArraySize(ImageBtnPathArray())   ;UseIMAGEDecoder
          ImageExtPath = LCase(GetExtensionPart(ImageBtnPathArray(I)\ImagePath))
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
        Next
        If ImageExtFullPath <> ""
          Code +#CRLF$
        EndIf
        
        For I = 1 To ArraySize(ImageBtnPathArray())   ;LoadImage
          If FileSize(ImageBtnPathArray(I)\ImagePath)
            If GetGadgetState(#CodeConstants)
              Code + "LoadImage(#Img_Window_" + Str(I) + ", " + #DQUOTE$ + ImageBtnPathArray(I)\ImagePath + #DQUOTE$ + ")" +#CRLF$
            Else
              Code + "Global Img_Window_" + Str(I) + " = LoadImage(#PB_Any, " + #DQUOTE$ + ImageBtnPathArray(I)\ImagePath + #DQUOTE$ + ")" +#CRLF$
            EndIf
          EndIf
        Next
        Code +#CRLF$
      EndIf
      
      Code + "Define.l Event" +#CRLF$+#CRLF$
    EndIf
    
    ;-Create Window
    With Buffer(0)
      If GetGadgetState(#CodeConstants) : Name = \Name : Else : Name = Mid(\Name,2) : EndIf
      Width = GetGadgetText(#SetDrawWidth) : Height = GetGadgetText(#SetDrawHeight)
      Caption = Mid(\Caption, 7)
      
      Code + "Declare Open_"+Mid(\Name,2)+"(X = 0, Y = 0, Width = "+Width+", Height = "+Height+")" +#CRLF$+#CRLF$
      Code + "Procedure Open_"+Mid(\Name,2)+"(X = 0, Y = 0, Width = "+Width+", Height = "+Height+")" +#CRLF$
      
      If GetGadgetState(#CodeConstants)
        Code +INDENT$+ "If OpenWindow("+Name+", X, Y, Width, Height, "
      Else
        Code +INDENT$+ Name + " = OpenWindow(#PB_Any, X, Y, Width, Height, "
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
      If GetGadgetState(#CodeConstants) = #False : Code +INDENT$+ "If " + Name +#CRLF$ :EndIf
      
      If Left(\BackColor, 5) <> "#Nooo" And \BackColor <> ""   ;Background window color
        Code +INDENT$+INDENT$+ "SetWindowColor(" + Name + ", " + \BackColor + ")" +#CRLF$
      EndIf
    EndWith
    
    If GetGadgetState(#CodeAddStatusBar)   ;Add a Status Bar Enumeration
      If GetGadgetState(#CodeConstants)
        Code +INDENT$+INDENT$+ "CreateStatusBar(#StatusBar_0, WindowID(" + Name + "))" +#CRLF$
      Else
        Code +INDENT$+INDENT$+ "StatusBar_0 = CreateStatusBar(#PB_Any, WindowID(" + Name + "))" +#CRLF$
      EndIf
    EndIf
    
    ;-Create Gadgets
    For I=1 To ArraySize(Buffer())
      With Buffer(I)
        If \ModelType = 9 : Break : EndIf   ;Gadget Deleted
        If \ModelType = 2                   ;2=Gadget
          IdGadget = \IdGadget
          Model = ModelGadget(\IdModel)\Model
          If GetGadgetState(#CodeConstants) : Name = \Name : Else : Name = Mid(\Name,2) : EndIf
          X = Str(GadgetX(IdGadget)) : Y = Str(GadgetY(IdGadget))
          Width = Str(GadgetWidth(IdGadget)) : Height = Str(GadgetHeight(IdGadget))
          Caption = Mid(\Caption, 7)   ;
          
          If \IdModel = 23   ;Specific ScintillaGadget: If InitScintilla() : ScintillaGadget(xxx) : EndIf
            Code +INDENT$+INDENT$+ "If InitScintilla()" +#CRLF$+INDENT$
          EndIf
          
          If GetGadgetState(#CodeConstants)
            Code +INDENT$+INDENT$+ Model + "(" + Name + ", " + X + ", " + Y + ", " + Width + ", " + Height   ;Common part
          Else
            Code +INDENT$+INDENT$+ Name + " = " + Model + "(#PB_Any, " + X + ", " + Y + ", " + Width + ", " + Height   ;Common part
          EndIf
          
          Select Left(\Caption, 5)
            Case "#Text" : Code + ", " + #DQUOTE$ + Caption + #DQUOTE$   ;Caption=#Text:blabla => "blabla", or ""
            Case "#Date"
              If Caption <> "" : Code + ", " + #DQUOTE$ + Caption + #DQUOTE$ : EndIf   ;;"%dd/%mm/%yyyy". If empty, nothing and no comma for the default value
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
                Code + ", 0"
              Else
                For J=1 To ArraySize(ImageBtnPathArray())   ;LoadImage
                  If ImageBtnPathArray(J)\ImagePath =TmpImagePath
                    If GetGadgetState(#CodeConstants)
                      Code + ", ImageID(#Img_Window_" + Str(J) + ")"
                    Else
                      Code + ", ImageID(Img_Window_" + Str(J) + ")"
                    EndIf
                    
                    Break
                  EndIf
                Next
              EndIf
          EndSelect
          
          Select Left(\Option2, 5)
            Case "#Maxi" : Code + ", " + Mid(\Option2, 7)
            Case "#InrH" : Code + ", " + Mid(\Option2, 7)
            Case "#Widh" : Code + ", " + Mid(\Option2, 7)
          EndSelect
          
          ;Specific addition
          Select \IdModel
            Case 24 : Code + ", " + Mid(\Option3, 7)   ;Specific ScrollAreaGadget: Displacement Value
            Case 25 : Code + ", 0"                     ;Specific ScrollBarGadget: Page length
              
          EndSelect
          
          If \Constants <> ""   ;Are there any Constants for the window
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
                Code + "#PB_" + Left(TmpConstants, Len(TmpConstants)-3)
              EndIf
            Next
          EndIf
          
          Code + ")" +#CRLF$   ;End of generation of the gadget code
          
          ;Specific addition
          Select \IdModel
            Case 6   ;ComboBoxGadget
              Code +INDENT$+INDENT$+ "AddGadgetItem("+ Name + ", -1, " + #DQUOTE$ + Mid(\Name,2) + #DQUOTE$ + ")" +#CRLF$
              Code +INDENT$+INDENT$+ "SetGadgetState("+ Name + ", 0)" +#CRLF$
            Case 9   ;EditorGadget
              Code +INDENT$+INDENT$+ "AddGadgetItem("+ Name + ", -1, " + #DQUOTE$ + Mid(\Name,2) + #DQUOTE$ + ")" +#CRLF$
            Case 16   ;IPAddressGadget
              Code +INDENT$+INDENT$+ "SetGadgetState("+ Name + ", MakeIPAddress(127, 0, 0, 1))" +#CRLF$
            Case 23   ;ScintillaGadget
              : Code +INDENT$+INDENT$+ "EndIf" +#CRLF$
            Case 22, 26, 29   ;ProgressBarGadget, SpinGadget, TackBarGadget: Cosmetic, progression 2/3
              Mini = Val(Mid(\Option1, 7)) : Maxi = Val(Mid(\Option2, 7))
              Code +INDENT$+INDENT$+ "SetGadgetState("+ Name + ", " + Str(Mini+(Maxi-Mini)*2/3) + ")" +#CRLF$
          EndSelect
          
          If Left(\FrontColor, 5) <> "#Nooo" And \FrontColor <> ""
            Code +INDENT$+INDENT$+ "SetGadgetColor(" + Name + ", #PB_Gadget_FrontColor, " + \FrontColor + ")" +#CRLF$
          EndIf
          If Left(\BackColor, 5) <> "#Nooo" And \BackColor <> ""
            Code +INDENT$+INDENT$+ "SetGadgetColor(" + Name + ", #PB_Gadget_BackColor, " + \BackColor + ")" +#CRLF$
          EndIf
          
          If \ToolTip <> "#Nooo"
            Code +INDENT$+INDENT$+ "GadgetToolTip(" + Name + ", " + #DQUOTE$ + \ToolTip + #DQUOTE$ + ")" +#CRLF$
          EndIf
          
          If \IdModel = 7 Or \IdModel = 21 Or \IdModel = 24   ;ContainerGadget, PanelGadget, ScrollAreaGadget
            Code +INDENT$+INDENT$+ "CloseGadgetList()" +#CRLF$
          EndIf
          
        EndIf
      EndWith
    Next
    
    Code +INDENT$+ "EndIf" +#CRLF$
    Code + "EndProcedure" +#CRLF$+#CRLF$
    
    Code + "Open_" + Mid(Buffer(0)\Name,2) + "()" +#CRLF$+#CRLF$
    
    If GetGadgetState(#CodeIncEvent) = #True   ;-Include Event Loop
      Code + "Repeat" +#CRLF$
      Code +INDENT$+ "Event = WaitWindowEvent()" +#CRLF$
      Code +INDENT$+ "Select Event" +#CRLF$
      Code +INDENT$+INDENT$+ "Case #PB_Event_Menu" +#CRLF$
      Code +INDENT$+INDENT$+INDENT$+ "Select EventMenu()" +#CRLF$
      Code +INDENT$+INDENT$+INDENT$+ "EndSelect" +#CRLF$+#CRLF$
      Code +INDENT$+INDENT$+ "Case #PB_Event_Gadget" +#CRLF$
      Code +INDENT$+INDENT$+INDENT$+ "Select EventGadget()" +#CRLF$
      For I=1 To ArraySize(Buffer())
        If Buffer(I)\ModelType = 9 : Break : EndIf   ;Gadget Deleted
        If Buffer(I)\IdModel = 1                     ;Button
          If GetGadgetState(#CodeConstants)
            Code +INDENT$+INDENT$+INDENT$+INDENT$+ "Case " + Buffer(I)\Name +#CRLF$
          Else
            Code +INDENT$+INDENT$+INDENT$+INDENT$+ "Case " + Mid(Buffer(I)\Name,2) +#CRLF$
          EndIf
        EndIf
      Next
      Code +INDENT$+INDENT$+INDENT$+ "EndSelect" +#CRLF$+#CRLF$
      Code +INDENT$+INDENT$+ "Case #PB_Event_CloseWindow" +#CRLF$
      Code +INDENT$+INDENT$+INDENT$+ "End" +#CRLF$
      Code +INDENT$+ "EndSelect" +#CRLF$
      Code + "ForEver" +#CRLF$
    EndIf
    
    SetClipboardText(Code)   ;Copy the code to the clipboard
    FreeArray(Buffer())
    CloseWindow(#CodeForm)
    MessageRequester("SweetyVD Information", "The Generate Code is copied to the Clipboard  :)", #PB_MessageRequester_Info|#PB_MessageRequester_Ok)
  EndProcedure
  
  Procedure InitWindowSelected()
    SetGadgetState(#ListGadgets, #MainWindow)
    SetGadgetState(#PosGadgetX, 0) : SetGadgetState(#PosGadgetY, 0)
    SetGadgetState(#PosGadgetWidth, GetGadgetState(#SetDrawWidth)) : SetGadgetState(#PosGadgetHeight, GetGadgetState(#SetDrawHeight))
    LoadGadgetProperties(#MainWindow)
  EndProcedure
  
  Procedure InitProperties()
    DisableGadget(#CaptionString,#True)
    DisableGadget(#ToolTipString,#False)
    HideGadget(#MiniText, #True) : HideGadget(#MiniString, #True)
    HideGadget(#MaxiText, #True) : HideGadget(#MaxiString, #True)
    HideGadget(#ImageText, #True) : HideGadget(#ImageString, #True) : HideGadget(#ImagePick, #True)
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
    Protected GadgetsElement.i, TmpConstants.s, I.i
    InitProperties()
    If IsGadget(IdGadget) : GadgetsElement = GetGadgetData(IdGadget) : EndIf
    If IsWindow(IdGadget) : GadgetsElement = 0 : DisableGadget(#ToolTipString,#True) : EndIf
    With Gadgets(GadgetsElement)
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
      EndSelect
      
      If \IdModel = 24 : SetGadgetText(#MiniText, "InnerW") : SetGadgetText(#MaxiText, "InnerH") : EndIf   ;ScrollAreaGadget
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
      For I=1 To CountString(\Constants, "|") + 1
        TmpConstants = Trim(StringField(\Constants, I, "|"))
        If TmpConstants <> ""
          If Right(TmpConstants, 3) = "(x)"
            AddGadgetItem(#Constants, -1, Left(TmpConstants, Len(TmpConstants)-3))
            SetGadgetItemState(#Constants, I-1,  #PB_ListIcon_Checked)
          Else
            AddGadgetItem(#Constants, -1, TmpConstants)
          EndIf
        EndIf
      Next
    EndWith
  EndProcedure
  
  Procedure DrawSelectedImage(IdGadget.i, ImagePath.s)
    Protected TmpImage.i, ImageBtn.i, Rtn.i, I.i
    If ImagePath
      TmpImage = LoadImage(#PB_Any, ImagePath)
      If TmpImage
        Rtn = MessageRequester("SweetyVD Information", "Do you want to resize the gadget to the image size ?", #PB_MessageRequester_Info|#PB_MessageRequester_YesNo)
        If Rtn = 6     ;the YES button was chosen (Result=7 for the NO button)
          If GadgetX(IdGadget) + ImageWidth(TmpImage) > ParentWidth
            ResizeSVDGadget(IdGadget, ParentWidth-ImageWidth(TmpImage), -1, -1, -1)
          EndIf
          ResizeSVDGadget(IdGadget, -1, -1, ImageWidth(TmpImage), -1)
          If GadgetY(IdGadget) + ImageHeight(TmpImage) > ParentHeight
            ResizeSVDGadget(IdGadget, -1, ParentHeight-ImageHeight(TmpImage), -1, -1)
          EndIf
          ResizeSVDGadget(IdGadget, -1, -1, -1, ImageHeight(TmpImage))
        EndIf
        For I = 0 To ArraySize(ImageBtnPathArray())
          If ImageBtnPathArray(I)\ImagePath = ImagePath
            ImageBtn = ImageBtnPathArray(I)\ImageBtn
            Break
          EndIf
        Next
        If ImageBtn = 0
          CountImageBtn=CountImageBtn+1
          ReDim ImageBtnPathArray(CountImageBtn)
          ImageBtn = CopyImage(TmpImage, #PB_Any)
          ImageBtnPathArray(CountImageBtn)\ImageBtn=ImageBtn
          ImageBtnPathArray(CountImageBtn)\ImagePath=ImagePath
        EndIf
        FreeImage(TmpImage)
        Select GadgetType(IdGadget)
          Case 19
            SetGadgetAttribute(IdGadget, #PB_Button_Image, ImageID(ImageBtn))
            ResizeGadget(IdGadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore)
          Case 33
            SetGadgetAttribute(IdGadget, #PB_Canvas_Image, ImageID(ImageBtn))
        EndSelect
        SetGadgetText(#ImageString, ImagePath)   ;Or GetFilePart(ImagePath) and the same in LoadGadgetProperties
        Gadgets(GetGadgetData(IdGadget))\Option1 = "#Imag:"+ImagePath
      Else
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
        Gadgets(GetGadgetData(IdGadget))\Option1 = "#Imag:0"
      EndIf
    Else
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
      Gadgets(GetGadgetData(IdGadget))\Option1 = "#Imag:0"
    EndIf
  EndProcedure
  
  Procedure ResizeDrawArea(Width.i, Height.i)
    DrawAreaSize(Width, Height)   ;For ParentWidth(Height) with max displacement value
    If GetGadgetState(#ShowGrid) = #PB_Checkbox_Checked   ;and redraw the grid
      DrawGrid(#True, GetGadgetState(#GridSpacing))
    Else
      DrawGrid(#False)
    EndIf
  EndProcedure
  
  Procedure WindowSize()
    Protected DrawMaxWidth.i, DrawMaxHeight.i, ScrollMargin = 20
    ;Adjust width and height of the scroll drawing area according to window size
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
    EndIf
  EndProcedure
  
  Procedure OpenMainWindow(X = 0, Y = 0, Width = 800, Height = 580)
    Protected GadgetObj.i
    OpenWindow(#MainWindow, x, y, width, height, "SweetyVD (Visual Designer)", #PB_Window_SizeGadget | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_ScreenCentered | #PB_Window_SystemMenu)
    CreatePopupImageMenu(#PopUpMenu)
    ButtonGadget(#EnableSVD, 5, 5, 100, 25, "Enable SVD", #PB_Button_Toggle) : SetGadgetState(#EnableSVD, #True)
    ButtonGadget(#CodeCreate, 115, 5, 100, 25, "Create Code")
    
    ContainerGadget(#SettingContainer, 220, 5, 570, 30, #PB_Container_Raised) : HideGadget(#SettingContainer,#True)
    TextGadget(#SetDrawSizeText, 10, 4, 30, 20, "Size")
    SpinGadget(#SetDrawWidth, 40, 1, 70, 20, 1, 1920, #PB_Spin_Numeric)
    TextGadget(#SetDrawSizeTextX, 110, 4, 10, 20, "x", #PB_Text_Center)
    SpinGadget(#SetDrawHeight, 120, 1, 70, 20, 1, 1020, #PB_Spin_Numeric)
    TextGadget(#DragText, 215, 4, 75, 20, "Drag space")
    SpinGadget(#DragSVD, 290, 1, 50, 20, 1, 20, #PB_Spin_Numeric)  : SetGadgetState(#DragSVD, 10)
    CheckBoxGadget(#ShowGrid, 375, 2, 85, 20, "Show grid") : SetGadgetState(#ShowGrid, #PB_Checkbox_Checked)
    SpinGadget(#GridSpacing, 460, 1, 50, 20, 1, 50, #PB_Spin_Numeric) : SetGadgetState(#GridSpacing, 20)
    CloseGadgetList()
    
    ContainerGadget(#GadgetList, 5, 35, 210, 110, #PB_Container_Raised) : HideGadget(#GadgetList,#True)
    ComboBoxGadget(#ListGadgets, 2 ,5, 174, 22) ;Liste des gadgets
    CatchImage(#Img_Delete,?Img_Delete)
    ButtonImageGadget(#DeleteGadgetButton, 182, 5, 22, 22, ImageID(#Img_Delete))
    SpinGadget(#PosGadgetX, 2, 56, 70, 20, 0, 1920, #PB_Spin_Numeric) : SetGadgetState(#PosGadgetX, 0)
    SpinGadget(#PosGadgetY, 68, 32, 70, 20, 0, 1020, #PB_Spin_Numeric) : SetGadgetState(#PosGadgetY, 0)
    SpinGadget(#PosGadgetWidth, 133, 56, 70, 20, 1, 1920, #PB_Spin_Numeric)
    SpinGadget(#PosGadgetHeight, 68, 80, 70, 20, 1, 1020, #PB_Spin_Numeric)
    CloseGadgetList()
    
    ListIconGadget(#ControlsListIcon, 5, 150, 210, 180, "Common Controls", 186) : HideGadget(#ControlsListIcon,#True)
    ContainerGadget(#PropertiesContainer, 5, 335, 210, 95, #PB_Container_Raised) : HideGadget(#PropertiesContainer,#True)
    StringGadget(#CaptionText, 0, 2, 65, 22, "Caption", #PB_String_ReadOnly)
    StringGadget(#CaptionString, 65, 2, 141, 22, "")
    StringGadget(#ToolTipText, 0, 24, 65, 22, "ToolTip", #PB_String_ReadOnly)
    StringGadget(#ToolTipString, 65, 24, 141, 22, "")
    StringGadget(#MiniText, 0, 46, 52, 22, "Mini", #PB_String_ReadOnly)
    StringGadget(#MiniString, 52, 46, 50, 22, "0", #PB_String_Numeric)
    StringGadget(#MaxiText, 104, 46, 52, 22, "Maxi", #PB_String_ReadOnly)
    StringGadget(#MaxiString, 156, 46, 50, 22, "100", #PB_String_Numeric)
    StringGadget(#ImageText, 0, 46, 65, 22, "Image", #PB_String_ReadOnly)
    StringGadget(#ImageString, 65, 46, 114, 22, "C:\xxxx\PB.jpg", #PB_String_ReadOnly)
    ButtonGadget(#ImagePick, 179, 46, 26, 22, "...") : HideGadget(#ImagePick, #True)
    TextGadget(#FrontColorText, 5, 72, 66, 22, "FrontColor")
    ButtonImageGadget(#FrontColorPick, 71, 70, 22, 18, 0)
    CreateImage(#FrontColorImg, 22, 22)
    TextGadget(#BackColorText, 114, 72, 66, 22, "BackColor")
    ButtonImageGadget(#BackColorPick, 180, 70, 22, 18, 0)
    CreateImage(#BackColorImg, 22, 22)
    CloseGadgetList()
    ListIconGadget(#Constants, 5, 435, 210, 135, "Options (#PB_)", 186, #PB_ListIcon_CheckBoxes) : HideGadget(#Constants,#True)
    
    ScrollAreaGadget(#ScrollDrawArea, 220, 35, 570, 535, 1930, 1030, 20, #PB_ScrollArea_Single)   ;InnerWidth,InnerHeight + 10 for the resize handle of the drawing window
    
    EnableGadgetDrop(#ControlsListIcon, #PB_Drop_Text, #PB_Drag_Copy)
    EnableGadgetDrop(#ScrollDrawArea, #PB_Drop_Text, #PB_Drag_Copy)
    
    ;All interface Objects must have #PB_Ignore as data. To not load them later when loading Designer
    PB_Object_EnumerateStart(PB_Gadget_Objects)
    While PB_Object_EnumerateNext(PB_Gadget_Objects, @GadgetObj)
      SetGadgetData(GadgetObj, #PB_Ignore)
    Wend
    ;*** Important *** Call InitSVD just after the ScrollArea and before creating Gadets on it: default param CountGadget.i = 144
    InitSVD()
  EndProcedure
  
  Procedure SVDGadgetTest()
    TextGadget(#TextGadget, 50, 50, 200, 20, "Hello world") : ResizeGadget(#TextGadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore)
    EditorGadget(#EditorGadget, 50, 100, 200, 50, #PB_Editor_WordWrap) : SetGadgetText(#EditorGadget, "On ne voit bien qu'avec le cœur. L'essentiel est invisible pour les yeux.")
    ComboBoxGadget(#ComboBox, 50, 180, 100, 25) : AddGadgetItem(#ComboBox, -1, "Bienvenue") : AddGadgetItem(#ComboBox, -1, "Welcome") : AddGadgetItem(#ComboBox, -1, "willkommen")
    ;ComboBox: Do not set load element to be displayed (SetGadgetState(#ComboBox, 1)
    ButtonGadget(#ButtonGadget, 330, 50, 140, 25, "Bonjour à tous", #PB_Button_MultiLine)
    CheckBoxGadget(#CheckBoxGadget, 340, 140, 120, 20, "Hallo Welt") : SetGadgetState(#CheckBoxGadget, #PB_Checkbox_Checked)
    TrackBarGadget(#TrackBarGadget, 320, 190, 160, 25, 0, 100) : SetGadgetState(#TrackBarGadget, 66) : ResizeGadget(#TrackBarGadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore)
    SpinGadget(#SpinGadget, 340, 240, 70, 25, 800, 1920, #PB_Spin_Numeric) : SetGadgetState(#SpinGadget, 1366)
    
    LoadPBObjectEnum()
  EndProcedure
  
  ;- Main
  Define *PosDim.PosDim
  Define IdGadget.i, GadgetsElement.i, ImagePath.s, TmpImage.i, SelectedColor.i, TmpConstants.s, I.i
  
  LoadFontWML()
  LoadControls()
  OpenMainWindow()
  InitModelgadget()   ;Initializing Gadget Templates
  BindEvent(#PB_Event_SizeWindow, @WindowSize())
  ;SVDGadgetTest()
  
  Repeat   ;- Event Loop
    Select WaitWindowEvent()
        
      Case #PB_Event_CloseWindow
        Exit()
        
      Case #PB_Event_LeftClick   ;does not work on Linux
        If GetGadgetState(#EnableSVD) = #False And GadgetHoverCheck(#MainWindow,#ScrollDrawArea) = #True
          InitWindowSelected()
        EndIf
        
      Case #PB_Event_RightClick   ;does not work on Linux
        If GetGadgetState(#EnableSVD) = #False And  ClickHoverGridArea(#MainWindow) = #True
          ;GadgetHoverCheck(#MainWindow,#ScrollDrawArea) = #True
          X=WindowMouseX(#MainWindow)-GadgetX(#ScrollDrawArea) + GetGadgetAttribute(#ScrollDrawArea, #PB_ScrollArea_X) : Y=WindowMouseY(#MainWindow)-GadgetY(#ScrollDrawArea) + GetGadgetAttribute(#ScrollDrawArea, #PB_ScrollArea_Y)  ;Keep the coordinates of the mouse before creating the gadget
          DisplayPopupMenu(#PopUpMenu,WindowID(#MainWindow))
        EndIf
        
      Case #PB_Event_GadgetDrop
        If EventGadget() = #ScrollDrawArea
          X=WindowMouseX(#MainWindow)-GadgetX(#ScrollDrawArea) + GetGadgetAttribute(#ScrollDrawArea, #PB_ScrollArea_X) : Y=WindowMouseY(#MainWindow)-GadgetY(#ScrollDrawArea) + GetGadgetAttribute(#ScrollDrawArea, #PB_ScrollArea_Y)  ;Keep the coordinates of the mouse before creating the gadget
          CreateGadgets(Val(EventDropText()))
        EndIf
        
      Case #PB_Event_Menu   ;-> Event Menu
        Select EventMenu()
          Case 1 To 31   ;Popup menu for creating gadgets
            CreateGadgets(EventMenu())
            
          Case #Shortcut_Delete   ;AddKeyboardShortcut is added on #PB_EventType_Focus and RemoveKeyboardShortcut on #PB_EventType_LostFocus in module, proc SVD_Callback
            If GetGadgetState(#ListGadgets) > 0
              IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
              If IsGadget(IdGadget)
                RemoveGadgetItem(#ListGadgets, GetGadgetState(#ListGadgets))
                For I = 1 To ArraySize(Gadgets())
                  If Gadgets(I)\Idgadget = IdGadget
                    Gadgets(I)\Idgadget = 0
                    Gadgets(I)\ModelType=9
                    Break
                  EndIf
                Next
                DeleteSVDGadget(IdGadget)
                InitWindowSelected()
              EndIf
            EndIf
            
          Case #Shortcut_Insert   ;Insert key as Right Click replacement under Linux
            If GetGadgetState(#EnableSVD) = #False And   ClickHoverGridArea(#MainWindow) = #True
              X=WindowMouseX(#MainWindow)-GadgetX(#ScrollDrawArea) + GetGadgetAttribute(#ScrollDrawArea, #PB_ScrollArea_X) : Y=WindowMouseY(#MainWindow)-GadgetY(#ScrollDrawArea) + GetGadgetAttribute(#ScrollDrawArea, #PB_ScrollArea_Y)  ;Keep the coordinates of the mouse before creating the gadget
              DisplayPopupMenu(#PopUpMenu,WindowID(#MainWindow))
            EndIf
        EndSelect
        
      Case #PB_Event_Gadget   ;-> Event Gadget
        If EventWindow()=#MainWindow
          Select EventGadget()
            Case #EnableSVD
              Select GetGadgetState(#EnableSVD)
                Case #True
                  SetGadgetText(#EnableSVD, "Enable SVD")
                  CompilerIf #PB_Compiler_OS = #PB_OS_Linux : RemoveKeyboardShortcut(#MainWindow, #PB_Shortcut_Insert) : CompilerEndIf   ;Insert key as Right Click replacement under Linux
                  HideGadget(#SettingContainer,#True)
                  HideGadget(#GadgetList,#True)
                  HideGadget(#PropertiesContainer,#True)
                  HideGadget(#ControlsListIcon,#True)
                  HideGadget(#Constants,#True)
                  DisableSVD()
                  DrawGrid(#False)
                  
                Case #False   ;EnableSVD Parameters: drawing area, Drag Space
                  SetGadgetText(#EnableSVD, "Disable SVD")
                  CompilerIf #PB_Compiler_OS = #PB_OS_Linux : AddKeyboardShortcut(#MainWindow, #PB_Shortcut_Insert, #Shortcut_Insert) : CompilerEndIf   ;Insert key as Right Click replacement under Linux
                  InitWindowSelected()
                  HideGadget(#SettingContainer,#False)
                  HideGadget(#GadgetList,#False)
                  HideGadget(#PropertiesContainer,#False)
                  HideGadget(#ControlsListIcon,#False)
                  HideGadget(#Constants,#False)
                  EnableSVD(GetGadgetState(#DragSVD))
                  If GetGadgetState(#ShowGrid) = #PB_Checkbox_Checked
                    DrawGrid(#True, GetGadgetState(#GridSpacing))
                  Else
                    DrawGrid(#False)
                  EndIf
              EndSelect
              
            Case #CodeCreate ;Génération du code
              CodeGenerateForm()
              
            Case #ListGadgets
              If GetGadgetState(#ListGadgets) = 0
                InitWindowSelected()
              Else
                IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
                If IsGadget(IdGadget)
                  SelectSVDGadget(IdGadget)
                Else
                  InitWindowSelected()
                EndIf
              EndIf
              
            Case #DeleteGadgetButton
              If GetGadgetState(#ListGadgets) > 0
                IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
                If IsGadget(IdGadget)
                  RemoveGadgetItem(#ListGadgets, GetGadgetState(#ListGadgets))
                  For I = 1 To ArraySize(Gadgets())
                    If Gadgets(I)\Idgadget = IdGadget
                      Gadgets(I)\Idgadget = 0
                      Gadgets(I)\ModelType=9
                      Break
                    EndIf
                  Next
                  DeleteSVDGadget(IdGadget)
                  InitWindowSelected()
                EndIf
              EndIf
              
            Case #ControlsListIcon   ;Element beging at 0 -> Element+1
              Select EventType()
                Case #PB_EventType_LeftDoubleClick
                  X = MyGrid : Y = MyGrid   ;coordinates for creating gadget inside #ScrollDrawArea
                  CreateGadgets(GetGadgetState(#ControlsListIcon)+1)
                Case #PB_EventType_DragStart
                  DragText(Str(GetGadgetState(#ControlsListIcon)+1))
              EndSelect
              
            Case #DragSVD
              MyGrid = GetGadgetState(#DragSVD)
              
            Case #ShowGrid
              If GetGadgetState(#ShowGrid) = #PB_Checkbox_Checked
                DrawGrid(#True, GetGadgetState(#GridSpacing))
              Else
                DrawGrid(#False)
              EndIf
              
            Case #GridSpacing
              If GetGadgetState(#ShowGrid) = #PB_Checkbox_Checked And GetGadgetState(#EnableSVD) = #False   ;Not to call it the first time on Linux
                DrawGrid(#True, GetGadgetState(#GridSpacing))
              EndIf
              
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
              
            Case #PosGadgetX
              If EventType() = #PB_EventType_Change And GetGadgetState(#ListGadgets) > 0
                IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
                If IsGadget(IdGadget)
                  ResizeSVDGadget(IdGadget, GetGadgetState(#PosGadgetX), -1, -1, -1)
                EndIf
              EndIf
              
            Case #PosGadgetY
              If EventType() = #PB_EventType_Change And GetGadgetState(#ListGadgets) > 0
                IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
                If IsGadget(IdGadget)
                  ResizeSVDGadget(IdGadget, -1, GetGadgetState(#PosGadgetY), -1, -1)
                EndIf
              EndIf
              
            Case #PosGadgetWidth
              If EventType() = #PB_EventType_Change And GetGadgetState(#ListGadgets) = 0
                SetGadgetState(#SetDrawWidth, GetGadgetState(#PosGadgetWidth))
                ResizeDrawArea(GetGadgetState(#SetDrawWidth), GetGadgetState(#SetDrawHeight))
              Else
                IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
                If IsGadget(IdGadget)
                  ResizeSVDGadget(IdGadget, -1, -1, GetGadgetState(#PosGadgetWidth), -1)
                  If GadgetType(IdGadget) = 33 And GetGadgetText(#ImageString) <> "0" And GetGadgetText(#ImageString) <> ""
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
              If EventType() = #PB_EventType_Change And GetGadgetState(#ListGadgets) = 0
                SetGadgetState(#SetDrawHeight, GetGadgetState(#PosGadgetHeight))
                ResizeDrawArea(GetGadgetState(#SetDrawWidth), GetGadgetState(#SetDrawHeight))
              Else
                IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
                If IsGadget(IdGadget)
                  ResizeSVDGadget(IdGadget, -1, -1, -1, GetGadgetState(#PosGadgetHeight))
                  If GadgetType(IdGadget) = 33 And GetGadgetText(#ImageString) <> "0" And GetGadgetText(#ImageString) <> ""
                    TmpImage = LoadImage(#PB_Any, GetGadgetText(#ImageString))
                    If TmpImage
                      ResizeImage(TmpImage, GetGadgetState(#PosGadgetWidth), GetGadgetState(#PosGadgetHeight))
                      SetGadgetAttribute(IdGadget, #PB_Canvas_Image, ImageID(TmpImage))
                      FreeImage(TmpImage)
                    EndIf
                  EndIf
                EndIf
              EndIf
              
              ;->> Event Gadget Properties
            Case #CaptionString
              If EventType() = #PB_EventType_Change
                IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
                If IsGadget(IdGadget)
                  GadgetsElement = GetGadgetData(IdGadget)   ;Element number in the Gadgets structure array
                  Select Left(Gadgets(GadgetsElement)\Caption, 5)
                    Case "#Text"
                      SetGadgetText(IdGadget, GetGadgetText(#CaptionString))
                      Gadgets(GadgetsElement)\Caption = "#Text:" + GetGadgetText(#CaptionString)
                    Case "#Date"
                      If GetGadgetText(#CaptionString) <> "" : SetGadgetText(IdGadget, GetGadgetText(#CaptionString)) :EndIf
                      Gadgets(GadgetsElement)\Caption = "#Date:" + GetGadgetText(#CaptionString)
                    Case "#Dir$"
                      SetGadgetText(IdGadget, GetGadgetText(#CaptionString))
                      Gadgets(GadgetsElement)\Caption = "#Dir$:" + GetGadgetText(#CaptionString)
                    Case "#Url$"
                      SetGadgetText(IdGadget, GetGadgetText(#CaptionString))
                      Gadgets(GadgetsElement)\Caption = "#Url$:" + GetGadgetText(#CaptionString)
                  EndSelect
                EndIf
                If IsWindow(IdGadget)
                  Gadgets(0)\Caption = "#Text:" + GetGadgetText(#CaptionString)
                EndIf
              EndIf
              
            Case #ToolTipString
              If EventType() = #PB_EventType_Change
                IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
                If IsGadget(IdGadget)
                  Gadgets(GetGadgetData(IdGadget))\ToolTip = GetGadgetText(#ToolTipString)
                EndIf
              EndIf
              
            Case #MiniString
              If EventType() = #PB_EventType_Change
                IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
                If IsGadget(IdGadget)
                  SetGadgetAttribute(IdGadget, #PB_Spin_Minimum, Val(GetGadgetText(#MiniString)))
                  Gadgets(GetGadgetData(IdGadget))\Option1 = "#Mini:"+GetGadgetText(#MiniString)
                  If Gadgets(GetGadgetData(IdGadget))\IdModel = 22 Or Gadgets(GetGadgetData(IdGadget))\IdModel = 26 Or Gadgets(GetGadgetData(IdGadget))\IdModel = 29
                    SetGadgetState(IdGadget, Val(GetGadgetText(#MiniString))+(Val(GetGadgetText(#MaxiString))-Val(GetGadgetText(#MiniString)))*2/3)
                  EndIf
                EndIf
              EndIf
              ;If EventType() = #PB_EventType_LostFocus   ;No control for easy entry, with Maxi = 0)
              ;If Val(GetGadgetText(#MiniString)) > Val(GetGadgetText(#MaxiString)) : SetGadgetText(#MiniString, GetGadgetText(#MaxiString)) : EndIf
              ;EndIf
              
            Case #MaxiString
              If EventType() = #PB_EventType_Change
                IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
                If IsGadget(IdGadget)
                  SetGadgetAttribute(IdGadget, #PB_Spin_Maximum, Val(GetGadgetText(#MaxiString)))
                  Gadgets(GetGadgetData(IdGadget))\Option2 = "#Maxi:"+GetGadgetText(#MaxiString)
                  If Gadgets(GetGadgetData(IdGadget))\IdModel = 22 Or Gadgets(GetGadgetData(IdGadget))\IdModel = 26 Or Gadgets(GetGadgetData(IdGadget))\IdModel = 29
                    SetGadgetState(IdGadget, Val(GetGadgetText(#MiniString))+(Val(GetGadgetText(#MaxiString))-Val(GetGadgetText(#MiniString)))*2/3)
                  EndIf
                EndIf
              EndIf
              If EventType() = #PB_EventType_LostFocus
                If Val(GetGadgetText(#MaxiString)) < Val(GetGadgetText(#MiniString))
                  SetGadgetText(#MaxiString, GetGadgetText(#MiniString))
                  Gadgets(GetGadgetData(IdGadget))\Option2 = "#Maxi:"+GetGadgetText(#MaxiString)
                EndIf
              EndIf
              
            Case #ImagePick
              IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
              ImagePath = OpenFileRequester("Select image",GetCurrentDirectory(),"Picture (*.bmp; *.jpg; *.png)|*.bmp;*.jpg;*.png", 1)
              DrawSelectedImage(IdGadget, ImagePath)
              
            Case #FrontColorPick
              IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
              SelectedColor = ColorRequester()
              If SelectedColor = -1
                SetGadgetAttribute(#FrontColorPick, #PB_Button_Image, 0)
                If IsGadget(IdGadget) : Gadgets(GetGadgetData(IdGadget))\FrontColor = "" : SetGadgetColor(IdGadget, #PB_Gadget_FrontColor, #PB_Default) : EndIf
              Else
                If StartDrawing(ImageOutput(#FrontColorImg))
                  Box(0, 0, OutputWidth(), OutputHeight(), SelectedColor)
                  StopDrawing()
                  SetGadgetAttribute(#FrontColorPick, #PB_Button_Image, ImageID(#FrontColorImg))
                  If IsGadget(IdGadget) : Gadgets(GetGadgetData(IdGadget))\FrontColor = Str(SelectedColor) : SetGadgetColor(IdGadget, #PB_Gadget_FrontColor, SelectedColor) : EndIf
                EndIf
              EndIf
              
            Case #BackColorPick
              IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
              SelectedColor = ColorRequester()
              If SelectedColor = -1
                SetGadgetAttribute(#BackColorPick, #PB_Button_Image, 0)
                If IsGadget(IdGadget) : Gadgets(GetGadgetData(IdGadget))\BackColor = ""  : SetGadgetColor(IdGadget, #PB_Gadget_BackColor, #PB_Default) : EndIf
                If IsWindow(IdGadget) : Gadgets(0)\BackColor = "" : EndIf   ;For fun SetWindowColor(#MainWindow, #PB_Default)
              Else
                If StartDrawing(ImageOutput(#BackColorImg))
                  Box(0, 0, OutputWidth(), OutputHeight(), SelectedColor)
                  StopDrawing()
                  SetGadgetAttribute(#BackColorPick, #PB_Button_Image, ImageID(#BackColorImg))
                  If IsGadget(IdGadget) : Gadgets(GetGadgetData(IdGadget))\BackColor = Str(SelectedColor) : SetGadgetColor(IdGadget, #PB_Gadget_BackColor, SelectedColor) : EndIf
                  If IsWindow(IdGadget) : Gadgets(0)\BackColor = Str(SelectedColor) : EndIf   ;For fun SetWindowColor(#MainWindow, SelectedColor)
                EndIf
              EndIf
              
            Case #Constants
              If EventType() = #PB_EventType_Change
                IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
                If IsGadget(IdGadget) Or IsWindow(IdGadget)
                  TmpConstants = ""
                  For I=0 To CountGadgetItems(#Constants)-1
                    If TmpConstants <> ""
                      TmpConstants + "|"
                    EndIf
                    TmpConstants + GetGadgetItemText(#Constants, I)
                    If GetGadgetItemState(#Constants, I) =  #PB_ListIcon_Checked Or GetGadgetItemState(#Constants, I) =  #PB_ListIcon_Checked | #PB_ListIcon_Selected
                      TmpConstants + "(x)"
                    EndIf
                  Next
                  If IsGadget(IdGadget) : Gadgets(GetGadgetData(IdGadget))\Constants = TmpConstants : EndIf
                  If IsWindow(IdGadget) : Gadgets(0)\Constants = TmpConstants : EndIf
                EndIf
              EndIf
              
          EndSelect   ;#PB_Event_Gadget #MainWindow
        EndIf
        
        If EventWindow()=#CodeForm   ;Code Generation window
          Select EventGadget()
            Case #AboutButton
              CloseWindow(#CodeForm)
              AboutForm()
            Case #CodeCancel
              CloseWindow(#CodeForm)
            Case #CodePerform
              CodeGenerate()
          EndSelect
        EndIf
        
        If EventWindow()=#AboutForm   ;About Form window
          Select EventGadget()
            Case #AboutBack
              CloseWindow(#AboutForm)
              CodeGenerateForm()
          EndSelect
        EndIf
        
        Select EventType()   ;-> Receives Module Events
          Case  #SVD_Gadget_Focus
            *PosDim = EventData()
            ;Assign the global counter gadget to this new gadget
            For I=0 To CountGadgetItems(#ListGadgets)
              If GetGadgetItemData(#ListGadgets, I) = EventGadget()
                SetGadgetState(#ListGadgets,I)
                Break
              EndIf
            Next
            SetGadgetState(#PosGadgetX, *PosDim\X)
            SetGadgetState(#PosGadgetY, *PosDim\Y)
            SetGadgetState(#PosGadgetWidth, *PosDim\Width)
            SetGadgetState(#PosGadgetHeight, *PosDim\Height)
            LoadGadgetProperties(EventGadget())
            
          Case #SVD_Gadget_LostFocus
            
          Case #SVD_Gadget_Resize
            *PosDim = EventData()
            SetGadgetState(#PosGadgetX, *PosDim\X)
            SetGadgetState(#PosGadgetY, *PosDim\Y)
            SetGadgetState(#PosGadgetWidth, *PosDim\Width)
            SetGadgetState(#PosGadgetHeight, *PosDim\Height)
            If GadgetType(EventGadget()) = 33 And GetGadgetText(#ImageString) <> "0" And GetGadgetText(#ImageString) <> ""
              TmpImage = LoadImage(#PB_Any, GetGadgetText(#ImageString))
              If TmpImage
                ResizeImage(TmpImage, *PosDim\Width, *PosDim\Height)
                SetGadgetAttribute(EventGadget(), #PB_Canvas_Image, ImageID(TmpImage))
                FreeImage(TmpImage)
              EndIf
            EndIf
            
          Case #SVD_WinSize
            *PosDim = EventData()
            SetGadgetState(#SetDrawWidth, *PosDim\Width)
            SetGadgetState(#SetDrawHeight, *PosDim\Height)
            If GetGadgetState(#ListGadgets) = 0
              SetGadgetState(#PosGadgetWidth, *PosDim\Width)
              SetGadgetState(#PosGadgetHeight, *PosDim\Height)
            EndIf
            ResizeDrawArea(GetGadgetState(#SetDrawWidth), GetGadgetState(#SetDrawHeight))
            
        EndSelect   ;EventType()
    EndSelect
  ForEver
  
  Procedure Exit()
    FreeArray(ModelGadget())
    FreeArray(Gadgets())
    End   ;Do I need to free things?
  EndProcedure
  
  DataSection   ;- Data Section (Model)
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
    
    ModelGadgets:   ;31 Gadgets Models +window Model
    ;"CreateGadget","Order","GadgetType","Width","Height","Name","Caption","Option1","Option2","Option3","FrontColor","BackColor","ToolTip","Constants"
    Data.s "OpenWindow","0","","520","480","Window","#Text","","","","#Nooo","","#Nooo","Window_SystemMenu(x)|Window_MinimizeGadget(x)|Window_MaximizeGadget(x)|Window_SizeGadget(x)|Window_Invisible|Window_TitleBar|Window_Tool|Window_BorderLess|Window_ScreenCentered(x)|Window_WindowCentered|Window_Maximize|Window_Minimize|Window_NoGadgets"
    Data.s "ButtonGadget","1","1","100","20","Button","#Text","","","","#Nooo","#Nooo","","Button_Right|Button_Left|Button_Default|Button_MultiLine|Button_Toggle"
    Data.s "ButtonImageGadget","2","19","100","20","ButtonImage","","#Imag:0","","","#Nooo","#Nooo","","Button_Toggle"
    Data.s "CalendarGadget","3","20","220","160","Calendar","","#Date:0","","","#Nooo","#Nooo","","Calendar_Borderless"
    Data.s "CanvasGadget","4","33","140","40","Canvas","","","","","#Nooo","#Nooo","",""
    Data.s "CheckBoxGadget","5","4","100","20","Checkbox","#Text","","","","#Nooo","#Nooo","","CheckBox_Right|CheckBox_Center|CheckBox_ThreeState"
    Data.s "ComboBoxGadget","6","8","100","20","Combo","","","","","#Nooo","#Nooo","","ComboBox_Editable|ComboBox_LowerCase|ComboBox_UpperCase|ComboBox_Image"
    Data.s "ContainerGadget","7","11","200","50","Container","","","","","","","","Container_BorderLess|Container_Flat|Container_Raised|Container_Single|Container_Double"
    Data.s "DateGadget","8","21","120","20","Date","#Date","#Date","","","#Nooo","#Nooo","","Date_UpDown|Date_CheckBox"
    Data.s "EditorGadget","9","22","140","40","Editor","","","","","","","",""
    Data.s "ExplorerComboGadget","10","25","120","20","ExplorerCombo","#Dir$","","","","#Nooo","#Nooo","#Nooo","Explorer_DrivesOnly|Explorer_Editable|Explorer_NoMyDocuments"
    Data.s "ExplorerListGadget","11","23","160","80","ExplorerList","#Dir$","","","","","","","Explorer_NoMyDocuments|Explorer_BorderLess|Explorer_AlwaysShowSelection|Explorer_MultiSelect|Explorer_GridLines|Explorer_HeaderDragDrop|Explorer_FullRowSelect|Explorer_NoFiles|Explorer_NoFolders|Explorer_NoParentFolder|Explorer_NoDirect"
    Data.s "ExplorerTreeGadget","12","24","160","80","ExplorerTree","#Dir$","","","","","","","Explorer_BorderLess|Explorer_AlwaysShowSelection|Explorer_NoLines|Explorer_NoButtons|Explorer_NoFiles|Explorer_NoDriveRequester|Explorer_NoMyDocuments|Explorer_AutoSort"
    Data.s "FrameGadget","13","7","200","50","Frame3D","#Text","","","","#Nooo","#Nooo","#Nooo","Frame_Single|Frame_Double|Frame_Flat"
    Data.s "HyperLinkGadget","14","10","150","20","Hyperlink","#Url$:https://www.purebasic.fr/","#Hard:RGB(0,0,128)","","","","","","HyperLink_Underline"
    Data.s "ImageGadget","15","9","140","40","Image","","#Imag:0","","","#Nooo","#Nooo","","Image_Border"
    Data.s "IPAddressGadget","16","13","100","20","IPAddress","","","","","#Nooo","#Nooo","",""
    Data.s "ListIconGadget","17","12","140","40","ListIcon","","#Titl","#Widh:140","","","","","ListIcon_CheckBoxes|ListIcon_ThreeState|ListIcon_MultiSelect|ListIcon_GridLines|ListIcon_FullRowSelect|ListIcon_HeaderDragDrop|ListIcon_AlwaysShowSelection"
    Data.s "ListViewGadget","18","6","140","40","ListView","","","","","","","","ListView_MultiSelect|ListView_ClickSelect"
    Data.s "OpenGLGadget","19","34","100","20","OpenGL","","","","","#Nooo","#Nooo","","OpenGL_Keyboard"
    Data.s "OptionGadget","20","5","100","20","Option","#Text","","","","#Nooo","#Nooo","",""
    Data.s "PanelGadget","21","28","200","50","Panel","","","","","#Nooo","#Nooo","",""
    Data.s "ProgressBarGadget","22","14","140","12","ProgressBar","","#Mini:0","#Maxi:0","","","","","ProgressBar_Smooth|ProgressBar_Vertical"
    Data.s "ScintillaGadget","23","31","140","40","Scintilla","","#Hard:0","","","#Nooo","#Nooo","#Nooo",""
    Data.s "ScrollAreaGadget","24","16","200","50","ScrollArea","","#InrW:0","#InrH:0","#Step:10","","","#Nooo","ScrollArea_Flat|ScrollArea_Raised|ScrollArea_Single|ScrollArea_BorderLess|ScrollArea_Center"
    Data.s "ScrollBarGadget","25","15","140","16","Scrollbar","","#Mini:0","#Maxi:0","#Long:0","#Nooo","#Nooo","","ScrollBar_Vertical"
    Data.s "SpinGadget","26","26","100","20","Spin","","#Mini:0","#Maxi:0","","","","","Spin_ReadOnly|Spin_Numeric(x)"
    Data.s "StringGadget","27","2","100","20","String","#Text","","","","","","","String_Numeric|String_Password|String_ReadOnly|String_LowerCase|String_UpperCase|String_BorderLess"
    Data.s "TextGadget","28","3","100","20","Text","#Text","","","","","","#Nooo","Text_Center|Text_Right|Text_Border"
    Data.s "TrackBarGadget","29","17","100","20","TrackBar","","#Mini:0","#Maxi:0","","","#Nooo","#Nooo","TrackBar_Ticks|TrackBar_Vertical"
    Data.s "TreeGadget","30","27","100","20","Tree","","","","","","","","Tree_AlwaysShowSelection|Tree_NoLines|Tree_NoButtons|Tree_CheckBoxes|Tree_ThreeState"
    Data.s "WebGadget","31","18","260","125","WebView","#Url$:https://www.purebasic.fr/","","","","#Nooo","#Nooo","#Nooo",""
  EndDataSection
CompilerEndIf

; IDE Options = PureBasic 5.60 (Windows - x64)
; CursorPosition = 582
; FirstLine = 577
; Folding = -----
; EnableXP
; UseIcon = Include\SweetyVD.ico
; Executable = SweetyVD.exe
; Compiler = PureBasic 5.60 (Windows - x86)
; EnablePurifier
; IncludeVersionInfo
; VersionField0 = 1.8.2
; VersionField1 = 1.8.2
; VersionField3 = SweetyVD.exe
; VersionField4 = 1.8.2
; VersionField5 = 1.8.2
; VersionField6 = Sweety Visual Designer
; VersionField7 = SweetyVD.exe
; VersionField8 = SweetyVD.exe
; VersionField9 = @ChrisR
; Watchlist = CodeGenerate()>Code