function mygui_replayer_callback_mdefutinitbutton( hObject , eventdata , handles )
    variablenotused(hObject);
    variablenotused(eventdata);

    global MDEFUT_INSTANCE;
    global STRAT_INSTANCE;
    global OPS_INSTANCE;

    %get the replay speed
    replayspeedcell = get(handles.generalsetup.replayspeed_popupmenu,'string');
    idx = get(handles.generalsetup.replayspeed_popupmenu,'value');
    replayspeedval = str2double(replayspeedcell{idx});
    MDEFUT_INSTANCE.settimerinterval(0.5/replayspeedval);
    OPS_INSTANCE.settimerinterval(1/replayspeedval);
    
    %get startup fund
    startupfund = get(handles.generalsetup.startupfund_edit,'string');
    STRAT_INSTANCE.setavailablefund(str2double(startupfund{1}),'firstset',true);
    
    %the strategy
%     stratnamelist = get(handles.generalsetup.strategyname_popupmenu,'string');
%     idx = get(handles.generalsetup.strategyname_popupmenu,'value');
%     stratname = stratnamelist{idx};
%     if strcmpi(stratname,'manual')
%         strat = cStratManual;
%     elseif strcmpi(stratname,'wlpr')
%         strat = cStratFutMultiWR;
%     elseif strcmpi(stratname,'batman')
%         strat = cStratFutMultiBatman;
%     elseif strcmpi(stratname,'wlprbatman')
%         strat = cStratFutMultiWRPlusBatman;
%     else
%         statusstr = 'Error:unknown strategy name...';
%         set(handles.statusbar.statustext,'string',statusstr);
%         return
%     end
    STRAT_INSTANCE.settimerinterval(1/replayspeedval);
    
    %load strategy risk configurations
    configfilename = get(handles.generalsetup.riskconfig_edit,'string');
    STRAT_INSTANCE.loadriskcontrolconfigfromfile('filename',configfilename{1});
    instruments2trade = STRAT_INSTANCE.getinstruments;
    ninstruments = size(instruments2trade,1);
    
    %load with tick data on specified replay dates
    replay_startdt = get(handles.generalsetup.startdate_edit,'string');
    replay_enddt = get(handles.generalsetup.enddate_edit,'string');
    replay_dates = gendates('fromdate',replay_startdt{1},'todate',replay_enddt{1});
    ndates = size(replay_dates,1);
    
    replay_filenames = cell(ninstruments);
    ctpcodelist = cell(ninstruments,1);
    
    for i = 1:ninstruments
        ctpcodelist{i} = instruments2trade{i}.code_ctp;
        statusstr = ['load tick data of ',ctpcodelist{i},'...'];
        set(handles.statusbar.statustext,'string',statusstr);
        pause(1);     
        files = cell(ndates,1);
        for j = 1:ndates
            files{j,1} = [ctpcodelist{i},'_',datestr(replay_dates(j),'yyyymmdd'),'_tick.txt'];
        end
        replay_filenames{i} = files;
        STRAT_INSTANCE.mde_fut_.initreplayer('code',ctpcodelist{i},'filenames',files);
    end
    
%     STRAT_INSTANCE = strat;
%     STRAT_INSTANCE.gui_ = handles;
    
    %set check box
    list = handles.instruments.instrumentlist;
    for i = 1:size(list,1)
        try
            propname_i = [list{i},'_checkbox'];
            set(handles.instruments.(propname_i),'value',0);
        catch
            fprintf('%s not set to blank...\n',propname_i);
        end
    end
    
    for i = 1:ninstruments
        assetname = instruments2trade{i}.asset_name;
        info = getassetinfo(assetname);
        assetnamemap = info.AssetNameMap;
        propname = [assetnamemap,'_checkbox'];
        try
            set(handles.instruments.(propname),'value',1);
        catch
            fprintf('%s not set to use...\n',propname);
        end
    end
        
    %load historical data
    columnnames = {'last trade','bid','ask','update time','last close','change','wlhigh','wllow'};
    data = cell(ninstruments,length(columnnames));

    for i = 1:ninstruments
        %init data
        statusstr = ['load historical candles of ',ctpcodelist{i},'...'];
        set(handles.statusbar.statustext,'string',statusstr);
        pause(1);
        samplefreqstr = STRAT_INSTANCE.riskcontrols_.getconfigvalue('code',ctpcodelist{i},'propname','samplefreq');
        if strcmpi(samplefreqstr(end),'m')
            samplefreqnum = str2double(samplefreqstr(1:end-1));
        elseif strcmpi(samplefreqstr(end),'h')
            samplefreqnum = 60*str2double(samplefreqstr(1:end-1));
        else
            error('mygui_replayer_callback_mdefutinitbutton:invalid sample freq')
        end
        
        if samplefreqnum == 1
            nbdays = 1;
        elseif samplefreqnum == 3
            nbdays = 3;
        elseif samplefreqnum == 5
            nbdays = 5;
        elseif samplefreqnum == 15
            nbdays = 10;
        else
            error('mygui_replayer_callback_mdefutinitbutton:unsupported sample freq:%s',samplefreqstr)
        end
        
        MDEFUT_INSTANCE.initcandles(instruments2trade{i},'NumberofPeriods',nbdays);
        
        try
            numofperiod = STRAT_INSTANCE.riskcontrols_.getconfigvalue('code',ctpcodelist{i},'propname','numofperiod');
        catch
            numofperiod = 144;
        end
        wlprparams = struct('name','WilliamR','values',{{'numofperiods',numofperiod}});
        MDEFUT_INSTANCE.settechnicalindicator(instruments2trade{i},wlprparams);
        
        wrinfo = MDEFUT_INSTANCE.calc_technical_indicators(instruments2trade{i});
        data{i,1} = 0;
        data{i,2} = 0;
        data{i,3} = 0;
        histcandles = MDEFUT_INSTANCE.gethistcandles(instruments2trade{i});
        data{i,4} = datestr(histcandles{1}(end,1),'dd/mmm HH:MM');
        data{i,5} = num2str(wrinfo{1}(4));
        data{i,5} = 0;
        data{i,7} = num2str(wrinfo{1}(2));
        data{i,8} = num2str(wrinfo{1}(3));
    end

    %set table
    set(handles.mktdatatbl.table,'RowName',ctpcodelist,'Data',data);
    %
    if ninstruments > 0
        set(handles.mktdataplot.popupmenu,'String',ctpcodelist);
    else
        set(handles.mktdataplot.popupmenu,'String',{'none'});
    end
    
    if ninstruments > 0
        set(handles.manualops.instrument_popupmenu,'String',ctpcodelist);
    else
        set(handles.manualops.instrument_popupmenu,'String',{'none'});
    end
    
    set(handles.positions.table,'RowName',ctpcodelist,'Data',num2cell(zeros(length(ctpcodelist),6)));
    
    statusstr = 'market data engine initialized...';
    set(handles.statusbar.statustext,'string',statusstr);
    
    %
    MDEFUT_INSTANCE.gui_ = handles;
    OPS_INSTANCE.gui_ = handles;
    STRAT_INSTANCE.gui_ = handles;
    
end