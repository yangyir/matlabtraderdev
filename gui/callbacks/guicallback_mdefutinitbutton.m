function guicallback_mdefutinitbutton( hObject , eventdata , handles )
    variablenotused(hObject);
    variablenotused(eventdata);

    global MDEFUT_INSTANCE;
    global STRAT_INSTANCE;
    global OPS_INSTANCE;

    counterlist = get(handles.generalsetup.countername_popupmenu,'string');
    counteridx = get(handles.generalsetup.countername_popupmenu,'value');
    countername = counterlist{counteridx};
    counter = CounterCTP.(countername);    
    if strcmpi(countername,'citic_kim_fut')
        counternameshort = 'citickim';
    elseif strcmpi(countername,'ccb_ly_fut')
        counternameshort = 'ccbly';
    elseif strcmpi(countername,'ccb_yy_fut')
        counternameshort = 'ccbyy';
    elseif strcmpi(countername,'dh_professorWan_fut')
        counternameshort = 'dhpw';
    end
    
    classname = class(STRAT_INSTANCE);
    %note:20180218
    %we now only work with cStratFutMultiWR
    if strcmpi(classname,'cStratFutMultiWR')
        bookname = [counternameshort,'-wlpr'];
        tradername = 'trader-wlpr';
    else
        error('%s is not a supportive strategy name')
    end
    trader = cTrader;
    trader.init(tradername);
        
    book = cBook('BookName',bookname,'TraderName',trader.name_,'CounterName',countername);
    trader.addbook(book);
    OPS_INSTANCE.registerbook(book);
    OPS_INSTANCE.registercounter(counter);
    STRAT_INSTANCE.registerhelper(OPS_INSTANCE);
    
    %the strategy
    %get startup fund
    startupfund = get(handles.generalsetup.startupfund_edit,'string');
    ret = STRAT_INSTANCE.setavailablefund(str2double(startupfund{1}),'firstset',true,...
        'checkavailablefund',false);
    if ~ret
        statusstr = 'Error:startup fund set failed...';
        set(handles.statusbar.statustext,'string',statusstr);
        return
    end
    
    %load strategy risk configurations
    configfilename = get(handles.generalsetup.riskconfigfile_edit,'string');
    STRAT_INSTANCE.loadriskcontrolconfigfromfile('filename',configfilename{1});
    instruments2trade = STRAT_INSTANCE.getinstruments;
    ninstruments = size(instruments2trade,1);
    ctpcodelist = cell(ninstruments,1);
    
    replaydt1str = get(handles.generalsetup.replaytimestart_edit,'string');
    replaydt2str = get(handles.generalsetup.replaytimeend_edit,'string');
    try
        replaydts = gendates('fromdate',replaydt1str{1},'todate',replaydt2str{1});
        isreplay = 1;
    catch
        isreplay = 0;
    end
    if isreplay
        MDEFUT_INSTANCE.mode_ = 'replay';
        OPS_INSTANCE.mode_ = 'replay';
        STRAT_INSTANCE.mode_ = 'replay';
        try
            for i = 1:ninstruments
                code = instruments2trade{i}.code_ctp;
                filenames = cell(size(replaydts,1),1);
                for j = 1:size(replaydts,1)
                    filenames{j} = [code,'_',datestr(replaydts(j),'yyyymmdd'),'_tick.txt'];
                end
                MDEFUT_INSTANCE.initreplayer('code',code,'filenames',filenames);
            end
        catch err
            fprintf('Error:%s\n',err.message);
        end
    end
    
    %set check box
    list = handles.instruments.instrumentlist;
    for i = 1:size(list,1)
        try
            propname_i = [lower(list{i}),'_checkbox'];
            set(handles.instruments.(propname_i),'value',0);
        catch
            fprintf('%s not set to blank...\n',propname_i);
        end
    end
    
    for i = 1:ninstruments
        assetname = instruments2trade{i}.asset_name;
        info = getassetinfo(assetname);
        assetnamemap = info.AssetNameMap;
        propname = [lower(assetnamemap),'_checkbox'];
        try
            set(handles.instruments.(propname),'value',1);
        catch
            fprintf('%s not set to use...\n',propname);
        end
    end
    
    usehistlist = get(handles.generalsetup.usehistdata_popupmenu,'string');
    usehistidx = get(handles.generalsetup.usehistdata_popupmenu,'value');
    usehiststr = usehistlist{usehistidx};
    
    if strcmpi(usehiststr,'yes')
        useflag = 1;
    else
        useflag = 0;
    end
        
    %load historical data
    if useflag
        columnnames = {'last trade','bid','ask','update time','last close','change','highest','lowest','wlpr'};
    else
        columnnames = {'last trade','bid','ask','update time','last close','change'};
    end
    data = cell(ninstruments,length(columnnames));

    if ~isreplay
        if ~MDEFUT_INSTANCE.qms_.isconnect
            MDEFUT_INSTANCE.login('Connection','CTP','CounterName',countername);
        end
    end
    
    if ~isreplay
        %refresh twice
        MDEFUT_INSTANCE.qms_.refresh;
        MDEFUT_INSTANCE.qms_.refresh;
    end
    
    if ~isreplay
        hh = hour(now);
        if hh < 3
            cobdate = today - 1;
        else
            cobdate = today;
        end
        if hh < 16 && hh > 2
            lastbd = businessdate(cobdate,-1);
        else
            lastbd = cobdate;
        end
    else
        cobdate = MDEFUT_INSTANCE.replay_date1_;
        lastbd = businessdate(cobdate,-1);
    end
    
    for i = 1:ninstruments
        dailydata = cDataFileIO.loadDataFromTxtFile([instruments2trade{i}.code_ctp,'_daily.txt']);
        idx = dailydata(:,1) == lastbd;
        try
            lastcloseprice = dailydata(idx,5);
        catch
            statusstr = ['last close of ',instruments2trade{i}.code_ctp,'...not found!!!'];
            set(handles.statusbar.statustext,'string',statusstr);
            pause(1);
            continue;
        end
        ctpcodelist{i} = instruments2trade{i}.code_ctp;
%         if ~isreplay
%             quote = MDEFUT_INSTANCE.qms_.getquote(ctpcodelist{i});
%         end
        if useflag
            %init data
            statusstr = ['load historical candles of ',ctpcodelist{i},'...'];
            set(handles.statusbar.statustext,'string',statusstr);
            pause(1);

            STRAT_INSTANCE.initdata;
            wrinfo = MDEFUT_INSTANCE.calc_technical_indicators(instruments2trade{i});
            data{i,1} = num2str(wrinfo{1}(4));
            data{i,2} = '-';
            data{i,3} = '-';
            data{i,4} = '-';
            data{i,5} = num2str(lastcloseprice);
            data{i,6} = sprintf('%4.2f%%',100*(wrinfo{1}(4)/lastcloseprice-1));
            data{i,7} = num2str(wrinfo{1}(2));
            data{i,8} = num2str(wrinfo{1}(3));
            data{i,9} = sprintf('%4.2f%',wrinfo{1}(1));
        else
%             data{i,1} = num2str(quote.last_trade);
%             data{i,2} = num2str(quote.bid1);
%             data{i,3} = num2str(quote.ask1);
%             data{i,4} = datestr(quote.update_time1,'dd/mmm HH:MM');
%             data{i,5} = num2str(lastcloseprice);
        end
    end

    %set table
    set(handles.mktdatatbl.table,'RowName',ctpcodelist,'Data',data,'ColumnName',columnnames);
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