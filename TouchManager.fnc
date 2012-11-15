
var __X;
var __Y;
var touched;
var file_selected;

func TouchEvent(var x,var y)
     var i;
    __X:=x;
    __Y:=y;

    touched:=img_Touched(hndl,-1);

    if(WINDOW==W_MAIN)  //Window Main TouchEvent
        if(touched==iImage1 || touched==iImage2) //Axis Move
            for(i:=0; i<sizeof(AXIS_MOVE_TOUCH_REGION); i++)
                if( checkRegion( @ AXIS_MOVE_TOUCH_REGION[i] ) ) //Moves the axes depending on the region Touched
                    SerialPrintlnBuffer(AXIS_MOVE_TOUCH_ACTION[i]);
                    if(i==HOMING_ACTION_INDEX)
                        updateMessage("Homing..","","");
                        setTimerMessage(4500);
                    endif
                    pause(50);
                    break;
                endif
            next
        else if(touched==iImage3) //SD Card TouchEvent
            WINDOW:=W_PRINTING_OPTION;
            drawWinPrintingOption();
        else if(touched==iWinbutton1) //Extrude Button
                updateButtonExtrude(ON);
                SerialPrintBuffer("G91\nG1 E");
                SerialPrintNumber(str2w(str_Ptr(ex_setmm)));
                SerialPrintBuffer(" F");
                SerialPrintlnNumber(str2w(str_Ptr(ex_setmm_min)));
                SerialPrintlnBuffer("G90");
                updateMessage("Extrude ",str_Ptr(ex_setmm),"mm of filament..");
                setTimerMessage(3000);
        else if(touched==iWinbutton2) //Reverse Button
                updateButtonReverse(ON);
                SerialPrintBuffer("G91\nG1 E-");
                SerialPrintNumber(str2w(str_Ptr(ex_setmm)));
                SerialPrintBuffer(" F");
                SerialPrintlnNumber(str2w(str_Ptr(ex_setmm_min)));
                SerialPrintlnBuffer("G90");
                updateMessage("Reverse ",str_Ptr(ex_setmm),"mm of filament..");
                setTimerMessage(3000);
        else if(touched==iWinbutton3) //Extruder Off
            updateButtonExOff(ON);
            SerialPrintlnBuffer("M104 S0");
            updateMessage("Heater shutdown","","");
            setTimerMessage(3000);
        else if(touched==iWinbutton4) //Bed Off
            updateButtonBedOff(ON);
            SerialPrintlnBuffer("M140 S0");
            updateMessage("Bed shutdown","","");
            setTimerMessage(3000);
        else if(touched==iWinbutton5) //Extruder Set
            updateButtonExSet(ON);
            SerialPrintBuffer("M104 S");
            SerialPrintlnNumber(str2w(str_Ptr(ex_setTemp)));
            updateMessage("set Heater target to ",str_Ptr(ex_setTemp)," C");
            setTimerMessage(3000);
        else if(touched==iWinbutton6) //Bed Set
            updateButtonBedSet(ON);
            SerialPrintBuffer("M140 S");
            SerialPrintlnNumber(str2w(str_Ptr(bed_setTemp)));
            updateMessage("set Bed target to ",str_Ptr(bed_setTemp)," C");
            setTimerMessage(3000);
        else if(touched==iWinbutton9 || touched==iWinbutton10) //Switch Extruder
            updateButtonSwitchEx(EVENT);
        else  //ALL "Button Set NUMBER"
            for(i:=0; i<sizeof(BUTTON_SET_NUMBER); i++)
                if(checkRegion( @ BUTTON_SET_NUMBER[i]))
                    initTrackbar(i);
                    updateTrackbarStatus(i);
                    initButtonFine();
                    updateButtonFine(FALSE);
                    break;
                endif
            next
        endif

    else if(WINDOW==W_EXTMM || WINDOW==W_EXTMM_MIN || WINDOW==W_EXTTEMP || WINDOW==W_BEDTEMP) //Window Button Set Number TouchEvent
        if(touched==iTrackbar1)
             updateTrackbarEvent(WINDOW,x);
             EN_TOUCH_MOVING:=TRUE;
             //pause(50);
        else if(touched==iWinbutton7) //Fine Plus
            ButtonFinePlusAction();
            pause(70);
        else if(touched==iWinbutton8) //Fine Minus
            ButtonFineMinusAction();
            pause(70);
        else if(!checkRegion( @ TRACKPAD_CONTAINER))
            remove_currentTrackpad();
            EN_TOUCH_MOVING:=FALSE;
            WINDOW:=W_MAIN; //Return to Windows Main
        endif
    else if(WINDOW==W_SDCARD) //Window SDCard Touch event
        if(touched==iWinbutton14 && sd_page_count!=0) //left button
            updateButtonPagesLeft(ON);
            sd_current_page++;
            drawSDScreen();
            updateButtonFileList();
        else if(touched==iWinbutton13 && sd_page_count!=0) //right button
            updateButtonPagesRight(ON);
            sd_current_page--;
            drawSDScreen();
            updateButtonFileList();
        else if(checkRegion( @ WIN_SDCARD_CONTAINER))
            var j;
            var STOP:=FALSE;
            file_selected:=sd_current_page*24;
            for(i:=0; i<8 && STOP==FALSE; i++) // Button files is 8x3 Matrix
                for(j:=0; j<3 && STOP==FALSE; j++)
                    if(file_selected<file_count)
                        if(checkRegion(BUTTON_FILES_X[j],BUTTON_FILES_Y[i],
                                       BUTTON_FILES_X[j]+BUTTON_FILE_WIDTH,BUTTON_FILES_Y[i]+BUTTON_FILE_HEIGHT))
                            WINDOW:=W_PRINT_CONFIRM;
                            //SerialPrintlnBuffer(files[file_selected]); //For DEBUG
                            WinPrintConfirm(file_selected,files[file_selected]);
                            STOP:=TRUE;
                            break;
                        endif
                        file_selected++;
                    endif
                next
            next
        else //Exit SD Card Windows
             switchWinSDtoMain();
        endif
    else if(WINDOW==W_PRINT_CONFIRM)
        if(touched==iWinbutton11) //Yes Confirm
            SerialPrintBuffer("M23 "); // Print file
            SerialPrintlnBuffer(files[file_selected]);
            pause(200);
            updateMessage("Printing file ",files[file_selected],"");
            //setTimerMessage(3000);
            SerialPrintlnBuffer("M24");
            //updateMessage(files[file_selected]);
            switchWinSDtoMain();
        else if(touched==iWinbutton12) //No Confirm
             WINDOW:=W_SDCARD;
             drawSDScreen();
             updateButtonFileList();
        endif
    else if(WINDOW==W_PRINTING_OPTION)
        if(touched==iWinbutton15) //Resume Print Button
             updateResumeButton(ON);
             SerialPrintBuffer("M24\n");
        else if(touched==iWinbutton16) //Pause Button
             updatePauseButton(ON);
             SerialPrintBuffer("M25\n");
        else if(touched==iWinbutton17) //Open File Button
            updateOpenFileButton(ON);
            WINDOW:=W_SDCARD;
            SD_READING:=TRUE;
            SerialPrintBuffer("M21\nM20\n");
            drawSDScreen();
        else if(!checkRegion( @ PRINTING_OPTION_TOUCH_REGION)) //out of Window, return to Main
            WINDOW:=W_MAIN;
            switchWinSDtoMain();
        endif
    endif
endfunc

func TouchReleasedEvent()
       if(touched==iWinbutton1 && WINDOW==W_MAIN) //Extrude Button
            updateButtonExtrude(OFF);
        else if(touched==iWinbutton2 && WINDOW==W_MAIN) //Reverse Button
            updateButtonReverse(OFF);
        else if(touched==iWinbutton3 && WINDOW==W_MAIN) //Extruder Off
            updateButtonExOff(OFF);
        else if(touched==iWinbutton4 && WINDOW==W_MAIN) //Bed Off
            updateButtonBedOff(OFF);
        else if(touched==iWinbutton5 && WINDOW==W_MAIN) //Extruder Set
            updateButtonExSet(OFF);
        else if(touched==iWinbutton6 && WINDOW==W_MAIN) //Bed Set
            updateButtonBedSet(OFF);
        else if(touched==iWinbutton15 && WINDOW==W_PRINTING_OPTION) //Resume Print
            updateResumeButton(OFF);
        else if(touched==iWinbutton16 && WINDOW==W_PRINTING_OPTION) //Pause
            updatePauseButton(OFF);
        else if(touched==iWinbutton6 && WINDOW==W_PRINTING_OPTION) //Open File
            updateOpenFileButton(OFF);
//        else if(touched==iWinbutton13) //Pages Left
//             updateButtonPagesLeft(OFF);
//        else if(touched==iWinbutton14) //Pages Right
//             updateButtonPagesRight(OFF);
        endif
endfunc

func checkRegion(var p1x,var p1y ,var p2x,var p2y)
    var ret := FALSE;
    if( __X >= p1x && __X <= p2x && __Y >= p1y && __Y <= p2y)
        ret := TRUE;
    endif
    return ret;
endfunc
