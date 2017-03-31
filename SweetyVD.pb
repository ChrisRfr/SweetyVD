; ---------------------------------------------------------------------------------------
;           Name: SweetyVD
;    Description: Sweety Visual Designer
;     dependency: SweetyVDmodule.pbi (Sweety Visual Designer Module)
;         Author: ChrisR
;           Date: 2017-03-14
;        Version: 1.6.1
;     PB-Version: 5.4* LTS, 5.5*, 5.60 (x86/x64)
;             OS: Windows, Linux, Mac
;         Credit: STARGÅTE: Transformation of gadgets at runtime
;         Credit: Falsam: Tiny Visual Designer (TVD)
;  English-Forum:
;   French-Forum: http://www.purebasic.fr/french/viewtopic.php?f=3&t=16527
;   German-Forum:
; ---------------------------------------------------------------------------------------
; v1.6.1: Disable Tootip for TextGadget
; ---------------------------------------------------------------------------------------

CompilerIf #PB_Compiler_IsMainFile
  EnableExplicit

  ;Import internal function
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    Import ""
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

    #INDENT = "  "

    Enumeration
      #MainWindow
      #DrawArea
      #PopUpMenu
      #EnableSVD
      #CodeCreate
      #SettingContainer
      #DrawSizeText
      #DrawWidth
      #DrawSizeTextX
      #DrawHeight
      #DragText
      #DragSVD
      #ShowGrid
      #GridSpacing
      #GadgetList
      #ListGadgets
      #AddGadgetButton
      #DeleteGadgetButton
      #PosGadgetX
      #PosGadgetY
      #PosGadgetWidth
      #PosGadgetHeight
      ;Properties
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
      #Img_Add
      #Img_Delete
      #Img_About
    EndEnumeration

    Enumeration Font
      #FontWML
    EndEnumeration

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
      Constants.s                   ;Available Constants (Ex: "#PB_Text_Center,#PB_Text_Right,#PB_Text_Border")
      CountGadget.i                 ;Gadget Counter by Model
    EndStructure
    Global Dim ModelGadget.ModelGadgetProperty(27)

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
    Global Dim Gadgets.StructureGadget(1), CountGadgets.i, CountImageBtn.i

    Global X.i, Y.i

    Declare.f AjustFontSize(Size.l)
    Declare LoadFontWML()
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
    Declare OpenMainWindow(SelectDrawArea.l = 0, X = 0, Y = 0, Width = 800, Height = 530)
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
        SetGadgetFont(#PB_Default, FontID(#FontWML))   ; Set the loaded Arial 8 font as new default font for all Gadgets
      ElseIf LoadFont(#FontWML, "Arial", AjustFontSize(8))
        SetGadgetFont(#PB_Default, FontID(#FontWML))   ; Set the loaded Arial 8 font as new default font for all Gadgets
      EndIf                                            ;If not loaded: SetGadgetFont(#PB_Default, #PB_Default): set the font settings back to original standard font
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
      Protected Buffer.s, ScrollMargin = 20, I.i
      With ModelGadget(0)
        ;Draw Area Width and Height with associated Spin Gadgets
        SetGadgetState(#PosGadgetWidth, \DftWidth)
        SetGadgetState(#PosGadgetHeight, \DftHeight)
        SetGadgetState(#DrawWidth, \DftWidth)
        SetGadgetState(#DrawHeight,  \DftHeight)
        If GadgetX(#DrawArea) + \DftWidth + ScrollMargin + 10 > WindowWidth(#MainWindow)
          ResizeGadget(#DrawArea, #PB_Ignore, #PB_Ignore, WindowWidth(#MainWindow) - GadgetX(#DrawArea) - 10, #PB_Ignore)
        Else
          ResizeGadget(#DrawArea, #PB_Ignore, #PB_Ignore, \DftWidth + ScrollMargin, #PB_Ignore)
        EndIf
        SetGadgetAttribute(#DrawArea, #PB_ScrollArea_InnerWidth, \DftWidth)
        If GadgetY(#DrawArea) + \DftHeight + ScrollMargin + 10 > WindowHeight(#MainWindow)   ;To display the scrollbar
          ResizeGadget(#DrawArea, #PB_Ignore, #PB_Ignore, #PB_Ignore, WindowHeight(#MainWindow) - GadgetY(#DrawArea) - 10)
        Else
          ResizeGadget(#DrawArea, #PB_Ignore, #PB_Ignore, #PB_Ignore, \DftHeight + ScrollMargin)
        EndIf
        SetGadgetAttribute(#DrawArea, #PB_ScrollArea_InnerHeight, \DftHeight)
        DrawAreaSize(#DrawArea)
        ;Save window information in the gadget List. Element 0
        Gadgets(0)\IdGadget=#MainWindow
        Gadgets(0)\IdModel=0
        Gadgets(0)\Name="#"+\Name+"_0"
        Gadgets(0)\Caption=\Name+"_0"
        Gadgets(0)\Option1=\Option1
        Gadgets(0)\Option2=\Option2
        Gadgets(0)\Option3=\Option3
        Gadgets(0)\FrontColor=\FrontColor
        Gadgets(0)\BackColor=\BackColor
        Gadgets(0)\Constants=\Constants
        Gadgets(0)\ModelType=0   ;0=Window
                                 ;Add Window to List Gadgets ComboBox. Element 0 for the Window Draw Area
        AddGadgetItem(#ListGadgets, -1, Gadgets(0)\Name)
        SetGadgetState(#ListGadgets, 0)
        SetGadgetItemData(#ListGadgets, 0, 0)
      EndWith
    EndProcedure

    Procedure InitModelgadget()   ;Initializing Gadget Templates
      Protected Buffer.s, I.i, J.i
      Restore ModelGadgets
      For I=0 To 27
        With ModelGadget(I)
          For J=1 To 13
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
              Case 13 : \Constants=Buffer
            EndSelect
          Next
          If I = 0
            InitModelWindow()   ;Draw Area Width and Height and Save Window information
          Else
            MenuItem((I), \Model)   ;Add to popup menu
          EndIf
        Next
      EndWith
    EndProcedure

    Procedure CreateGadgets(IdModel.i)
      Protected IdGadget.i, TmpCaption.s, Mini.i, Maxi.i, TmpConst.s, TmpConstants.s, I.i
      InitProperties()
      OpenGadgetList(#DrawArea)   ;Required when changing apps(ex: test generate code) to reopen the GadgetList
      With ModelGadget(IdModel)
        \CountGadget=\CountGadget+1   ;Updating the gadget counter by model
        CountGadgets=CountGadgets+1
        ReDim Gadgets(CountGadgets)

        X = Round(X/MyGrid, #PB_Round_Down)*MyGrid   ;Align on Grid
        Y = Round(Y/MyGrid, #PB_Round_Down)*MyGrid
        ;Default values from the gadget models table
        If \Caption = "#Nooo"
          TmpCaption=""
        Else
		  If IdModel = 12 Or IdModel = 27  ;Specific HyperLinkGadget, WebGadget
		    TmpCaption="https://www.purebasic.fr/"
		  Else
            TmpCaption=\Name+"_"+Str(\CountGadget)
		  EndIf
        EndIf
        ;         ;Constants! how to get constant value from text
        ;         For I=1 To CountString(\Constants, "|") + 1
        ;           TmpConst = Trim(StringField(\Constants, I, "|"))
        ;           If Right(TmpConst, 3) = "(x)"
        ;             If TmpConstants <> ""
        ;               TmpConstants + " | "
        ;             EndIf
        ;             TmpConstants + "#PB_" + Left(TmpConst, Len(TmpConst)-3)
        ;           EndIf
        ;         Next

        Select IdModel   ;Create Gadget depending on model
          Case 1  : IdGadget=ButtonGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, TmpCaption)
          Case 2  : IdGadget=ButtonImageGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, 0)
          Case 3  : IdGadget=  CalendarGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, 0)
          Case 4
            IdGadget=CanvasGadget(#PB_Any, X, Y, \DftWidth, \DftHeight)
            If StartDrawing(CanvasOutput(IdGadget))
              DrawText(5, 5, \Name+Str(\CountGadget), #Blue, #White)
              StopDrawing()
            EndIf
          Case 5  : IdGadget=CheckBoxGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, TmpCaption)
          Case 6
            IdGadget=ComboBoxGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, #PB_ComboBox_Editable)
            AddGadgetItem(Idgadget,-1,TmpCaption)
          Case 7  : IdGadget=DateGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, TmpCaption)
          Case 8
            IdGadget=EditorGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, #PB_Editor_ReadOnly)
            AddGadgetItem(IdGadget, 0, \Name+"_"+Str(\CountGadget))
          Case 9
            IdGadget=ExplorerComboGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, "")
          Case 10
            IdGadget=ExplorerListGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, "")
          Case 11
            IdGadget=ExplorerTreeGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, "")
          Case 12
            IdGadget=HyperLinkGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, TmpCaption, RGB(0,0,128))
          Case 13   ;We cheat with a Canvas instead of an ImageGadget
            IdGadget=CanvasGadget(#PB_Any, X, Y, \DftWidth, \DftHeight)
            If StartDrawing(CanvasOutput(IdGadget))
              DrawText(5, 5, \Name+Str(\CountGadget), #Blue, #White)
              StopDrawing()
            EndIf
          Case 14
            IdGadget=  IPAddressGadget(#PB_Any, X, Y, \DftWidth, \DftHeight)
            SetGadgetState(IdGadget, MakeIPAddress(127, 0, 0, 1))
          Case 15  : IdGadget=ListIconGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, TmpCaption, 100)
          Case 16  : IdGadget=ListViewGadget(#PB_Any, X, Y, \DftWidth, \DftHeight)
          Case 17  : IdGadget=OpenGLGadget(#PB_Any, X, Y, \DftWidth, \DftHeight)
          Case 18  : IdGadget=OptionGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, TmpCaption)
          Case 19
            Mini = Val(Mid(\Option1, 7)) : Maxi = Val(Mid(\Option2, 7))
            IdGadget=ProgressBarGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, Mini, Maxi)
            SetGadgetState(IdGadget, Mini+(Maxi-Mini)*2/3)
          Case 20
            If InitScintilla()
              IdGadget=ScintillaGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, 0)
            EndIf
          Case 21
            Mini = Val(Mid(\Option1, 7)) : Maxi = Val(Mid(\Option2, 7))
            IdGadget=ScrollBarGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, Mini, Maxi, 0)
          Case 22
            Mini = Val(Mid(\Option1, 7)) : Maxi = Val(Mid(\Option2, 7))
            IdGadget=SpinGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, Mini, Maxi, #PB_Spin_Numeric)
            SetGadgetState(IdGadget, Mini+(Maxi-Mini)*2/3)
          Case 23
            IdGadget=StringGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, TmpCaption, #PB_String_ReadOnly)
          Case 24 : IdGadget=TextGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, TmpCaption)
          Case 25
            Mini = Val(Mid(\Option1, 7)) : Maxi = Val(Mid(\Option2, 7))
            IdGadget=TrackBarGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, Mini, Maxi)
            SetGadgetState(IdGadget, Mini+(Maxi-Mini)*2/3)
          Case 26 : IdGadget=TreeGadget(#PB_Any, X, Y, \DftWidth, \DftHeight)
          Case 27 : IdGadget=WebGadget(#PB_Any, X, Y, \DftWidth, \DftHeight, TmpCaption)
        EndSelect

        SetGadgetData(IdGadget, CountGadgets)   ;Add Gadget Counter to Gadget Data
                                                ;Save gadget information in the gadget List
        Gadgets(CountGadgets)\IdGadget=Idgadget
        Gadgets(CountGadgets)\IdModel=IdModel
        Gadgets(CountGadgets)\Name="#"+\Name+"_"+Str(\CountGadget)
        ;Default values from the gadget models table
        If \Caption = "#Nooo"
          Gadgets(CountGadgets)\Caption=\Caption
        Else
          Gadgets(CountGadgets)\Caption=TmpCaption
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
        SetGadgetItemData(#ListGadgets, CountGadgetItems(#ListGadgets)-1, IdGadget)
        ;Add Drag Handle Gadget in module
        AddSVDGadget(#DrawArea, IdGadget)
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
        AddGadgetItem(#Licence,-1,"SweetyVD is a Freeware tool and is Free")
        AddGadgetItem(#Licence,-1,"of all Cost.")
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
      Protected AnyGadgets.b = #False, I.i, J.i
      For I = 1 To ArraySize(Gadgets())   ;At least one Gadget is required
        If Gadgets(I)\Idgadget > 0 And Gadgets(I)\ModelType=2
          AnyGadgets = #True
          Break
        EndIf
      Next

      If AnyGadgets   ;If at least one Gadget
        If OpenWindow(#CodeForm, WindowX(#MainWindow)+GadgetX(#CodeCreate), WindowY(#MainWindow)+70 , 220 , 145, "SweetyVD: PureBasic code Generation",#PB_Window_TitleBar)
          CheckBoxGadget(#CodeIncTitle, 30, 5, 160, 25, "IncludeTitle block") : SetGadgetState(#CodeIncTitle, #PB_Checkbox_Checked)
          CheckBoxGadget(#CodeIncEnum, 30, 30, 160, 25, "Include enumeration") : SetGadgetState(#CodeIncEnum, #PB_Checkbox_Checked)
          CheckBoxGadget(#CodeAddStatusBar, 30, 55, 160, 25, "Add a Status Bar")
          CheckBoxGadget(#CodeIncEvent, 30, 80, 160, 25, "Include the event loop") : SetGadgetState(#CodeIncEvent, #PB_Checkbox_Checked)
          CatchImage(#Img_About,?Img_About)
          ButtonImageGadget(#AboutButton, 190, 5, 25, 25, ImageID(#Img_About))
          ButtonGadget(#CodePerform, 20, 110, 80, 25, "Generate", #PB_Button_Toggle) : SetGadgetState(#CodePerform, #True)
          ButtonGadget(#CodeCancel, 120, 110, 80, 25, "Cancel")
        EndIf
      Else
        MessageRequester("SweetyVD Information", "Let me play with at least one Gadget. Please  ;)", #PB_MessageRequester_Warning|#PB_MessageRequester_Ok)
      EndIf
    EndProcedure

    Procedure CodeGenerate()
      Protected Dim Buffer.StructureGadget(0)
      Protected IdGadget.i, SavModelType = -1
      Protected ImageExtPath.s, ImageExtFullPath.s, TmpImagePath.s
      Protected Code.s, Model.s, Name.s, X.s, Y.s, Width.s, Height.s, Caption.s
      Protected Mini.i, Maxi.i, TmpConstants.s, FirstPass.b, I.i, J.i

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

      If GetGadgetState(#CodeIncTitle) = #True   ;Générate Title block code
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

      If GetGadgetState(#CodeIncEnum) = #True   ;Include Enumeration
        For I=0 To ArraySize(Buffer())
          With Buffer(I)
            If \ModelType = 9 : Break : EndIf   ;Gadget Deleted
            Select \ModelType
              Case 0
                If \ModelType <> SavModelType
                  SavModelType = \ModelType
                  Code + "Enumeration Window" +#CRLF$
                EndIf

              Case 1
                If \ModelType <> SavModelType
                  SavModelType = \ModelType
                  Code + "EndEnumeration" +#CRLF$+#CRLF$
                  Code + "Enumeration StatusBar" +#CRLF$
                EndIf

              Case 2
                If \ModelType <> SavModelType
                  SavModelType = \ModelType
                  Code + "EndEnumeration" +#CRLF$+#CRLF$
                  Code + "Enumeration Gadgets" +#CRLF$
                EndIf
            EndSelect

            If \Name <> "#Pb_Any"
              Code +#INDENT+ \Name +#CRLF$
            EndIf
          EndWith
        Next
        Code + "EndEnumeration" +#CRLF$+#CRLF$

        If ArraySize(ImageBtnPathArray()) > 0   ;Enumeration Image
          Code + "Enumeration FormImage"+#CRLF$
          For I = 1 To ArraySize(ImageBtnPathArray())
            If FileSize(ImageBtnPathArray(I)\ImagePath)
              Code +#INDENT+ "#Img_Window_" + Str(I) +#CRLF$
            EndIf
          Next
          Code + "EndEnumeration" +#CRLF$+#CRLF$

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
              Code + "LoadImage(#Img_Window_" + Str(I) + ", " + #DQUOTE$ + ImageBtnPathArray(I)\ImagePath + #DQUOTE$ + ")" +#CRLF$
            EndIf
          Next
          Code +#CRLF$
        EndIf

        Code + "Define.l Event" +#CRLF$+#CRLF$
      EndIf

      ;-Create Window
      With Buffer(0)
        Name = \Name
        Width = GetGadgetText(#DrawWidth)
        Height = GetGadgetText(#DrawHeight)
        Caption = \Caption

        Code + "Declare Open_"+Mid(Name,2,Len(Name)-1)+"(X = 0, Y = 0, Width = "+Width+", Height = "+Height+")" +#CRLF$+#CRLF$
        Code + "Procedure Open_"+Mid(Name,2,Len(Name)-1)+"(X = 0, Y = 0, Width = "+Width+", Height = "+Height+")" +#CRLF$
        Code +#INDENT+ "If OpenWindow("+Name+", X, Y, Width, Height, " + #DQUOTE$ + Caption + #DQUOTE$

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

        If Left(\BackColor, 5) <> "#Nooo" And \BackColor <> ""   ;Background window color
          Code +#INDENT+#INDENT+ "SetWindowColor(" + Name + ", " + \BackColor + ")" +#CRLF$
        EndIf
      EndWith

      If GetGadgetState(#CodeAddStatusBar) = #True   ;Add a Status Bar Enumeration
        Code +#INDENT+#INDENT+ "CreateStatusBar(" + Name +", WindowID(" + Name + "))" +#CRLF$
      EndIf

      ;-Create Gadgets
      For I=1 To ArraySize(Buffer())
        With Buffer(I)
          If \ModelType = 9 : Break : EndIf   ;Gadget Deleted
          If \ModelType <> 1
            IdGadget = \IdGadget
            Model = ModelGadget(\IdModel)\Model
            Name = \Name
            X = Str(GadgetX(IdGadget))
            Y = Str(GadgetY(IdGadget))
            Width = Str(GadgetWidth(IdGadget))
            Height = Str(GadgetHeight(IdGadget))
            Caption = \Caption

            If \IdModel = 20 : Code +#INDENT+#INDENT+ "If InitScintilla()" +#CRLF$+#INDENT : EndIf   ;Specific ScintillaGadget

            Code +#INDENT+#INDENT+ Model + "(" + Name + ", " + X + ", " + Y + ", " + Width + ", " + Height   ;Common part

            If Caption <> "" And Caption <> "#Nooo"   ;Is there a Caption?
              Code + ", " +#DQUOTE$+ Caption +#DQUOTE$
            EndIf

            Select Left(\Option1, 5)
              Case "#Mini" : Code + ", " + Mid(\Option1, 7)
              Case "#Hard" : Code + ", " + Mid(\Option1, 7)
              Case "#Titl" : Code + ", " +#DQUOTE$+ Mid(Name, 2) +#DQUOTE$
              Case "#Imag"
                TmpImagePath = Mid(\Option1, 7)
                If TmpImagePath = "0"
                  Code + ", 0"
                Else
                  For J=1 To ArraySize(ImageBtnPathArray())   ;LoadImage
                    If ImageBtnPathArray(J)\ImagePath =TmpImagePath
                      Code + ", ImageID(#Img_Window_" + Str(J) + ")"
                      Break
                    EndIf
                  Next
                EndIf
            EndSelect

            Select Left(\Option2, 5)
              Case "#Maxi" : Code + ", " + Mid(\Option2, 7)
              Case "#Widh" : Code + ", " + Mid(\Option2, 7)
            EndSelect

            ;Specific addition
            Select \IdModel
              Case 21 : Code + ", 0"   ;Specific ScrollBarGadget: Page length

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
              Case 6
                Code +#INDENT+#INDENT+ "AddGadgetItem("+ Name + ", -1, " + #DQUOTE$ + Mid(Name,2) + #DQUOTE$ + ")" +#CRLF$
                Code +#INDENT+#INDENT+ "SetGadgetState("+ Name + ", 0)" +#CRLF$
              Case 8  : Code +#INDENT+#INDENT+ "AddGadgetItem("+ Name + ", -1, " + #DQUOTE$ + Mid(Name,2) + #DQUOTE$ + ")" +#CRLF$
              Case 14 : Code +#INDENT+#INDENT+ "SetGadgetState("+ Name + ", MakeIPAddress(127, 0, 0, 1))" +#CRLF$
              ;Case 19
                ;Mini = Val(Mid(\Option1, 7)) : Maxi = Val(Mid(\Option2, 7))
                ;Code +#INDENT+#INDENT+ "SetGadgetState("+ Name + ", " + Str(Mini+(Maxi-Mini)*2/3) + ")" +#CRLF$
              Case 20 : Code +#INDENT+#INDENT+ "EndIf" +#CRLF$
              Case 19, 22, 25   ;ProgressBarGadget, Spin, TackBar: Cosmetic, progression 2/3
                Mini = Val(Mid(\Option1, 7)) : Maxi = Val(Mid(\Option2, 7))
                Code +#INDENT+#INDENT+ "SetGadgetState("+ Name + ", " + Str(Mini+(Maxi-Mini)*2/3) + ")" +#CRLF$
            EndSelect

            If Left(\FrontColor, 5) <> "#Nooo" And \FrontColor <> ""
              Code +#INDENT+#INDENT+ "SetGadgetColor(" + Name + ", #PB_Gadget_FrontColor, " + \FrontColor + ")" +#CRLF$
            EndIf
            If Left(\BackColor, 5) <> "#Nooo" And \BackColor <> ""
              Code +#INDENT+#INDENT+ "SetGadgetColor(" + Name + ", #PB_Gadget_BackColor, " + \BackColor + ")" +#CRLF$
            EndIf

            If \ToolTip <> ""
              Code +#INDENT+#INDENT+ "GadgetToolTip(" + Name + ", " + #DQUOTE$ + \ToolTip + #DQUOTE$ + ")" +#CRLF$
            EndIf

          EndIf
        EndWith
      Next

      Code +#INDENT+ "EndIf" +#CRLF$
      Code + "EndProcedure" +#CRLF$+#CRLF$

      Name = Buffer(0)\Name   ;Window Name
      Code + "Open_" + Mid(Name,2,Len(Name)-1) + "()" +#CRLF$+#CRLF$

      If GetGadgetState(#CodeIncEvent) = #True   ;Event Loop
        Code + "Repeat" +#CRLF$
        Code +#INDENT+ "Event = WaitWindowEvent()" +#CRLF$
        Code +#INDENT+ "Select Event" +#CRLF$
        Code +#INDENT+#INDENT+ "Case #PB_Event_Menu" +#CRLF$
        Code +#INDENT+#INDENT+#INDENT+ "Select EventMenu()" +#CRLF$
        Code +#INDENT+#INDENT+#INDENT+ "EndSelect" +#CRLF$+#CRLF$
        Code +#INDENT+#INDENT+ "Case #PB_Event_Gadget" +#CRLF$
        Code +#INDENT+#INDENT+#INDENT+ "Select EventGadget()" +#CRLF$
        For I=1 To ArraySize(Buffer())
          If Buffer(I)\ModelType = 9 : Break : EndIf   ;Gadget Deleted
          If Buffer(I)\IdModel = 1                     ;Button
            Code +#INDENT+#INDENT+#INDENT+#INDENT+ "Case " + Buffer(I)\Name +#CRLF$
          EndIf
        Next
        Code +#INDENT+#INDENT+#INDENT+ "EndSelect" +#CRLF$+#CRLF$
        Code +#INDENT+#INDENT+ "Case #PB_Event_CloseWindow" +#CRLF$
        Code +#INDENT+#INDENT+#INDENT+ "End" +#CRLF$
        Code +#INDENT+ "EndSelect" +#CRLF$
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
      SetGadgetState(#PosGadgetWidth, GetGadgetState(#DrawWidth)) : SetGadgetState(#PosGadgetHeight, GetGadgetState(#DrawHeight))
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

      SetGadgetText(#CaptionString, "") : SetGadgetText(#ToolTipString, "")
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
        If \Caption <> "#Nooo"
          SetGadgetText(#CaptionString, \Caption)
          DisableGadget(#CaptionString,#False)
        EndIf
        If \IdModel = 24
          DisableGadget(#ToolTipString,#True)
        EndIf
        SetGadgetText(#ToolTipString, \ToolTip)
        Select Left(\Option1, 5)
          Case "#Mini"
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
          Case "#Maxi"
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
            ResizeSVDGadget(IdGadget, -1, -1, ImageWidth(TmpImage), -1)
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
      Protected ScrollMargin = 20
      If Width > 0
        If GadgetX(#DrawArea) + Width + ScrollMargin + 10 > WindowWidth(#MainWindow)
          ResizeGadget(#DrawArea, #PB_Ignore, #PB_Ignore, WindowWidth(#MainWindow) - GadgetX(#DrawArea) - 10, #PB_Ignore)
        Else
          ResizeGadget(#DrawArea, #PB_Ignore, #PB_Ignore, Width + ScrollMargin, #PB_Ignore)
        EndIf
        ResizeGadget(#GridArea, #PB_Ignore, #PB_Ignore, Width, #PB_Ignore)   ;Require for Linux and GetGadgetAttribute #PB_ScrollArea_. The canvas must be smaller
        SetGadgetAttribute(#DrawArea, #PB_ScrollArea_InnerWidth, Width)
      EndIf
      If Height > 0
        If GadgetY(#DrawArea) + Height + ScrollMargin + 10 > WindowHeight(#MainWindow)   ;To display the scrollbar
          ResizeGadget(#DrawArea, #PB_Ignore, #PB_Ignore, #PB_Ignore, WindowHeight(#MainWindow) - GadgetY(#DrawArea) - 10)
        Else
          ResizeGadget(#DrawArea, #PB_Ignore, #PB_Ignore, #PB_Ignore, Height + ScrollMargin)
        EndIf
        ResizeGadget(#GridArea, #PB_Ignore, #PB_Ignore, #PB_Ignore, Height)   ;Require for Linux and GetGadgetAttribute #PB_ScrollArea_. The canvas must be smaller
        SetGadgetAttribute(#DrawArea, #PB_ScrollArea_InnerHeight, Height)
      EndIf
      DrawAreaSize(#DrawArea)   ;For ParentWidth(Height) with max displacement value
      If GetGadgetState(#ShowGrid) = #PB_Checkbox_Checked   ;and redraw the grid
        DrawGrid(#True, GetGadgetState(#GridSpacing))
      EndIf
    EndProcedure

    Procedure WindowSize()
      Protected DrawMaxWidth.i, DrawMaxHeight.i, ScrollMargin = 20
      ;Adjust width and height of the scroll drawing area according to window size
      If IsGadget(#DrawArea) And GadgetType(#DrawArea) = #PB_GadgetType_ScrollArea
        DrawMaxWidth = WindowWidth(#MainWindow) - GadgetX(#DrawArea) - 10   ;10 from the right border
        If DrawMaxWidth > GetGadgetAttribute(#DrawArea,#PB_ScrollArea_InnerWidth) + ScrollMargin
          DrawMaxWidth = GetGadgetAttribute(#DrawArea,#PB_ScrollArea_InnerWidth) + ScrollMargin
        EndIf
        DrawMaxHeight = WindowHeight(#MainWindow) - GadgetY(#DrawArea) - 10   ;10 from the bottom border
        If DrawMaxHeight > GetGadgetAttribute(#DrawArea,#PB_ScrollArea_InnerHeight) + ScrollMargin
          DrawMaxHeight = GetGadgetAttribute(#DrawArea,#PB_ScrollArea_InnerHeight) + ScrollMargin
        EndIf
        ResizeGadget(#DrawArea, #PB_Ignore, #PB_Ignore, DrawMaxWidth, DrawMaxHeight)
        ;Do not resize #SettingContainer or others Main window Gadget. Gadgets become inaccessible
      EndIf
    EndProcedure

    Procedure OpenMainWindow(SelectDrawArea.l = 0, X = 0, Y = 0, Width = 800, Height = 530)
      Protected GadgetObj.i
      OpenWindow(#MainWindow, x, y, width, height, "SweetyVD (Visual Designer)", #PB_Window_SizeGadget | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_ScreenCentered | #PB_Window_SystemMenu)
      CreatePopupMenu(#PopUpMenu)
      ButtonGadget(#EnableSVD, 5, 5, 100, 25, "Enable SVD", #PB_Button_Toggle) : SetGadgetState(#EnableSVD, #True)
      ButtonGadget(#CodeCreate, 115, 5, 100, 25, "Create Code")

      ContainerGadget(#SettingContainer, 220, 5, 520, 30, #PB_Container_Raised) : HideGadget(#SettingContainer,#True)
      TextGadget(#DrawSizeText, 10, 4, 30, 20, "Size")
      SpinGadget(#DrawWidth, 40, 1, 70, 20, 1, 1920, #PB_Spin_Numeric)
      TextGadget(#DrawSizeTextX, 110, 4, 10, 20, "x", #PB_Text_Center)
      SpinGadget(#DrawHeight, 120, 1, 70, 20, 1, 1020, #PB_Spin_Numeric)
      TextGadget(#DragText, 215, 4, 75, 20, "Drag space")
      SpinGadget(#DragSVD, 290, 1, 50, 20, 1, 20, #PB_Spin_Numeric)  : SetGadgetState(#DragSVD, 10)
      CheckBoxGadget(#ShowGrid, 375, 2, 85, 20, "Show grid") : SetGadgetState(#ShowGrid, #PB_Checkbox_Checked)
      SpinGadget(#GridSpacing, 460, 1, 50, 20, 1, 50, #PB_Spin_Numeric) : SetGadgetState(#GridSpacing, 20)
      CloseGadgetList()

      ContainerGadget(#GadgetList, 5, 35, 210, 115, #PB_Container_Raised) : HideGadget(#GadgetList,#True)
      ComboBoxGadget(#ListGadgets, 2 ,5, 158, 22) ;Liste des gadgets
      CatchImage(#Img_Add,?Img_Add)
      ButtonImageGadget(#AddGadgetButton, 162, 6, 20, 20, ImageID(#Img_Add))
      CatchImage(#Img_Delete,?Img_Delete)
      ButtonImageGadget(#DeleteGadgetButton, 184, 6, 20, 20, ImageID(#Img_Delete))
      ;ComboBoxGadget(#ListGadgets, 2 ,5, 166, 22) ;Liste des gadgets
      ;ImageGadget(#AddGadgetButton, 171, 10, 0, 0, ImageID(#Img_Add))
      ;ImageGadget(#DeleteGadgetButton, 188, 10, 0, 0, ImageID(#Img_Delete))
      SpinGadget(#PosGadgetX, 2, 60, 70, 20, 0, 1920, #PB_Spin_Numeric) : SetGadgetState(#PosGadgetX, 0)
      SpinGadget(#PosGadgetY, 68, 35, 70, 20, 0, 1020, #PB_Spin_Numeric) : SetGadgetState(#PosGadgetY, 0)
      SpinGadget(#PosGadgetWidth, 133, 60, 70, 20, 1, 1920, #PB_Spin_Numeric)
      SpinGadget(#PosGadgetHeight, 68, 85, 70, 20, 1, 1020, #PB_Spin_Numeric)
      CloseGadgetList()

      ContainerGadget(#PropertiesContainer, 5, 155, 210, 345, #PB_Container_Single) : HideGadget(#PropertiesContainer,#True)
      StringGadget(#CaptionText, 0, 0, 60, 22, "Caption", #PB_String_ReadOnly)
      StringGadget(#CaptionString, 60, 0, 148, 22, "")
      StringGadget(#ToolTipText, 0, 22, 60, 22, "ToolTip", #PB_String_ReadOnly)
      StringGadget(#ToolTipString, 60, 22, 148, 22, "")
      StringGadget(#MiniText, 0, 44, 35, 22, "Mini", #PB_String_ReadOnly)
      StringGadget(#MiniString, 35, 44, 68, 22, "0", #PB_String_Numeric)
      StringGadget(#MaxiText, 105, 44, 35, 22, "Maxi", #PB_String_ReadOnly)
      StringGadget(#MaxiString, 140, 44, 68, 22, "100", #PB_String_Numeric)
      StringGadget(#ImageText, 0, 44, 60, 22, "Image", #PB_String_ReadOnly)
      StringGadget(#ImageString, 60, 44, 124, 22, "C:\xxxx\PB.jpg", #PB_String_ReadOnly)
      ButtonGadget(#ImagePick, 184, 44, 22, 22, "...") : HideGadget(#ImagePick, #True)
      TextGadget(#FrontColorText, 5, 70, 66, 22, "FrontColor")
      ButtonImageGadget(#FrontColorPick, 71, 68, 18, 18, 0)
      CreateImage(#FrontColorImg, 22, 22)
      TextGadget(#BackColorText, 120, 70, 66, 22, "BackColor")
      ButtonImageGadget(#BackColorPick, 186, 68, 18, 18, 0)
      CreateImage(#BackColorImg, 22, 22)
      ListIconGadget(#Constants, 0, 90, 210, 255, "Options (#PB_)", 206, #PB_ListIcon_CheckBoxes)
      CloseGadgetList()

      Select SelectDrawArea   ;0=ScrollArea, 1=Container. Possible todo, to see for 2=Canvas ScrollArea
        Case 0
          ScrollAreaGadget(#DrawArea, 220, 35, 580, 480, 1920, 1020, 20, #PB_ScrollArea_Single)
        Case 1
          ContainerGadget(#DrawArea, 220, 35, 580, 480, #PB_Container_Single)
        Default
          ScrollAreaGadget(#DrawArea, 220, 35, 580, 480, 1920, 1020, 20, #PB_ScrollArea_Single)
      EndSelect

      ;All interface Objects must have #PB_Ignore as data. To not load them later when loading Designer
      PB_Object_EnumerateStart(PB_Gadget_Objects)
      While PB_Object_EnumerateNext(PB_Gadget_Objects, @GadgetObj)
        SetGadgetData(GadgetObj, #PB_Ignore)
      Wend
      ;*** Important *** Call InitSVD just after the drawing area: ScrollArea or Container. And before creating Gadets on it
      InitSVD(#DrawArea)
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
    Define SelectDrawArea.l = 0   ;0=ScrollArea, 1=Container. Possible todo 2=Canvas
    Define *PosDim.PosDim
    Define IdGadget.i, DrawMaxWidth.i, DrawMaxHeight.i, ScrollMargin = 20
    Define ImagePath.s, TmpImage.i, SelectedColor.i, TmpConstants.s, Rtn.i, I.i

    LoadFontWML()
    OpenMainWindow(SelectDrawArea)
    InitModelgadget()   ;Initializing Gadget Templates
    BindEvent(#PB_Event_SizeWindow, @WindowSize())
    ;SVDGadgetTest()

    Repeat   ;- Event Loop
      Select WaitWindowEvent()

        Case #PB_Event_CloseWindow
          Exit()

        Case #PB_Event_LeftClick   ;does not work on Linux
          If GetGadgetState(#EnableSVD) = #False And GadgetHoverCheck(#MainWindow,#DrawArea) = #True
            InitWindowSelected()
          EndIf

        Case #PB_Event_RightClick   ;does not work on Linux
          If GetGadgetState(#EnableSVD) = #False And GadgetHoverCheck(#MainWindow,#DrawArea) = #True
            X=WindowMouseX(#MainWindow)-GadgetX(#DrawArea) : Y=WindowMouseY(#MainWindow)-GadgetY(#DrawArea)   ;Keep the coordinates of the mouse before creating the gadget
            DisplayPopupMenu(#PopUpMenu,WindowID(#MainWindow))
          EndIf

        Case #PB_Event_Menu   ;-> Event Menu
          Select EventMenu()
            Case 1 To 27   ;Popup menu for creating gadgets
              CreateGadgets(EventMenu())

            Case #Shortcut_Delete   ;AddKeyboardShortcut is added on #PB_EventType_Focus and RemoveKeyboardShortcut on #PB_EventType_LostFocus in module, proc SVD_Callback
              If GetGadgetState(#ListGadgets) > 0
                IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
                If IsGadget(IdGadget)
                  RemoveGadgetItem(#ListGadgets, GetGadgetState(#ListGadgets))
                  For I = 1 To ArraySize(Gadgets())
                    If Gadgets(I)\Idgadget = IdGadget
                      Gadgets(I)\ModelType=9
                      Break
                    EndIf
                  Next
                  DeleteSVDGadgetFromDragHandle(GetActiveGadget())
                  InitWindowSelected()
                EndIf
              EndIf

            Case #Shortcut_Insert   ;Insert key as Right Click replacement under Linux
              If GetGadgetState(#EnableSVD) = #False And GadgetHoverCheck(#MainWindow,#DrawArea) = #True
                X=WindowMouseX(#MainWindow)-GadgetX(#DrawArea) : Y=WindowMouseY(#MainWindow)-GadgetY(#DrawArea)   ;Keep the coordinates of the mouse before creating the gadget
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
                    DisableSVD()
                    DrawGrid(#False)

                  Case #False   ;EnableSVD Parameters: drawing area, Drag Space
                    SetGadgetText(#EnableSVD, "Disable SVD")
                    CompilerIf #PB_Compiler_OS = #PB_OS_Linux : AddKeyboardShortcut(#MainWindow, #PB_Shortcut_Insert, #Shortcut_Insert) : CompilerEndIf   ;Insert key as Right Click replacement under Linux
                    InitWindowSelected()
                    HideGadget(#SettingContainer,#False)
                    HideGadget(#GadgetList,#False)
                    HideGadget(#PropertiesContainer,#False)
                    EnableSVD(#DrawArea, GetGadgetState(#DragSVD))
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

              Case #AddGadgetButton
                X = MyGrid : Y = MyGrid   ;coordinates for creating gadget inside #DrawArea
                DisplayPopupMenu(#PopUpMenu,WindowID(#MainWindow))

              Case #DeleteGadgetButton
                If GetGadgetState(#ListGadgets) > 0
                  IdGadget=GetGadgetItemData(#ListGadgets, GetGadgetState(#ListGadgets))
                  If IsGadget(IdGadget)
                    RemoveGadgetItem(#ListGadgets, GetGadgetState(#ListGadgets))
                    For I = 1 To ArraySize(Gadgets())
                      If Gadgets(I)\Idgadget = IdGadget
                        Gadgets(I)\ModelType=9
                        Break
                      EndIf
                    Next
                    DeleteSVDGadget(IdGadget)
                    InitWindowSelected()
                  EndIf
                EndIf

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

              Case  #DrawWidth
                If GetGadgetState(#ListGadgets) = 0 : InitWindowSelected() : EndIf
                If EventType() = #PB_EventType_Change And IsGadget(#DrawArea)
                  ResizeDrawArea(GetGadgetState(#DrawWidth), #PB_Ignore)
                EndIf

              Case #DrawHeight
                If GetGadgetState(#ListGadgets) = 0 : InitWindowSelected() : EndIf
                If EventType() = #PB_EventType_Change And IsGadget(#DrawArea)
                  ResizeDrawArea(#PB_Ignore, GetGadgetState(#DrawHeight))
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
                  SetGadgetState(#DrawWidth, GetGadgetState(#PosGadgetWidth))
                  ResizeDrawArea(GetGadgetState(#DrawWidth), #PB_Ignore)
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
                  SetGadgetState(#DrawHeight, GetGadgetState(#PosGadgetHeight))
                  ResizeDrawArea(#PB_Ignore, GetGadgetState(#DrawHeight))
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
                    SetGadgetText(IdGadget, GetGadgetText(#CaptionString))
                    Gadgets(GetGadgetData(IdGadget))\Caption = GetGadgetText(#CaptionString)
                  EndIf
                  If IsWindow(IdGadget)
                    Gadgets(0)\Caption = GetGadgetText(#CaptionString)
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
                    If Gadgets(GetGadgetData(IdGadget))\IdModel = 22  ;25
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
                    If Gadgets(GetGadgetData(IdGadget))\IdModel = 22 ;25
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
              ;On affecte le compteur de gadget global à ce nouveau gadget
              For I=0 To CountGadgetItems(#ListGadgets)
                If GetGadgetItemData(#ListGadgets, I)=EventGadget()
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

          EndSelect   ;EventType()
      EndSelect
    ForEver

    Procedure Exit()
      FreeArray(ModelGadget())
      FreeArray(Gadgets())
      End   ;Do I need to free things
    EndProcedure

    DataSection   ;- Data Section (Model)
      #Img_Delete:
      IncludeBinary "delete-icon.png"

      #Img_Add:
      IncludeBinary "add-icon.png"

      #Img_About:
      IncludeBinary "about.png"

      ModelGadgets:   ;27 Gadgets Models +window Model
                      ;"CreateGadget","Order","GadgetType","Width","Height","Name","Caption","Option1","Option2","Option3","FrontColor","BackColor","Constants"
      Data.s "OpenWindow","0","","800","600","Window","","","","","#Nooo","","Window_SystemMenu(x)|Window_MinimizeGadget(x)|Window_MaximizeGadget(x)|Window_SizeGadget(x)|Window_Invisible|Window_TitleBar|Window_Tool|Window_BorderLess|Window_ScreenCentered(x)|Window_WindowCentered|Window_Maximize|Window_Minimize|Window_NoGadgets"
      Data.s "ButtonGadget","1","1","100","20","Button","","","","","#Nooo","#Nooo","Button_Right|Button_Left|Button_Default|Button_MultiLine|Button_Toggle"
      Data.s "ButtonImageGadget","2","19","100","20","ButtonImage","#Nooo","#Imag:0","","","#Nooo","#Nooo","Button_Toggle"
      Data.s "CalendarGadget","3","20","220","160","Calendar","#Nooo","#Date:0","","","","","Calendar_Borderless"
      Data.s "CanvasGadget","4","33","140","40","Canvas","#Nooo","","","","#Nooo","#Nooo",""
      Data.s "CheckBoxGadget","5","4","100","20","Checkbox","","","","","#Nooo","#Nooo","CheckBox_Right|CheckBox_Center|CheckBox_ThreeState"
      Data.s "ComboBoxGadget","6","8","100","20","Combo","#Nooo","","","","#Nooo","#Nooo","ComboBox_Editable|ComboBox_LowerCase|ComboBox_UpperCase|ComboBox_Image"
      Data.s "DateGadget","7","21","120","20","Date","","#Date","","","#Nooo","#Nooo","Date_UpDown|Date_CheckBox"
      Data.s "EditorGadget","8","22","140","40","Editor","#Nooo","","","","","",""
      Data.s "ExplorerComboGadget","9","25","120","20","ExplorerCombo","","","","","#Nooo","#Nooo","Explorer_DrivesOnly|Explorer_Editable|Explorer_NoMyDocuments"
      Data.s "ExplorerListGadget","10","23","160","80","ExplorerList","","","","","","","Explorer_NoMyDocuments|Explorer_BorderLess|Explorer_AlwaysShowSelection|Explorer_MultiSelect|Explorer_GridLines|Explorer_HeaderDragDrop|Explorer_FullRowSelect|Explorer_NoFiles|Explorer_NoFolders|Explorer_NoParentFolder|Explorer_NoDirect"
      Data.s "ExplorerTreeGadget","11","24","160","80","ExplorerTree","","","","","","","Explorer_BorderLess|Explorer_AlwaysShowSelection|Explorer_NoLines|Explorer_NoButtons|Explorer_NoFiles|Explorer_NoDriveRequester|Explorer_NoMyDocuments|Explorer_AutoSort"
      Data.s "HyperLinkGadget","12","10","150","20","Hyperlink","","#Hard:RGB(0,0,128)","","","","","HyperLink_Underline"
      Data.s "ImageGadget","13","9","140","40","Image","#Nooo","#Imag:0","","","#Nooo","#Nooo","Image_Border"
      Data.s "IPAddressGadget","14","13","100","20","IPAddress","#Nooo","","","","#Nooo","#Nooo",""
      Data.s "ListIconGadget","15","12","140","40","ListIcon","#Nooo","#Titl","#Widh:140","","","","ListIcon_CheckBoxes|ListIcon_ThreeState|ListIcon_MultiSelect|ListIcon_GridLines|ListIcon_FullRowSelect|ListIcon_HeaderDragDrop|ListIcon_AlwaysShowSelection"
      Data.s "ListViewGadget","16","6","140","40","ListView","#Nooo","","","","","","ListView_MultiSelect|ListView_ClickSelect"
      Data.s "OpenGLGadget","17","34","100","20","OpenGL","#Nooo","","","","#Nooo","#Nooo","OpenGL_Keyboard"
      Data.s "OptionGadget","18","5","100","20","Option","","","","","#Nooo","#Nooo",""
      Data.s "ProgressBarGadget","19","14","140","14","ProgressBar","#Nooo","#Mini:0","#Maxi:0","","","","ProgressBar_Smooth|ProgressBar_Vertical"
      Data.s "ScintillaGadget","20","31","140","40","Scintilla","#Nooo","#Hard:0","","","#Nooo","#Nooo",""
      Data.s "ScrollBarGadget","21","15","140","16","Scrollbar","#Nooo","#Mini:0","#Maxi:0","#Long:0","#Nooo","#Nooo","ScrollBar_Vertical"
      Data.s "SpinGadget","22","26","100","20","Spin","#Nooo","#Mini:0","#Maxi:0","","","","Spin_ReadOnly|Spin_Numeric(x)"
      Data.s "StringGadget","23","2","100","20","String","","","","","","","String_Numeric|String_Password|String_ReadOnly|String_LowerCase|String_UpperCase|String_BorderLess"
      Data.s "TextGadget","24","3","100","20","Text","","","","","","","Text_Center|Text_Right|Text_Border"
      Data.s "TrackBarGadget","25","17","100","20","TrackBar","#Nooo","#Mini:0","#Maxi:100","","#Nooo","#Nooo","TrackBar_Ticks|TrackBar_Vertical"
      Data.s "TreeGadget","26","27","100","20","Tree","#Nooo","","","","","","Tree_AlwaysShowSelection|Tree_NoLines|Tree_NoButtons|Tree_CheckBoxes|Tree_ThreeState"
      Data.s "WebGadget","27","18","260","125","WebView","","","","","#Nooo","#Nooo",""
      ;Data.s "ContainerGadget","28","11","200","50","Container","#Nooo","","","","","","Container_BorderLess|Container_Flat|Container_Raised|Container_Single|Container_Double"
      ;Data.s "FrameGadget","29","7","200","50","Frame3D","","","","","#Nooo","#Nooo","Frame_Single|Frame_Double|Frame_Flat"
      ;Data.s "PanelGadget","30","28","200","50","Panel","#Nooo","","","","#Nooo","#Nooo",""
      ;Data.s "ScrollAreaGadget","31","16","200","50","ScrollArea","#Nooo","#InrW:0","#InrH:0","#Step:1","","","ScrollArea_Flat|ScrollArea_Raised|ScrollArea_Single|ScrollArea_BorderLess|ScrollArea_Center"
    EndDataSection
  CompilerEndIf

  ; IDE Options = PureBasic 5.4* LTS (Linux - x86/x64) - PureBasic 5.4* LTS, 5.5* and 5.6* (Windows - x86/x64)
  ; EnableUnicode
  ; EnableXP
  ; EnablePurifier
; IDE Options = PureBasic 5.60 (Windows - x64)
; CursorPosition = 20
; FirstLine = 4
; Folding = -----
; EnableXP
; UseIcon = Include\SweetyVD.ico
; Executable = ..\..\..\Temp\SweetyVD-master\SweetyVD.exe
; Compiler = PureBasic 5.60 (Windows - x86)
; EnablePurifier
; IncludeVersionInfo
; VersionField0 = 1.6.0
; VersionField1 = 1.6.0
; VersionField3 = SweetyVD.exe
; VersionField4 = 1.6.0
; VersionField5 = 1.6.0
; VersionField6 = Sweety Visual Designer
; VersionField7 = SweetyVD.exe
; VersionField8 = SweetyVD.exe
; VersionField9 = @ChrisR
; Watchlist = CodeGenerate()>Code