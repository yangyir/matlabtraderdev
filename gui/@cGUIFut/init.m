function obj = init(obj,varargin)
%cGUIFut
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('FileName','',@ischar);    
    p.parse(varargin{:});
    filename = p.Results.FileName;
    if isempty(filename)
        error('cGUIFut:init:empty filename input')
    end
    
    defaultprops = struct('name','guifut',...
        'countername','ccb_ly_fut',...
        'configfilename','config_gui_mdefut_config1.txt',...
        'mode','realtime',...
        'replaydatefrom','yyyy-mm-dd',...
        'replaydateto','yyyy-mm-dd');
    
    name = defaultprops.name;
    countername = defaultprops.countername;
    configfilename = defaultprops.configfilename;
    mode = defaultprops.mode;
    replaydatefromstr = defaultprops.replaydatefrom;
    replaydatetostr = defaultprops.replaydateto;
    
    [propnames,propvalues] = getpropnamevaluefromfile(filename);
    nprop = size(propnames,1);
    for i = 1:nprop
        if strcmpi(propnames{i},'name')
            name = propvalues{i};
        elseif strcmpi(propnames{i},'countername')
            countername = propvalues{i};
        elseif strcmpi(propnames{i},'configfilename')
            configfilename = propvalues{i};
        elseif strcmpi(propnames{i},'mode')
            mode = propvalues{i};
        elseif strcmpi(propnames{i},'replaydatefrom')
            replaydatefromstr = propvalues{i};
        elseif strcmpi(propnames{i},'replaydateto')
            replaydatetostr = propvalues{i};
        end
    end
    obj.name_ = name;
    obj.countername_ = countername;
    
    %instruments
    code = cell(100,1);
    samplefreq = zeros(100,1);
    wrnperiod = zeros(100,1);
    macdlead = zeros(100,1);
    macdlag = zeros(100,1);
    macdnavg = zeros(100,1);
    tdsqlag = zeros(100,1);
    tdsqconsecutive = zeros(100,1);
    
    fid = fopen(filename,'r');
    tline = fgetl(fid);
    while ischar(tline)
        lineinfo = regexp(tline,'\t','split');
        if strcmpi(lineinfo{1},'code')
            n = size(lineinfo,2)-1;
            for i = 2:size(lineinfo,2), code{i-1} = lineinfo{i};end
        elseif strcmpi(lineinfo{1},'samplefreq')
            for i = 2:size(lineinfo,2), samplefreq(i-1) = str2double(lineinfo{i}(1:end-1));end
        elseif strcmpi(lineinfo{1},'wrnperiod')
            for i = 2:size(lineinfo,2), wrnperiod(i-1) = str2double(lineinfo{i});end
        elseif strcmpi(lineinfo{1},'macdlead')
            for i = 2:size(lineinfo,2), macdlead(i-1) = str2double(lineinfo{i});end
        elseif strcmpi(lineinfo{1},'macdlag')
            for i = 2:size(lineinfo,2), macdlag(i-1) = str2double(lineinfo{i});end
        elseif strcmpi(lineinfo{1},'macdnavg')
            for i = 2:size(lineinfo,2), macdnavg(i-1) = str2double(lineinfo{i});end
        elseif strcmpi(lineinfo{1},'tdsqlag')
            for i = 2:size(lineinfo,2), tdsqlag(i-1) = str2double(lineinfo{i});end
        elseif strcmpi(lineinfo{1},'tdsqconsecutive')
            for i = 2:size(lineinfo,2), tdsqconsecutive(i-1) = str2double(lineinfo{i});end
        end
        tline = fgetl(fid);
    end
    code = code(1:n);
    samplefreq = samplefreq(1:n);
    wrnperiod = wrnperiod(1:n);
    macdlead = macdlead(1:n);
    macdlag = macdlag(1:n);
    macdnavg = macdnavg(1:n);
    tdsqlag = tdsqlag(1:n);
    tdsqconsecutive = tdsqconsecutive(1:n);
    
    mdefut = cMDEFut;
    mdefut.mode_ = mode;
    for i = 1:n
        mdefut.registerinstrument(code{i});
        mdefut.setcandlefreq(samplefreq(i),code{i});
        mdefut.wrnperiod_(i) = wrnperiod(i);
        mdefut.macdlead_(i) = macdlead(i);
        mdefut.macdlag_(i) = macdlag(i);
        mdefut.macdavg_(i) = macdnavg(i);
        mdefut.tdsqlag_(i) = tdsqlag(i);
        mdefut.tdsqconsecutive_(i) = tdsqconsecutive(i);
    end
    %init historical data
    instruments2trade = mdefut.qms_.instruments_.getinstrument;
    for i = 1:n
        if samplefreq(i) == 1
            nbdays = 1;
        elseif samplefreq(i) == 3
            nbdays = 3;
        elseif samplefreq(i) == 5
            nbdays = 5;            
        elseif samplefreq(i) == 15
            nbdays = 10;
        else
            error('cGUIFut:init:unsupported sample freq:%s',num2str(samplefreq(i)))
        end
        fprintf('init historical data of %s...\n',code{i});
        mdefut.initcandles(instruments2trade{i},'NumberofPeriods',nbdays);
    end
    
    fclose(fid);
 
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
        'topPanelH1',0.18,...
        'topPanelH2',0);
   % 
   %frame
   handles = gui_frame_md_init(ui);
   
   %generalsetup
   generalsetup_propnames = {'CounterName';'RiskConfigFile';...
       'Mode';'ReplayTimeStart';'ReplayTimeEnd'};
   generalsetup_propvalues = {countername;configfilename;...
       mode;replaydatefromstr;replaydatetostr};
   handles = gui_frame_generalsetup(handles,ui,generalsetup_propnames,generalsetup_propvalues);
   
   %mktdatatbl
   handles = gui_frame_mktdatatbl(handles,ui,'code',code);
   columnnames = get(handles.mktdatatbl.table,'columnname');
   data = cell(n,length(columnnames));
   for i = 1:n
        dailydata = cDataFileIO.loadDataFromTxtFile([instruments2trade{i}.code_ctp,'_daily.txt']);
        if strcmpi(mode,'realtime')
            lastbd = getlastbusinessdate;
        else
            replaystartdtnum = datenum(replaystartdtstr,'yyyy-mm-dd');
            lastbd = businessdate(replaystartdtnum,-1);
        end
        idx = dailydata(:,1) == lastbd;
        try
            lastcloseprice = dailydata(idx,5);
        catch
            lastcloseprice = NaN;
        end
                
        wrinfo = mdefut.calc_wr_(instruments2trade{i},'IncludeLastCandle',1);
        [macdvec,sigvec] = mdefut.calc_macd_(instruments2trade{i},'IncludeLastCandle',1);
        [bs,ss,levelup,leveldn] = mdefut.calc_tdsq_(instruments2trade{i},'IncludeLastCandle',1);
        
        data{i,1} = num2str(lastcloseprice);
        data{i,2} = num2str(lastcloseprice);
        data{i,3} = num2str(lastcloseprice);
        
        if size(instruments2trade{i}.break_interval,1) > 2
            data{i,4} = datestr([datestr(lastbd,'yyyy-mm-dd'),' ',instruments2trade{i}.break_interval{3,end}],'dd/mmm HH:MM:SS');
        else
            data{i,4} = datestr([datestr(lastbd,'yyyy-mm-dd'),' ',instruments2trade{i}.break_interval{2,end}],'dd/mmm HH:MM:SS');
        end
        data{i,5} = num2str(lastcloseprice);
        data{i,6} = sprintf('%3.1f%%',0);
        data{i,7} = sprintf('%3.1f',wrinfo(1));
        data{i,8} = num2str(wrinfo(2));
        data{i,9} = num2str(wrinfo(3));
        data{i,10} = num2str(bs(end));
        data{i,11} = num2str(ss(end));
        data{i,12} = num2str(levelup(end));
        data{i,13} = num2str(leveldn(end));
        data{i,14} = sprintf('%3.3f',macdvec(end));
        data{i,15} = sprintf('%3.3f',sigvec(end));
   end
   set(handles.mktdatatbl.table,'RowName',code,'Data',data,'ColumnName',columnnames); 
   %mktdataplot
   handles = gui_frame_mktdataplot(handles,ui);
   set(handles.mktdataplot.popupmenu,'String',code);
   %    
   obj.mdefut_ = mdefut;
   obj.handles_ = handles;
   
   
end