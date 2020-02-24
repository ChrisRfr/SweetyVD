;{ ==Code Header Comment==============================
;        Name/title: OnOffButton.pbi
;   Executable name: Custom Gadget No exe
;           Version: 1.0
;            Author: STARGÅTE
;     Modifications: Collectordave
;    Translation by:
;       Create date: 20\12\2016
; Previous releases:
; This Release Date:
;  Operating system: Windows  [X]GUI
;  Compiler version: PureBasic 5.5 (x64)
;         Copyright: (C)2016
;           License:
;         Libraries:
;     English Forum:
;      French Forum:
;      German Forum:
;  Tested platforms: Windows
;       Description: Custom gadget Include File
; ====================================================
;.......10........20........30........40........50........60........70........80
;}

UsePNGImageDecoder()
DeclareModule OnOffButton

  ;{ ==Gadget Event Enumerations=================================
;        Name/title: Enumerations
;       Description: Part of custom gadget template
;                  : Enumeration of Custom Gagdet event constants
;                  : Started at 100 to Avoid Using 0
;                  : as creation events etc can still be recieved
;                  : in main event loop
; ================================================================
;}
  Enumeration 100
    #StateIsOn
    #StateIsOff
  EndEnumeration

  ;Create the gadget procedure Only used by main gadget public procedure
  Declare CreateGadget(Gadget.i, x.i,y.i,width.i,height.i,Flags.i)
  Declare.i GetState(Gadget.i)
  Declare SetState(Gadget.i,State.i)

EndDeclareModule

Module OnOffButton

  ;The Main Gadget Structure
  ;All Variables Used By The Gadget should Be Declared In This Structure
  ;Variables Declared Out Of The Structure are not guaranteed
  Structure MyGadget
    Window_ID.i
    Gadget_ID.i
    Image.i
    HoverImage.i
    ButtonImage.i
    DisabledImage.i
    State.i
    Hover.i
    Move.i
    Disabled.i
    Thread.i
    Quit.i
 EndStructure

  Global Dim MyGadgetArray.MyGadget(0)
  Global CurrentGadget.i

  ;Required To Obtain Resize Events
  Enumeration #PB_EventType_FirstCustomValue
    #PB_EventType_Size
    #PB_EventType_Move
  EndEnumeration

  Procedure.i SetCurrentGadget(Gadget.i)
  ;{ ==Procedure Header Comment==============================
;        Name/title: GetgadgetID
;       Description: Part of custom gadget template
;                  : Procedure to return the MyGadgetArray() element number
;                  : for the gadget on which the event occurred
;
; ====================================================
;}
    Define iLoop.i

    For iLoop = 0 To ArraySize(MyGadgetArray())

      If Gadget = MyGadgetArray(iLoop)\Gadget_ID

        CurrentGadget = iLoop

      EndIf

    Next iLoop

    ProcedureReturn CurrentGadget

  EndProcedure

  Procedure DrawGadget(Gadget.i)
  ;{ ==Procedure Header Comment==============================
  ;        Name/title: DrawGadget
  ;       Description: Procedure to draw the gadget on the canvas
  ;
  ; ====================================================
  ;}
    If CurrentGadget <> Gadget
      SetCurrentGadget(Gadget)
    EndIf

    If StartDrawing(CanvasOutput(MyGadgetArray(CurrentGadget)\Gadget_ID))
      ; Background
      If MyGadgetArray(CurrentGadget)\Disabled
        DrawImage(ImageID(MyGadgetArray(CurrentGadget)\DisabledImage), 0, 0)
      ElseIf MyGadgetArray(CurrentGadget)\Hover
        DrawImage(ImageID(MyGadgetArray(CurrentGadget)\HoverImage), 0, 0)
      Else
        DrawImage(ImageID(MyGadgetArray(CurrentGadget)\Image), 0, 0)
      EndIf
      ; Button
      DrawAlphaImage(ImageID(MyGadgetArray(CurrentGadget)\ButtonImage), MyGadgetArray(CurrentGadget)\Move, 0)
      StopDrawing()
    EndIf

  EndProcedure

  Procedure IDGadget( GadgetID )
 ;{ ==Procedure Header Comment==============================
;        Name/title: IDGadget
;       Description: Part of custom gadget template
;                  : Required to capture resize events of the gadget canvas
;
; ====================================================
;}


     CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Windows
        ProcedureReturn GetProp_( GadgetID, "PB_GadgetID") - 1

      CompilerCase #PB_OS_Linux
        g_object_get_data_( GadgetID, "PB_GadgetID") - 1

    CompilerEndSelect
  EndProcedure

    CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      Procedure Resize_CallBack(GadgetID, Msg, wParam, lParam)
;{ ==Procedure Header Comment==============================
;        Name/title: Resize_CallBack
;       Description: Part of custom gadget template
;                  : Required to capture resize events of the gadget canvas
;                  : when running on windows
; ====================================================
;}
        Protected *Func = GetProp_( GadgetID, "Resize_Event_CallBack")

        Protected *Gadget = IDGadget( GadgetID )

        Protected *Window = GetActiveWindow() ; GetProp_( GadgetID, "PB_WindowID") - 1

        Select Msg
          Case #WM_SIZE : PostEvent( #PB_Event_Gadget, *Window, *Gadget , #PB_EventType_Size )
          Case #WM_MOVE : PostEvent( #PB_Event_Gadget, *Window, *Gadget , #PB_EventType_Move )
          Default

            ProcedureReturn CallWindowProc_(*Func, GadgetID, Msg, wParam, lParam)
        EndSelect


      EndProcedure

    CompilerCase #PB_OS_Linux
      ProcedureC Resize_CallBack( *Event.GdkEventAny, *Handle )
  ;{ ==Procedure Header Comment==============================
;        Name/title: Resize_CallBack
;       Description: Part of custom gadget template
;                  : Required to capture resize events of the gadget canvas
;                  : when running on Linux
; ====================================================
;}
        Protected *Widget.GtkWidget = gtk_get_event_widget_(*Event)
        ;Debug gdk_event_get_screen_ (*event)

        If *Widget
          ;Debug PeekS( gtk_widget_get_name_( (*Widget)), -1, #PB_UTF8 ) + " " + Str(g_object_get_data_(*Widget, "PB_GadgetID") - 1)
        EndIf

        If *Widget And *Widget = g_object_get_data_(*Widget, "Resize_Event_CallBack")
          Select *Event\type
            Case #GDK_2BUTTON_PRESS
            Case #GDK_BUTTON_PRESS
            Case #GDK_BUTTON_RELEASE
            Case #GDK_ENTER_NOTIFY
            Case #GDK_LEAVE_NOTIFY
            Case #GDK_MOTION_NOTIFY
            Case #GDK_SCROLL
              Protected *scroll.GdkEventScroll = *Event
              Select *scroll\state
                Case #GDK_SCROLL_UP
                  ;Debug "scrollUP"
                Case #GDK_SCROLL_DOWN
                  ;Debug "scrollDown"
              EndSelect

            Case #GDK_KEY_PRESS
            Case #GDK_KEY_RELEASE
            Case #GDK_FOCUS_CHANGE
            Case #GDK_CONFIGURE
            Case #GDK_DESTROY
            Case #GDK_DELETE
            Case #GDK_EXPOSE
            Case #GDK_UNMAP

              gdk_event_handler_set_( 0, 0, 0 )
            Default

              gtk_main_do_event_( *Event )
          EndSelect
        Else
          gtk_main_do_event_( *Event )
        EndIf
      EndProcedure

  CompilerEndSelect

  Procedure SetIDGadget( Gadget )
 ;{ ==Procedure Header Comment==============================
;        Name/title: SetIDGadget
;       Description: Part of custom gadget template
;                  : Required to capture resize events of the gadget canvas
; ====================================================
;}
    CompilerSelect #PB_Compiler_OS

      CompilerCase #PB_OS_Windows
        If GetProp_( GadgetID( Gadget ), "PB_GadgetID" ) = 0
          ProcedureReturn SetProp_( GadgetID( Gadget ), "PB_GadgetID", Gadget + (1))
        EndIf

      CompilerCase #PB_OS_Linux
        If g_object_get_data_( GadgetID( Gadget ), "PB_GadgetID" ) = 0
          ProcedureReturn g_object_set_data_( GadgetID( Gadget ), "PB_GadgetID", Gadget + (1))
        EndIf

    CompilerEndSelect

  EndProcedure

  Procedure ResizeGadgetEvents(Gadget)

    Protected GadgetID, GadgetID1, GadgetID2, GadgetID3, GadgetID4

    If IsGadget( Gadget )
      SetIDGadget( Gadget )
      GadgetID = GadgetID( Gadget )

      CompilerSelect #PB_Compiler_OS

        CompilerCase #PB_OS_Linux
          g_object_set_data_( GadgetID, "PB_GadgetID", Gadget + 1 )
          g_object_set_data_( GadgetID, "Resize_Event_CallBack", GadgetID )
          gdk_event_handler_set_( @Resize_CallBack(), GadgetID, 0 )

        CompilerCase #PB_OS_Windows
          If GadgetID  And GetProp_( GadgetID,  "Resize_Event_CallBack") = #False
            SetProp_( GadgetID, "Resize_Event_CallBack", SetWindowLongPtr_(GadgetID, #GWL_WNDPROC, @Resize_CallBack()))
          EndIf

      CompilerEndSelect

    EndIf

  EndProcedure

  Procedure AddGadget(ThisWindow.i,ThisGadget.i)
 ;{ ==Procedure Header Comment==============================
;        Name/title: AddGadget
;       Description: Part of custom gadget template
;                  : Adds the Id of the newly created gadget to the gadget array
; ====================================================
;}

    MyGadgetArray(ArraySize(MyGadgetArray()))\Window_ID = ThisWindow
    MyGadgetArray(ArraySize(MyGadgetArray()))\Gadget_ID = ThisGadget
    ReDim MyGadgetArray(ArraySize(MyGadgetArray())+1)

  EndProcedure

  Procedure SendEvents(Event.i)
;{ ==Procedure Header Comment==============================
;        Name/title: SendEvents
;       Description: Part of custom gadget template
;                  : Used to send custom events to the main event loop
; ====================================================
;}

    PostEvent(#PB_Event_Gadget, MyGadgetArray(CurrentGadget)\Window_ID, MyGadgetArray(CurrentGadget)\Gadget_ID, #PB_Event_FirstCustomValue,Event)

 EndProcedure

  Procedure.i GetState(Gadget.i)

    SetCurrentGadget(Gadget)

    ProcedureReturn MyGadgetArray(CurrentGadget)\State

 EndProcedure

  Procedure SetState(Gadget.i,State.i)

    SetCurrentGadget(Gadget)

    If State = #True
      MyGadgetArray(CurrentGadget)\State = #True
      MyGadgetArray(CurrentGadget)\Move = 39
    Else
      MyGadgetArray(CurrentGadget)\State = #False
      MyGadgetArray(CurrentGadget)\Move = -1
    EndIf
    Drawgadget(Gadget)

 EndProcedure

  Procedure MoveGadget()

    Protected Quit.i = #False
    Repeat

     If MyGadgetArray(CurrentGadget)\State = #True And MyGadgetArray(CurrentGadget)\Move < 38
       MyGadgetArray(CurrentGadget)\Move + 2
       If MyGadgetArray(CurrentGadget)\Move => 38
         Quit = #True
         MyGadgetArray(CurrentGadget)\Move = 38
       EndIf
     ElseIf MyGadgetArray(CurrentGadget)\State = #False And MyGadgetArray(CurrentGadget)\Move > 0
       MyGadgetArray(CurrentGadget)\Move - 2
       If MyGadgetArray(CurrentGadget)\Move =< 0
         Quit = #True
         MyGadgetArray(CurrentGadget)\Move = 0
       EndIf
     EndIf
     DrawGadget(CurrentGadget)
     Delay(10)
   Until Quit = #True

  EndProcedure

  Procedure GadgetEvents()
  ;{ ==Procedure Header Comment==============================
;        Name/title: GadgetEvents
;       Description: Part of custom gadget template
;                  : Handles all events for this custom gadget
; ====================================================
;}

    SetCurrentGadget(EventGadget())

    Select EventType()

      Case #PB_EventType_MouseEnter

        MyGadgetArray(CurrentGadget)\Hover = #True
        DrawGadget(CurrentGadget)

      Case #PB_EventType_MouseLeave

        MyGadgetArray(CurrentGadget)\Hover = #False
        DrawGadget(CurrentGadget)

      Case #PB_EventType_MouseMove

        ;Debug "MouseMove On Gadget " + Str(CurrentGadget)

      Case #PB_EventType_MouseWheel

        ;Debug "MouseWheel  On Gadget " + Str(CurrentGadget)

      Case #PB_EventType_LeftButtonDown

        ;Debug "LeftButtonDown On Gadget " + Str(CurrentGadget)

      Case #PB_EventType_LeftButtonUp

        ;Debug "LeftButtonUp On Gadget " + Str(CurrentGadget)

      Case #PB_EventType_LeftClick

        If MyGadgetArray(CurrentGadget)\State = #True
          MyGadgetArray(CurrentGadget)\State = #False
          SendEvents(#StateIsOff)
        Else
          MyGadgetArray(CurrentGadget)\State = #True
          SendEvents(#StateIsOn)
        EndIf
        MoveGadget()

      Case #PB_EventType_LeftDoubleClick

        ;Debug "LeftDoubleClick On Gadget " + Str(CurrentGadget)

      Case #PB_EventType_RightButtonDown

        ;Debug "RightButtonDown On Gadget " + Str(CurrentGadget)

       Case #PB_EventType_RightButtonUp

        ;Debug "RightButtonUp On Gadget " + Str(CurrentGadget)

      Case #PB_EventType_RightClick

        ;Debug "RightClick On Gadget " + Str(CurrentGadget)

      Case #PB_EventType_RightDoubleClick

        ;Debug "RightDoubleClick On Gadget " + Str(CurrentGadget)

      Case #PB_EventType_MiddleButtonDown

        ;Debug "MiddleButtonDown On Gadget " + Str(CurrentGadget)

      Case #PB_EventType_MiddleButtonUp

        ;Debug "MiddleButtonUp On Gadget " + Str(CurrentGadget)

      Case #PB_EventType_Size

        ;Fixed Size Gadget No resize
        If GadgetHeight(MyGadgetArray(CurrentGadget)\Gadget_ID) <> 32
          ResizeGadget(MyGadgetArray(CurrentGadget)\Gadget_ID,#PB_Ignore,#PB_Ignore,#PB_Ignore,32)
        EndIf
        If GadgetHeight(MyGadgetArray(CurrentGadget)\Gadget_ID) <> 96
          ResizeGadget(MyGadgetArray(CurrentGadget)\Gadget_ID,#PB_Ignore,#PB_Ignore,96,#PB_Ignore)
        EndIf

      Case    #PB_EventType_Focus

        ;Debug "Got Focus On Gadget " + Str(CurrentGadget)

      Case      #PB_EventType_LostFocus

        ;Debug "lost Focus On Gadget " + Str(CurrentGadget)

      Case      #PB_EventType_KeyDown

        ;Debug "Key down On Gadget " + Str(CurrentGadget)

      Case      #PB_EventType_KeyUp

        ;Debug "Key Up On Gadget " + Str(CurrentGadget)

      Case      #PB_EventType_Input

        ;Debug "Input On Gadget " + Str(CurrentGadget)   + "= " +   Chr(GetGadgetAttribute(MyGadgetArray(CurrentGadget)\Gadget_ID, #PB_Canvas_Input ))

    EndSelect

  EndProcedure

  Procedure CreateGadget(Gadget.i, x.i,y.i,width.i,height.i,Flags.i)
    ;{ ==Procedure Header Comment==============================
;        Name/title: CreateGadget
;       Description: Part of custom gadget template
;                  : procedure to create the canvas used for the gadget
; ====================================================
;}
    Define ThisWindow.i,ThisGadget.i

    ;minimum height for the button
    If Height <> 32
      Height = 32
    EndIf
    If Width <> 96
      Width = 96
    EndIf

    ;Create The Canvas For The Gadget
    If Gadget = #PB_Any
      ThisGadget = CanvasGadget(#PB_Any, x,y,width,height,Flags)
    Else
      ThisGadget = Gadget
      CanvasGadget(Gadget, x,y,width,height,Flags)
    EndIf

    ;Bind This Gadgets Events
    BindGadgetEvent(ThisGadget, @GadgetEvents())

    ;The Window On Which It Is Created
    ThisWindow = UseGadgetList(0)

    ;Add To The Custom Gadget Array
    AddGadget(ThisWindow,ThisGadget)

    ;Add Resize Event
    ResizeGadgetEvents( ThisGadget )

    SetCurrentGadget(ThisGadget)

    ;Grab Images For The Gadget
    MyGadgetArray(CurrentGadget)\Image = CatchImage(#PB_Any, ?Image_OnOff)
    MyGadgetArray(CurrentGadget)\HoverImage = CatchImage(#PB_Any, ?Image_OnOffHover)
    MyGadgetArray(CurrentGadget)\ButtonImage = CatchImage(#PB_Any, ?Image_OnOffButton)
    MyGadgetArray(CurrentGadget)\DisabledImage = CatchImage(#PB_Any, ?Image_OnOffDisabled)

    ;Draw the actual gadget
    DrawGadget(CurrentGadget)

    ProcedureReturn ThisGadget

  EndProcedure


DataSection
   Image_OnOff:
   Data.q $0A1A0A0D474E5089,$524448490D000000,$2000000060000000,$7DC0ED0000000608,$4942730400000054
   Data.q $64087C0808080854,$5948700900000088,$0D0000D70D000073,$0000789B284201D7,$6F53745845741900
   Data.q $7700657261777466,$63736B6E692E7777,$9B67726F2E657061,$49340800001A3CEE,$5D9AED8168544144
   Data.q $1F277FC719D99350,$B22232434F843BE4,$71D1419AEA905620,$B2DAEEBAA6163BB4,$54BC674EBB8C3A9D
   Data.q $5ED37B4CEB756C6F,$378ED599D6F6D5EC,$59D576ECE9D9C75A,$7151014558BAA83F,$488402441202C45D
   Data.q $12C8BDBC7C840902,$F9538376CC504D7D,$CFF3DE739F7924DD,$188DE739E79E7279,$CC50CE6798951D1D
   Data.q $31CC07799D3780B5,$0D439860810C99AA,$87CFAF728F7734BD,$3FAB061AF48933D3,$84202425AE6EFB2D
   Data.q $D58F9F9F923468C0,$64646495CAE5656A,$B87634072C9B6F24,$1FC9EE879DB473D9,$F3C07475E50FEC5D
   Data.q $2C286A6A6A66CD98,$C3B1A03825B04C2C,$32051C266D3F2FCD,$754A08DA83B6608C,$9F5CD62712BEF4BA
   Data.q $4C4CC3870949096B,$40989899BB76E04C,$6413825D5D5D4108,$7B68E7B30C102039,$6D072FC8364DF26C
   Data.q $952A33AFF93B6BD6,$B911515144C9930A,$E773B9C49248B9B9,$E03993B5929A9A98,$211864EC2C6F4350
   Data.q $12FFF9A9D2202173,$3A74E87979790421,$BB326D6D6D1F3E7C,$C8568C063F37092C,$194CEA749CFA0E5F
   Data.q $830ACC25AE77B5AB,$E3E3E337777740C1,$103FAF7015B2EBB2,$829BD84DA531A37B,$AEC8F1E3C003A74E
   Data.q $A37B1C34738056CB,$B28040C325325E4C,$D494130DD52C478C,$0444542F70E44E74,$AD328B8542CDBC65
   Data.q $D109509DCF48770B,$07BE870F899EFDEF,$FA530BC20F3654E7,$0783C6363632A962,$503060C6EEEEE80F
   Data.q $E2104B2592CC5C5C,$707060E8E8EDD869,$D56AB23468CFD650,$45DEEF770F1E3C2A,$3870E0421736A67A
   Data.q $B1D5A9E309F5EBD0,$0E65D765FBF7EA3C,$1F0EE1937F3AD578,$CE4E465D5DA97995,$3987868661C3845B
   Data.q $10782AFACF81B171,$D8ECADC5FD8021B2,$F2FE7F38DF518EB2,$655F801EB3CDFCDF,$E5F4382B9DD7F1B5
   Data.q $93A6038F49EE3E0D,$3EFF7FB967B3D9E1,$ABABAB309E204081,$0C13B76EC7AFAFA9,$EDEDED08E4723906
   Data.q $BCBCA32D96CBFEB2,$29D4EA738FC7E39C,$1ECF67B356AD4D99,$8DC667AD666A6A6A,$6A4F93A33B78CBD8
   Data.q $9BAF89C75F2CAC35,$96CA329D16FC18E8,$7F341AC3FEFCC5D5,$C0A089F33AEFC0BF,$2C58B058B1613662
   Data.q $308CAEAF98FE5FBC,$44CCCCC89020E52C,$15CAE575955F4AA1,$AAA1E3C78C3E1F0E,$A0102046CD9B0AAA
   Data.q $8D134FA7D385A5A5,$8850A13F7FBFD946,$C6E3641830402040,$D44A16205AB5688D,$49C9C98850A1356A
   Data.q $FC4141414158AC56,$03B29117FD6AC9FE,$F9CFF96AB2F5B03E,$329FDDC3F9971FEC,$50E46E1B68005922
   Data.q $7C7868AA5B9D85BE,$878786000EE35393,$3E0E0D96CDDED6B9,$1D529B83A7C8BCEC,$5D2E97089122653A
   Data.q $8779DE7798787862,$3800183061F6FB7D,$EAE51E8F4718EC76,$CACA8D76BB5CABD5,$A82A2A2A5616204A
   Data.q $028282CF7A4BABAB,$CE94A6B290381C0E,$34459458A9F80C82,$807C9F1A3FB9A51A,$6477FAE171578E7F
   Data.q $735DE3CBD22CCD9A,$A147915DDE002DEB,$78F1E2A9D1652062,$595152A542EAEAE8,$379BCD807C9F1959
   Data.q $A7A3E7CF8C5C5C53,$39015A529A6D27A7,$79FBF7E367B52878,$8C8C34416CCB3414,$4D09A7DA991B36C7
   Data.q $DB1A6719684B4108,$C05FB4762AC37778,$00C0C0DE0DDE9135,$2A109B56AD1BB76E,$2944B24924A443A6
   Data.q $B6B6B44D4D4D1249,$777BBDD8D9B36002,$0783C1C5D5D5DEDC,$97BBDDEC3468D001,$C039926B59ACACAC
   Data.q $3E9AC92D6ABD8C6A,$142810A5451C2ED3,$A3CDCF451274720A,$B22C10A94802FBE6,$31951468D1014A80
   Data.q $F10DAED4839DCB97,$EDE35B1717CEC39E,$E6C74C4CE6325E8B,$4924BC16C450A0D9,$222448DF594A9528
   Data.q $FD445789A346A7BB,$68595959BEF1FDFD,$204DDBB767F8DAB5,$4211B3B3B3DF2B10,$2B4A5C81D929A8CC
   Data.q $B79BB077A1614C60,$D4FC200753C88B8A,$E93CC4E7B0FA8FA6,$F560EFC67796724D,$BE6F96BB5D7E16C5
   Data.q $D9B36329F0CA9CB9,$4E9C2E5CB82C58B0,$2E5CDB8EAF57AB27,$D94A952843434317,$A95BADD6C108582F
   Data.q $ACB3E8656205ADAD,$310176BB5D86B359,$5294D257D6AD5B07,$8237DFB99850980E,$34694C897CCA8210
   Data.q $A86C1B86AD891626,$8B935B93BDA5A0AA,$CCB627A97235F492,$329F0CA937E3BB7F,$0E11151514B9B9B9
   Data.q $1A577C4EE773B987,$BDBD24F279384489,$5AED76B1959594BD,$C366CD874E9D3F59,$10AE43CB3661B366
   Data.q $571487C9D57B6E22,$F45F8590E3411440,$ABFCB1EB7BD1F1F6,$96C15A2C299E8799,$F5345F1249236F75
   Data.q $E7FE84D1045A90F0,$EF9D89A17E7C1D27,$C8C8C994F865486F,$D36FB7DB9ABABAA0,$82C165EBD780D0D0
   Data.q $16969684F2793C05,$EDD8D5D5D50D1A34,$E529A2D2C6C6C676,$7D397F157446F432,$98BE59AC3D459A9D
   Data.q $DCB4BD7A8C59D94D,$FC4D5F38C77CE2ED,$5C31F1FE0408040C,$1210102AA3848383,$8DBE6D299BF7CE1A
   Data.q $FCBFF82058C2DF3D,$4D4C6DB6DB642F4E,$27676748D8D8D14D,$74B03060C2DD6EB7,$EDF6CF5FAFD652E9
   Data.q $98B56AD1385881DB,$285269C4AA54264C,$1539CED9264C9814,$2436C7F27E03CF64,$9D037D671B25B409
   Data.q $30F6AEC21A4F27E4,$BE42809580313214,$8F24C5E803A2F34C,$48323B2288ECA144,$91411E6513C93486
   Data.q $F00F3EA90D9F7DB8,$D7D7D1F5F5F47CF9,$C42E170B21616147,$C64E9D39819F9264,$A0484D2D2D28C6C6
   Data.q $6EDD89D3A717AF5E,$BCDE63567B3B3B27,$35F8FAFAFA801379,$C347FA2A996D6B99,$2683CF2CC4299148
   Data.q $78B2338C58A70184,$DD7A4828AC328CC6,$CC0C7E31AB305CA3,$979794E5E5E53366,$CCCCDABB45E6D8CF
   Data.q $42F1EB3E5F2F964C,$CA6C9139C24010A1,$F89E9934A331ACCA,$47BF3EAA5D3126F7,$9DDA06C5B580AD90
   Data.q $F0D9AD18BD53943E,$733468D03A5BE303,$C8C8C49248A5E12D,$997CFCFC9AB56A08,$B362E4703E02B64D
   Data.q $BCF77498F84C89A8,$449248093CE8F1FA,$5EBD1FBF7E3F7F7F,$80732ECC8949494F,$2A510B9BC7C54336
   Data.q $7846D9DC64E23820,$CF398E7F2C29047C,$3A5EBD78428509CB,$0567F15CB9703A3A,$94B7FA49A605CFD3
   Data.q $F1E4E3393E3E87B6,$E96F6553826D2868,$F5EBD14BC25AE67F,$3A2C482C160E1C38,$E7CC2A7260003A92
   Data.q $306BA7EC7DBE6E2D,$EBD2232D7E17CB80,$2162C5874E9D00EA,$5F84929292872727,$30F49E603A3334FE
   Data.q $7301DE6639D0DFFF,$1FAFF6CEC2017FCC,$4900000000F88BFC,$00826042AE444E45
EndDataSection

DataSection
   Image_OnOffHover:
   Data.q $0A1A0A0D474E5089,$524448490D000000,$2000000060000000,$7DC0ED0000000608,$4942730400000054
   Data.q $64087C0808080854,$5948700900000088,$0D0000D70D000073,$0000789B284201D7,$6F53745845741900
   Data.q $7700657261777466,$63736B6E692E7777,$9B67726F2E657061,$49190D00001A3CEE,$C99AED8168544144
   Data.q $D5EF3FC77E571C6F,$58B9BB237B1BD5D2,$CD2D11A3335928A2,$19A3C898C84296C8,$50201C1CC930305B
   Data.q $BFE4E5B9040C1CE0,$39B729CC72DC8720,$D60E78F020120904,$92C92310D0D8E341,$50C84F24B2306A25
   Data.q $2F649BB24DCA2914,$DD8AFD50E4B5D5D5,$407E83966929ADAD,$FEFABF5555EBABA3,$AB56A89EF7EFEFB6
   Data.q $2082080820908F01,$F4442117BB297E3A,$80A13FEF45FB8EAD,$97E3A2F3CF1F7DF7,$22529741BA4C18CA
   Data.q $115FB8E8B4D34084,$70F3CF0082080A3D,$B438E38DBB76975D,$4BC251EFDF7C6DDB,$861894A5F028B279
   Data.q $EBAE8186189A6981,$0A014884A3D69A68,$B6D89B366871C77C,$635EBF971AC2DCCD,$7EF89B0BAB9956F6
   Data.q $2FF7EFE12969FC00,$19294890F0A7B1FC,$F2BCBDDEEF651D1D,$1659604C4C4C2BCA,$A0947B34D31C78F1
   Data.q $D66F9D7AF5F82F43,$F5F8B95767F0F937,$E52F5F8E8FE02106,$2C2B2B2B3EFBE2D1,$8262626084232F2F
   Data.q $D0072E5C977DDF77,$F7DF0356AD5104A3,$E3FF4E15CB57F023,$343052303DB5692F,$FA1F2026E80CB101
   Data.q $FF55A3BA16E4C7B3,$E5FED913CF63FD35,$54E171EFBA67F5D8,$680820DB84F3E659,$D6D6D675EBD4DBB7
   Data.q $1F07CEBAE89B3668,$624C992050A1407C,$EDFD65744A52269A,$5F67F0F9B6DB1B76,$7A053F21C6A7E086
   Data.q $0504F28684033402,$50090F2E8B1CE8A8,$EBF7CE88C5FFBAC9,$C9DEFB76D813B04C,$085501076BE07264
   Data.q $DD456EF7D1041041,$264C8A54A93EFBE7,$9C6B6B6B2AEAEAC3,$C7AF7BDEF78E773B,$2DCC38E3B1757403
   Data.q $F3F2D0F5EBF171AC,$20E840B741A66053,$0290214838050824,$4BCE83BF84520934,$EC52980EC1F801FA
   Data.q $20FC52B77CFBA028,$C58B1220F8F75E54,$1FBEF9C59FAEBA06,$1B1460CDD2762B7D,$0C7FA62CFDE3A6EC
   Data.q $1F28BCF3C4AFF8C2,$F2C7BBDDEE75EBD4,$41269A61659632F2,$BCB975D700E4EC10,$6E41AF8A01788350
   Data.q $EFF58ECCD069620A,$7CECC0D0C026BC58,$EDA1F3C0022A190C,$1A9256ED410BDB43,$B7003F04F1DEC10F
   Data.q $D8D8C883E35D1F73,$5E79ED5A2BE0C0D2,$D8BA28B58A6351F4,$A894AC037495C54F,$45A69A25291CB144
   Data.q $F9830C31366CD5FF,$93939332E5CA79F9,$7AFD9A3FEEF533D1,$952F021B3C527C33,$27A0865D7C088BE5
   Data.q $846E20349099480C,$86E9A176DE0421E7,$EE33B69251D14B60,$66FAF0FD700ABD78,$12A0303E041E5A1B
   Data.q $C0842F8374E0571E,$1C5D75C7DF7C3CF3,$408DD75C1C71C1C7,$5DC7154007AD34D4,$D34D7C08BCF3C5D7
   Data.q $0C34D3472B76E7A2,$295DF1458B1620C3,$ACACAE5428F5D74B,$B9F7DF00F1E97344,$6A40C5A2A21EB77A
   Data.q $9980EB5B115DF821,$46230E3E41672132,$0C278CA451EE7183,$5CD47DCB2C0A09BE,$8CAB28FF5A17B68D
   Data.q $ABFA7B8241EA558B,$62DFC243EB895C34,$BDBB73CBD5605832,$EC8E2F1E09E3A087,$34DB6D9E58A130AA
   Data.q $8B8B8B0A952A4D9B,$1F18B2CB1F7FBFDC,$F3CF02327272671F,$C35B5B59E7E7E63C,$0E499327DB88BCF3
   Data.q $F3F316D6D6C83C1E,$C763B1C05298D1F3,$C4A521863D72E5C8,$4D4F72E5CA004D34,$0174F9E4324F77A5
   Data.q $B04BAC96848989DF,$FAE38498A0C4C874,$DF7BF2726E2CDE0D,$537CBAEB803850A6,$4C66B92FE2FE732E
   Data.q $7B91F848638DA6B3,$6BB6B64DFB7CBF95,$80FF4DBF2CECE7FC,$7E1FE35DA9DF07B6,$B75665DCFDFE3DFA
   Data.q $4309DB8F78EAD0F6,$6C648AFD657C022F,$4BA5CB3B3B336F6F,$A068D1A058585897,$8F47A38A54A93AEB
   Data.q $6987878629D4EA72,$BEDCC7F1FC7C5AB5,$A41E0F0799E7BB7D,$E1729FA7E9F02850,$3CF030C3319E85C2
   Data.q $43C618634FA7D38F,$4180A3DF81103155,$1C38B901849F8544,$BFA63163DBF87796,$F56AC8BB3EE726F3
   Data.q $CFDB5ECFE7C2E8B7,$E79F9FB10EF57F07,$9A7EF249A688BC46,$3DF5E59B364B366C,$8902CDB1D7B7342B
   Data.q $0C1A662193264056,$E78843FF0ED360C5,$2EBAEF15544AA7A7,$FA3E15CAE5736DB6,$1C8E472AD5AA23E8
   Data.q $6F370E38E1CB9721,$3CF3C33ECFB3E4DE,$1A34DB6D83399CCE,$409C4E2716AD5A0D,$A8F1E3C4108475D7
   Data.q $221D0E8736DB604B,$3D2A54A9E147CF9F,$22100A40CB762C35,$F06287FB13A300F4,$FF36FBBE4722D8FD
   Data.q $A7628FF4BE73EE7D,$2C502E57CA1268B2,$FE76B04F0FC9F964,$F5D0F59037B1FC4B,$C1BCCF9FCF33BABE
   Data.q $C8C7E14687FFCFE2,$3E1EB8849AF9F08D,$ECD375F65B178A5F,$5F59D7EBF5C1A346,$79DE77866666675F
   Data.q $3E7C9F7DF0B2CB07,$1CDCDCC27C9F27CF,$1E462C58A3EDF6FB,$16269E9E99162C54,$66CFEC4F7AEBA18B
   Data.q $C52A548A753A9CB3,$D983A64C9910D0D0,$2A27D56570F16F60,$EB2320D31410A910,$AAF73EFBE1CF1FEC
   Data.q $0DAA86D54B32DB3E,$D0C57DCF2E09DCE5,$061DCCA4EA2910D0,$37DE1D34587AED74,$959893B31F7390C2
   Data.q $4DD2BCFABA2EB572,$9696152A54079537,$92F77BBD9D75D096,$C59658E3C788A54A,$7B61ECF67B34F4F4
   Data.q $E9C71C75F5F59B7B,$127E3FEA13375679,$0108821E0C9A7A93,$F294F60DDD2425D2,$36CD10DA1A75EBD4
   Data.q $35A8C7AE2C709CD4,$B151D3810CC7C9C2,$CAF172EF9EEC8210,$9C5FF99D789E4E35,$BCF42AD9E88CD027
   Data.q $546B6B6B94A6E968,$A3CF9F22CB2C152A,$E91E79E269A63AEB,$D80410452A549A74,$5C5808209F311DB6
   Data.q $1929487BBDDEE45C,$B81193C9E4E61E1E,$210E773B9CABABAB,$9F7FDFF782448904,$47A4D3CF79193264
   Data.q $99021F1DF8788501,$742D0C8FC2746904,$948FA4E414A50628,$C4048501E8496261,$7C335A059CC410F4
   Data.q $EFBE0FF3AB02148E,$BB407E54B30CCF13,$5D2F6609FED0E6DD,$84EEBD4985A1270D,$CB2D889E0CEEA8E1
   Data.q $778F8A996579E47A,$AEBA54EA8E054527,$4A973AA140EFAE8B,$8E9D3A6F7472E5CA,$6AD5A55AB5401298
   Data.q $249885CB97208421,$1294827915965812,$780AC9E30C3071C7,$96589DEDC841F89A,$1623ED4FF679B5D5
   Data.q $0C0294C261EB8834,$5EDC840526428B77,$F8D886D9B2943BBA,$EA747E15F5F85C1B,$BB682F79FE7F9F24
   Data.q $4647054FD200CC99,$D665CB94D3A74846,$F97BE1DBB769D7D7,$34152A541B1B1B3E,$42130A444891234D
   Data.q $8C3E1F0E71F8FC70,$F88A9E8912245965,$6C6C60393DC3E1F0,$E6A780F10615AA2C,$683DB7E05680D500
   Data.q $608423AFEF1621C8,$20C50CAAF0901934,$FBFC732E37E4066D,$27C76C3BABE6FCD3,$AA81CD7258ED6AD9
   Data.q $E75EBD4066EEE29F,$97411FF875FECE6F,$B774927E0AA2EFC5,$9898E5CB95915406,$D89696965D75C098
   Data.q $3AF5EA6DB6C2DADA,$A9997979655EAF57,$E2D3D0381C0E29A9,$C7C631B1B18B2CB0,$C8F1E3C40A1429C7
   Data.q $2626254A9494A403,$458B162098989826,$5EA807903220DCC5,$7704B56EB153BB4D,$B78BF897778B2CDC
   Data.q $EDBEB05FB3A7C07F,$10463E9E6F043710,$19D2F5816E6AFC04,$816EDD10754CF868,$EAFFCE0DE86B035D
   Data.q $6B15080A733D3F22,$CCEFFF822F115A77,$952A49A69A39277B,$716EB75B9A7A7A62,$6CD93AF5EA25D2E9
   Data.q $31379BCDC6AD5A96,$C7C7C669E9E9934D,$511861A2523B6DB1,$494A5CACAFD656C2,$C78F124C99269D3A
   Data.q $565612685E5E167B,$7F9D7C977E002A1A,$1E8E05856BC4BD9B,$C9B9B9B1CB9F229A,$E635BBF5CBFF5B8D
   Data.q $5BA53B0B55A43F53,$EB61B01E0FAB36CE,$6218D062D0C1B754,$8D9B2C854A39CBEC,$8D7DB82E5A025B16
   Data.q $8DB2557F1511E7BC,$BB769A7D3E9CE3C7,$E45C5C58371B8DCD,$1C0E0912245BADD6,$ADEB78472391C038
   Data.q $22462C589D75D0B7,$49C78F134E9D2091,$D3A667A8579152A5,$48924C9920C30C69,$26107FACAA9A2224
   Data.q $A9B6DB03D7D7D624,$F9E35FA7FE9C2A54,$202C9918FD6FF101,$4A7CE9D0684204CC,$58C816A754DB2611
   Data.q $E430DFDBA4EAD390,$EA518CB66913506F,$0C0168B43B468862,$BDCC366C0B13EFB5,$EDD20D2C126868B8
   Data.q $B728472AA6CF0807,$791AA13CC2B66C13,$763D2E663FE0E883,$8D1A80F55B7D7BAC,$1E0D8D8D9366CD06
   Data.q $6464665CB940783C,$860C993251D1D184,$FF73EFBE1A69A061,$535353068D1A7DFE,$438E3A8928C99324
   Data.q $B1B19979796152A5,$4AA70EA387878631,$6DB63EFBE49FAADE,$817C5F17C9B9B9B3,$E5CB92CF67B39294
   Data.q $AF296500F42B2CB0,$D7811ADDFAE492BD,$8225B4EB15D3BF02,$C20BC035078E200E,$214DA6249E96D9C6
   Data.q $E3BCF0ECA61854E5,$008431886C00D786,$CA1298042B0219BF,$7768D0DBB40044B2,$2A2BCF3BC9DFC03C
   Data.q $86F28F9D4FAB4484,$4A84F2AB5D14A952,$F6AFABEAF3EFBEBE,$91919F7D56CB298C,$ABB7F5C5294D8891
   Data.q $10A1428AEAA21D55,$1A69AF815D0023B1,$DF86B77EB867F627,$1023178439E322A8,$4138013112888112
   Data.q $69DEA7A90DC71FA8,$277F3C4218410737,$B00ED09C3A2AAAA9,$C9DBD7002F79D75A,$4559C4833F09BB01
   Data.q $C30C43168B4D353B,$5445FD7814A229E8,$EAB5D41BBB3D0410,$D398BDD0F1D9E818,$474600356AD7855D
   Data.q $EBA01E4449767B47,$CB8BAFF9640FC73A,$96E88B3691FFF668,$D8062C3D4841348E,$806EA852110B4B69
   Data.q $8C6A8ECB7D3EC815,$C0609EEA035D73BE,$DD269F197544A3D0,$BFD907BF54CB2A80,$C5B8F350BDD63DD3
   Data.q $9728F3CF02B5EE9C,$D458D8D8CEBAE8CB,$6F934D300F2E8257,$716E61993A39644F,$42DFA3E21DEAE693
   Data.q $9516A42266845DF3,$7BB85E93D49A22AA,$6EF13ADC7F9F0FF2,$DFDAF81CD9B34F43,$6FCB29E56E9AB6F7
   Data.q $3468D22E2E2C9B36,$90A8C58B148B1628,$59692E500A844213,$AFF77F00E4FE1F16,$AC559B709636B473
   Data.q $08623087227A24C2,$0FE44C47F94588F1,$EE99EB6B6B6571B9,$927CC5D37632947B,$CACACDBDBDBF98A8
   Data.q $B2C199999EF2D44A,$D06AD5AA217C9EAC,$7F9FE4D95CA52DBF,$FB97B67DDC6E3BF1,$FC925F4FBDD9CA43
   Data.q $8666666458B14B63,$0051E888ED1B366C,$BF2AE5EDD6637A3C,$56AF93716D72AC59,$DDE3777BF07EF81A
   Data.q $E7C83E54029A9FCA,$C512A54A254A94F3,$E6F744B31BB1F162,$D33C8C5F135B97DC,$7AAA48A2A37544D6
   Data.q $9B5CF2777739B97C,$978F0AA3EA8DD573,$1FFF6F420C9B3FA0,$B225CC61CDD9CE79,$444E454900000000
   Data.q $00000000826042AE
EndDataSection

DataSection
   Image_OnOffButton:
   Data.q $0A1A0A0D474E5089,$524448490D000000,$2000000060000000,$7DC0ED0000000608,$4942730400000054
   Data.q $64087C0808080854,$5948700900000088,$0D0000D70D000073,$0000789B284201D7,$6F53745845741900
   Data.q $7700657261777466,$63736B6E692E7777,$9B67726F2E657061,$49670200001A3CEE,$B19AED8168544144
   Data.q $9C5B7F860040D36E,$843395C58222451B,$194504BCB462158E,$64D3CCEA453215E1,$2C0331805794CA46
   Data.q $82C273878ECA4651,$7019B2D9F62F767B,$D367C8D2E0A4C6A5,$BBA4FB97CB3B36FB,$8790A1CF3CB4EEB3
   Data.q $E64802A3B1E05B2E,$49E78B162C3F5DC9,$9C01B000E003BC92,$00D600B63F7566D6,$21F93264D9908456
   Data.q $F980D687683EE85B,$FA00F7B4D346FE7C,$C5F9E79A083D2BF5,$BF2AA45B28FD3A74,$86180003FF062805
   Data.q $A0D6596E1C71D5F1,$E702FF0C529AEDDB,$EAB56AEE79E7BBFC,$6FE79E40025E210A,$7CED31402F6112DB
   Data.q $E3C69F060C1FD001,$24638E2D228A30F1,$401E99E4CB2C8249,$82727270421075D7,$AECFCB972F93A74E
   Data.q $DAAF21094006BEEB,$DF9CC5C22DED1D30,$7D0D1A3472E30C37,$71B8E3886318D7DF,$638E219659000F83
   Data.q $8D1A36BEFBE0C630,$FF17E8025C618686,$D8000E417794F1A5,$121084D318CD7DB6,$9A631804210DFE94
   Data.q $50AA472BC5D7DB6D,$F34D30006C01CA45,$A60210837F834DBC,$8A9954B68F179E69,$27A21080029C0394
   Data.q $B6EA6F72DC28E5C1,$D69A69621F838F79,$80307EE6DA3471ED,$EDEE6DB903F7B7AE,$02A32401510FFDB2
   Data.q $19200A8C90054648,$87D464802A324015,$6EA8A288060E6498,$2D8072F736D1A38F,$B8955ED6BB76EC00
   Data.q $807291522A95BEE5,$25CE73E861840035,$F430C239CE0C3CE8,$03948A9954B5C78B,$4529457A528000AC
   Data.q $A5052941CE70229B,$91542A92B578AAF4,$041A0019908400BD,$9B175D75C21099C1,$4B717236186106CD
   Data.q $C0D9B362186114D3,$CE0820DC21085D75,$0AAFDB267248EBF0,$2CDF7AF5EF943C7F,$4924D3D965967ACB
   Data.q $AEBA64842565B91A,$4017B18CF9E79E07,$EA52D7506FE50F8B,$8BAACC5D400060E3,$FAF391A1EA28033B
   Data.q $994F4FCC90054263,$0000E194DB0C8231,$42AE444E45490000,$0000000000008260
EndDataSection

DataSection
   Image_OnOffDisabled:
   Data.q $0A1A0A0D474E5089,$524448490D000000,$2000000060000000,$7DC0ED0000000608,$4752730100000054
   Data.q $0000E91CCEAE0042,$FF0044474B620600,$93A7BDA0FF00FF00,$7359487009000000,$D70D0000D70D0000
   Data.q $000000789B284201,$0ADD07454D497407,$C31B313E390F170B,$5441444917060000,$4D126FDB5AEDDE68
   Data.q $2DA5CBA077B33D1C,$6C69AC50D5B40ADB,$D5F5D7FD18D83EA3,$24404ADA897886B7,$5ECCBB02EC2812D8
   Data.q $2F682C293B2F87BF,$813B2D4F38FD149F,$7A4B3339CE5DF999,$72DC0CEE25805EBD,$F598435FF801960B
   Data.q $5C5C55AB545D75C0,$90B596580C30C05C,$492F390BB366C80B,$82B2B2B024489092,$E3A9F9E781EEF77B
   Data.q $9728DBB7680E34C8,$516833E1734D30CB,$2C58A32CB2197003,$76ED003AFD4A9522,$E0041045BEDF6F1B
   Data.q $7079E78124921E79,$90B0A142AB7662DC,$34C0E38E1F7DF2F3,$DFDFD8000BAEB84D,$72E53B6C9B81048F
   Data.q $E3C4249240104119,$D0BF9BB0B8A28871,$74E919659071CAE4,$54A950001C78F11A,$55AB5400ECDE79E0
   Data.q $32CB21E79E09A698,$210825BC9DCB2108,$5294010410E3C788,$861B093663F1F8FC,$81623FC51443C8C1
   Data.q $49253CC47F2B2B2B,$2BB3DB6D85DBB742,$5EC64CC003EFDFA0,$27D737F8537216E2,$D623468C0558E4D5
   Data.q $380FD9E79E03AEBF,$08286523F7DF038E,$7145133C8BCF3C02,$5C5C52941BBFE7EA,$64451442EDDBA05C
   Data.q $DDB58DADADAC1932,$E4C91060C18DBB76,$B56AD0B2CB072E5C,$DCB9733AD8C10410,$5738E3B52611EED4
   Data.q $5F588A28815701F3,$83162C479F3E475F,$0D5AB5134D30FBEF,$283264CD4DB3AEBA,$2F97CBE294A04A95
   Data.q $4F2793C145140B2C,$B9BD7AF467F3F9F0,$A82A54A804107C6C,$871C70DBB7682A54,$01C1C1C050A16611
   Data.q $F1F1C5D75C24C992,$9A6AF64456AD5A31,$24E4E4E3DFEFF786,$8B1628474747BC42,$DDDDFAC9576237B7
   Data.q $15FAFD7C59B3645D,$050A14108410E1C3,$E80F87C3E21E1E1C,$45028A2B074C3A74,$C7D7AF5166CD9051
   Data.q $C75EBD56553CF234,$9F3E42CB2C31F1F1,$66CD071C70AAAA87,$2F008208A7A7A713,$DC5D75D23264BE5F
   Data.q $3D0AA878559F7FBF,$1CDCDCD8BAEB83CF,$4004B7FF5A69A1E3,$3E9F4F869A685555,$F4FA789A6989658D
   Data.q $233EFDFA12A54A29,$9D8E7E7E7134D31D,$C3870C1D3A741D9D,$69A60D5AB5E6D13B,$05E2F1780783C1E2
   Data.q $0EF77BBC00024924,$A3477FBFDF1972E5,$9A2B6B06C6C6C0D1,$7808A67F7F7F61A6,$A95282CFFCD5EAF5
   Data.q $B6C21DC460208214,$E91CB2C80D1A346D,$13BCDCDCDB04A185,$382EDDBA16596B89,$007CDB06C6C6C38E
   Data.q $94A03264C84A9528,$AFD059FDDEEDDBA2,$797336DB61264C90,$CF3C21FCCCB84193,$5A0ECECEC75EBD43
   Data.q $8306377E908456AD,$5691082084D34C01,$00820CA249C8B611,$78AAAA8F2583468D,$F176EDDE7B39FCFE
   Data.q $8E8E8F96D66BF5FA,$233080166EC58B10,$20210994ACFC89C2,$7B0D6C88C5144084,$775DD0BA1984213A
   Data.q $CB97216D6D6C1D3A,$CDFABFF1B2AD5AA1,$5370A29AABBBC95F,$93BF974D79766543,$BFB3EFDFBE3679E7
   Data.q $D37FEC0820814515,$7BE458B162C05934,$042100575BA129A7,$C71C1A74E900C183,$D3019602083E4D8D
   Data.q $14356AD41C71C3AA,$15AE6DF6FB7C458B,$3060C145142AAAA0,$C18348E763EBAE80,$C10840C9CB890980
   Data.q $963BBBBBB10F87C3,$C67B3D9EA2CF97A4,$800D377218D75EC6,$8C48912084201861,$D1E7CF9114516169
   Data.q $1CC2108006A6B56A,$8F10035CE1E1E1E1,$CE3EFBE1A74E91C7,$1F1F7DF4AB59CFCF,$5F5F58EBAE847E3F
   Data.q $AAAB6E4456D6D6C7,$C0D4F2CB2155550A,$0E637E57237AAAAA,$7B7B1D75D0870E18,$820B2CB0AB56A87B
   Data.q $59CDF59B7B7B6020,$1AE6F6F6F61AEF08,$7670142851E79E00,$12294A0AB56A8676,$26CD9A11A3460489
   Data.q $6C5D2941264C9E7B,$4827272700820E12,$0C58B10D34D0D3A7,$4270662D5AB45294,$F590E1C31B6DB09E
   Data.q $891226CD9A82B0DE,$4C47A3D1F8C95CC4,$319D9D9C1D3A740C,$1F8FC78DBDBDB943,$14FAA6924977B98F
   Data.q $1B9AB5BA49240842,$60000DE6F3780FBB,$348908815AF57575,$3F26638549C982E4,$7DE9B90BA6FE3CBF
   Data.q $0C30C3AEBA14A500,$7B48C993242952A4,$ADADAC52941D75D1,$75D7411A34740845,$49509EAB2BC99324
   Data.q $965900AF4C1C1C1D,$A77657FBEF852941,$7404226367E2CA93,$34D3432CB20CF787,$970B33AF53F69A68
   Data.q $7A4C03DE1055EB65,$2597A9664C926E23,$AC6D064ECDB0876E,$E7875D740C993202,$FEB1179B7F49FF79
   Data.q $9121C71C0B2CB009,$45072E5C80AECC48,$931CD34C2EBAE051,$B6C061861CDC4B97,$326E57E118A2886D
   Data.q $2CB0210812A54A9B,$9FB9EDB6C3AEBA0B,$52941F7DF00DFFD5,$EC564C15DE10A776,$4F4E1EBD7A52D7D4
   Data.q $8A3AE322CD05D94F,$DCB972228A20AEED,$79EA1BBD6646A354,$70C0C30C26CD9A1E,$20025BF9319B9C38
   Data.q $C3162C414514228A,$625ACC5EF5EAEAEA,$FFC00CB3F0BE587E,$E598C8F97600FF1B,$4900000000456325
   Data.q $00826042AE444E45
EndDataSection

EndModule

Procedure.i OnOffButton(Gadget.i, x.i,y.i,width.i,height.i,Flags.i = 0)
;{ ==Procedure Header Comment==============================
;        Name/title: CustomGadget
;       Description: Part of custom gadget template
;                  : Public procedure to add this custom gadget to a window
; ====================================================
;}
  Define ThisGadget.i

  ThisGadget = OnOffButton::CreateGadget(Gadget.i, x.i,y.i,width.i,height.i,Flags.i)

  ProcedureReturn ThisGadget

EndProcedure

Procedure.i GetOnOffButtonState(Gadget.i)

  ProcedureReturn OnOffButton::GetState(Gadget)

EndProcedure

Procedure.i SetOnOffButtonState(Gadget.i,State)

  OnOffButton::SetState(Gadget,State)

EndProcedure
; IDE Options = PureBasic 5.50 (Windows - x64)
; CursorPosition = 77
; FirstLine = 69
; Folding = 8JJCF-
; EnableXP