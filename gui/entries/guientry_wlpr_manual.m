function [ handles,mdefut,strat,ops ] = guientry_wlpr_manual
 %
    global MDEFUT_INSTANCE;
    global STRAT_INSTANCE;
    global OPS_INSTANCE;
    
    ui_frame = struct('guiW',1920,'guiH',1017,'guiX',1,'guiY',41,...
    'guiColor',[0.85 0.85 0.85],...
    'guiName','CTP Futures Trading',...
    'panel2LeftFrame',0.01,...     
    'panel2RightFrame',0.01,...
    'panel2TopFrame',0.02,...
    'panel2BottomFrame',0.02,...
    'panel2panelH',0.01,...
    'panel2panelV',0.01,...
    'panelFontSize', 9,...
    'leftBlockW',0.14,...
    'middleBlockW',0.46,...
    'leftPanel1H',0.2,...;
    'leftPanel2H',0.45,...;
    'middlePanel1H',0.4,...
    'middlePanel2H',0.08,...
    'statusbarPanelH',0.04);
    
    handles = gui_frame_entry(ui_frame);
    
    mdefut = cMDEFut;
    MDEFUT_INSTANCE = mdefut;
    MDEFUT_INSTANCE.mode_ = 'realtime';
    MDEFUT_INSTANCE.gui_ = handles;
    %
    ops = cOps('Name','ops-wlpr');
    ops.registermdefut(mdefut);
    OPS_INSTANCE = ops;
    OPS_INSTANCE.mode_ = 'realtime';
    OPS_INSTANCE.gui_ = handles;
    %
    strat = cStratFutMultiWR;
    STRAT_INSTANCE = strat;
    STRAT_INSTANCE.mode_ = 'realtime';
    STRAT_INSTANCE.registermdefut(MDEFUT_INSTANCE);
%     STRAT_INSTANCE.registerhelper(OPS_INSTANCE);
    STRAT_INSTANCE.gui_ = handles;
    
     MDEFUT_INSTANCE.settimerinterval(0.5);
     OPS_INSTANCE.settimerinterval(1);
     STRAT_INSTANCE.settimerinterval(1);
        
    set(handles.mktdataops.mdefutInitButton,'CallBack',{@guicallback_mdefutinitbutton, handles});
    set(handles.mktdataops.mdefutStartButton,'CallBack',{@guicallback_mdefutstartbutton, handles});
    set(handles.mktdataops.mdefutStopButton,'CallBack',{@guicallback_mdefutstopbutton, handles});
    set(handles.mktdataops.mdefutPlotButton,'CallBack',{@guicallback_mdefutplotbutton, handles});
    set(handles.manualops.placeorderbutton,'CallBack',{@guicallback_placeorderbutton, handles});
    set(handles.manualops.cancelorderbutton,'CallBack',{@guicallback_cancelorderbutton, handles});
end