function [ handles,mdefut ] = guientry_mde_ctp
    %
    global MDEFUT_INSTANCE;
    
    ui = struct('guiW',1728,'guiH',972,'guiX',10,'guiY',41,...
        'guiColor',[0.85 0.85 0.85],...
        'guiName','CTP MDEFUT',...
        'panel2LeftFrame',0.01,...     
        'panel2RightFrame',0.01,...
        'panel2TopFrame',0.02,...
        'panel2BottomFrame',0.02,...
        'panel2panelH',0.01,...
        'panel2panelV',0.01,...
        'panelFontSize', 9,...
        'topLeftBlockW',0.18,...
        'topPanelH1',0.15,...
        'topPanelH2',0.05);
   % 
   handles = gui_frame_mdefut_entry(ui);
   
   vals = get(handles.generalsetup.mode_popupmenu,'string');
   idx = get(handles.generalsetup.mode_popupmenu,'value');
   mode = vals{idx};
   
   mdefut = cMDEFut;
   MDEFUT_INSTANCE = mdefut;
   MDEFUT_INSTANCE.mode_ = mode;
   MDEFUT_INSTANCE.gui_ = handles;
   
   set(handles.mktdataops.mdefutInitButton,'CallBack',{@guicallback_rt_ctp_mdefutinitbutton2, handles});
   set(handles.mktdataops.mdefutStartButton,'CallBack',{@guicallback_mdefutstartbutton2, handles});
   set(handles.mktdataops.mdefutStopButton,'CallBack',{@guicallback_mdefutstopbutton, handles})