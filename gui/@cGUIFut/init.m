function obj = init(obj,varargin)
%cGUIFut
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Name','guifut',@ischar);
%     p.addParameter('MDEFut',{},@(x) validateattributes(x,{'cMDEFut','cell'},{},'','MDEFut'));
%     p.addParameter('Handles',{},@(x) validateattributes(x,{'struct','cell'},{},'','Handles'));
    
    p.parse(varargin{:});
    obj.name_ = p.Results.Name;
%     obj.mdefut_ = p.Results.MDEFut;
%     obj.handles = p.Results.Handles;

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
   mdefut.mode_ = mode;
   
   set(handles.mktdataops.mdefutInitButton,'CallBack',{@guicallback_rt_ctp_mdefutinitbutton2, handles});
   set(handles.mktdataops.mdefutStartButton,'CallBack',{@guicallback_mdefutstartbutton2, handles});
   set(handles.mktdataops.mdefutStopButton,'CallBack',{@guicallback_mdefutstopbutton, handles});
   
   obj.mdefut_ = mdefut;
   obj.handles_ = handles;
   
   
end