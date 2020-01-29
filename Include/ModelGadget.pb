#CountModelGadget = 32

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

Declare InitModelWindow()
Declare InitModelgadget()
Declare InitJSONModelGadget()
Declare SaveJSONModelGadget()

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
        SetDrawWidth  = \DftWidth
        SetDrawHeight = \DftHeight
        ;DrawArea Size max Width and max Height
        DrawAreaSize(\DftWidth, \DftHeight)
        ;Save window information in the gadget List. Element 0
        AddMapElement(SVDListGadget(), Str(#MainWindow))
        SVDListGadget()\Gadget=#MainWindow
        SVDListGadget()\Model="OpenWindow"
        SVDListGadget()\Type=0
        SVDListGadget()\Name="#"+\Name+"_0"
        SVDListGadget()\Selected = 0
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
        SVDListGadget()\DrawGadget=#True
        SVDListGadget()\Image=0
        SVDListGadget()\ModelType=0
        ;Add Window to List Gadgets ComboBox. Element 0 for the Window Draw Area
        AddGadgetItem(#ListGadgets, -1, Mid(SVDListGadget()\Name, 2))
        SetGadgetState(#ListGadgets, 0)
        SetGadgetItemData(#ListGadgets, 0, 0)
        
        AddGadgetItem(#ListControls, -1, Mid(SVDListGadget()\Name, 2), ImageID(\Image), 0)
        SetGadgetState(#ListControls, 0)
        SetGadgetItemData(#ListControls, 0, 0)
      EndWith
      Break
    EndIf
  Next
  
EndProcedure

Procedure InitModelgadget()   ;Initializing Gadget Templates
  Protected Buffer.s, GadgetCtrlFound.b, CountItem.i, I.i, J.i
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
  
  For I=0 To #CountModelGadget
    With ModelGadget(I)
      Select \Type
        Case 0        ;OpenWindow
          \Image=CatchImage(#PB_Any,?Vd_Window)
          InitModelWindow()   ;Draw Area Width and Height and Save Window information
        Case 50               ;Custom Gadget
          \Image=CatchImage(#PB_Any,?Vd_Custom)
          AddGadgetItem(#CreateControlsList, CountItem, \Model, ImageID(\Image))
          SetGadgetItemData(#CreateControlsList, CountItem, \Image)
          MenuItem(I, \Model, ImageID(\Image))   ;Add to popup menu
          CountItem +1
        Default
          GadgetCtrlFound = #False
          For J = 1 To ArraySize(GadgetCtrlArray())   ;Load Popup Menu Image and ListIcon Controls Gadgets with Image
            If GadgetCtrlArray(J)\GadgetCtrlName = LCase(\Model)
              GadgetCtrlFound = #True
              \Image=GadgetCtrlArray(J)\GadgetCtrlImage
              AddGadgetItem(#CreateControlsList, CountItem, \Model, ImageID(\Image))
              SetGadgetItemData(#CreateControlsList, CountItem, \Image)
              MenuItem(I, \Model, ImageID(\Image))   ;Add to popup menu
              CountItem +1
            EndIf
          Next
          If GadgetCtrlFound = #False   ;If image not found, use Vd_Unknow.png
            \Image=GadgetCtrlArray(0)\GadgetCtrlImage
            AddGadgetItem(#CreateControlsList, CountItem, \Model, ImageID(\Image))
            SetGadgetItemData(#CreateControlsList, CountItem, \Image)
            MenuItem(I, \Model, ImageID(\Image))   ;Add to popup menu
            CountItem +1
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

DataSection   ;- Data Section (Model)
  ModelGadgets:   ;31 Gadgets Models +window Model
                  ;"Model","Order","GadgetType","Width","Height","Name","Caption","Option1","Option2","Option3","FrontColor","BackColor","ToolTip","Constants"
  Data.s "OpenWindow","0","","640","480","Window","#Text","","","","#Nooo","","#Nooo","Window_SystemMenu(x)|Window_MinimizeGadget(x)|Window_MaximizeGadget(x)|Window_SizeGadget(x)|Window_Invisible|Window_TitleBar|Window_Tool|Window_BorderLess|Window_ScreenCentered(x)|Window_WindowCentered|Window_Maximize|Window_Minimize|Window_NoGadgets"
  Data.s "ButtonGadget","1","1","100","20","Button","#Text","","","","#Nooo","#Nooo","","Button_Right|Button_Left|Button_Default|Button_MultiLine|Button_Toggle"
  Data.s "ButtonImageGadget","2","19","100","20","ButtonImage","","#Imag:0","","","#Nooo","#Nooo","","Button_Toggle"
  Data.s "CalendarGadget","3","20","220","160","Calendar","","#Date:0","","","#Nooo","#Nooo","","Calendar_Borderless"
  Data.s "CanvasGadget","4","33","140","40","Canvas","#Text","#Imag:0","","","#Nooo","#Nooo","",""
  Data.s "CheckBoxGadget","5","4","100","20","Checkbox","#Text","","","","#Nooo","#Nooo","","CheckBox_Right|CheckBox_Center|CheckBox_ThreeState"
  Data.s "ComboBoxGadget","6","8","100","20","Combo","","","","","#Nooo","#Nooo","","ComboBox_Editable|ComboBox_LowerCase|ComboBox_UpperCase|ComboBox_Image"
  Data.s "ContainerGadget","7","11","300","200","Container","","","","","","","","Container_BorderLess|Container_Flat|Container_Raised|Container_Single|Container_Double"
  Data.s "DateGadget","8","21","120","20","Date","#Date:","#Date","","","#Nooo","#Nooo","","Date_UpDown|Date_CheckBox"
  Data.s "EditorGadget","9","22","140","40","Editor","","","","","","","",""
  Data.s "ExplorerComboGadget","10","25","120","20","ExplorerCombo","#Dir$","","","","#Nooo","#Nooo","#Nooo","Explorer_DrivesOnly|Explorer_Editable|Explorer_NoMyDocuments"
  Data.s "ExplorerListGadget","11","23","160","80","ExplorerList","#Dir$","","","","","","","Explorer_NoMyDocuments|Explorer_BorderLess|Explorer_AlwaysShowSelection|Explorer_MultiSelect|Explorer_GridLines|Explorer_HeaderDragDrop|Explorer_FullRowSelect|Explorer_NoFiles|Explorer_NoFolders|Explorer_NoParentFolder|Explorer_NoDirect"
  Data.s "ExplorerTreeGadget","12","24","160","80","ExplorerTree","#Dir$","","","","","","","Explorer_BorderLess|Explorer_AlwaysShowSelection|Explorer_NoLines|Explorer_NoButtons|Explorer_NoFiles|Explorer_NoDriveRequester|Explorer_NoMyDocuments|Explorer_AutoSort"
  Data.s "FrameGadget","13","7","200","100","Frame","#Text","","","","#Nooo","#Nooo","#Nooo","Frame_Single|Frame_Double|Frame_Flat"
  Data.s "HyperLinkGadget","14","10","160","20","Hyperlink","#Url$:https://www.purebasic.com/","#Hard:RGB(0,0,128)","","","","","","HyperLink_Underline"
  Data.s "ImageGadget","15","9","140","40","Image","","#Imag:0","","","#Nooo","#Nooo","","Image_Border"
  Data.s "IPAddressGadget","16","13","100","20","IPAddress","","","","","#Nooo","#Nooo","",""
  Data.s "ListIconGadget","17","12","140","60","ListIcon","#Text","","#Widh:120","","","","","ListIcon_CheckBoxes|ListIcon_ThreeState|ListIcon_MultiSelect|ListIcon_GridLines|ListIcon_FullRowSelect|ListIcon_HeaderDragDrop|ListIcon_AlwaysShowSelection"
  Data.s "ListViewGadget","18","6","140","60","ListView","","","","","","","","ListView_MultiSelect|ListView_ClickSelect"
  Data.s "OpenGLGadget","19","34","100","100","OpenGL","","","","","#Nooo","#Nooo","","OpenGL_Keyboard"
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
  Data.s "TreeGadget","30","27","140","60","Tree","","","","","","","","Tree_AlwaysShowSelection|Tree_NoLines|Tree_NoButtons|Tree_CheckBoxes|Tree_ThreeState"
  Data.s "WebGadget","31","18","260","125","WebView","#Url$:https://www.purebasic.fr/english/index.php","","","","#Nooo","#Nooo","#Nooo",""
  Data.s "TabBarGadget","32","40","140","27","TabBar","#TabN","","","","#Nooo","#Nooo","#Nooo","BottomLine(x)|CheckBox|CloseButton(x)|Editable|MirroredTabs|MultiLine|MultiSelect|NewTab|NoTabMoving|PopupButton|ReverseOrdering|SelectedCloseButton|TextCutting|Vertical"
EndDataSection

; IDE Options = PureBasic 5.71 LTS (Windows - x64)
; Folding = -
; EnableXP