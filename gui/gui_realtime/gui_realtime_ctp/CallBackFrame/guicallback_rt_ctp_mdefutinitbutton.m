function guicallback_rt_ctp_mdefutinitbutton( hObject , eventdata , handles )
    variablenotused(hObject);
    variablenotused(eventdata);

    global MDEFUT_INSTANCE;
    global STRAT_INSTANCE;
    global OPS_INSTANCE;

    counterlist = get(handles.generalsetup.countername_popupmenu,'string');
    counteridx = get(handles.generalsetup.countername_popupmenu,'value');
    countername = counterlist{counteridx};
    counter = CounterCTP.(countername);    
    
    trader = cTrader;
    trader.init('trader_ctp_manual');
    book = cBook('BookName','tfzq_book_rh_manual','TraderName',trader.name_,'CounterName',countername);
    trader.addbook(book);
    OPS_INSTANCE.registerbook(book);
    OPS_INSTANCE.registercounter(counter);
    STRAT_INSTANCE.registerhelper(OPS_INSTANCE);
    
    %the strategy
    %get startup fund
    startupfund = get(handles.generalsetup.startupfund_edit,'string');
    ret = STRAT_INSTANCE.setavailablefund(str2double(startupfund{1}),'firstset',true);
    if ~ret
        statusstr = 'Error:startup fund set failed...';
        set(handles.statusbar.statustext,'string',statusstr);
        return
    end
    
    %load strategy risk configurations
    configfilename = get(handles.generalsetup.riskconfig_edit,'string');
    STRAT_INSTANCE.loadriskcontrolconfigfromfile('filename',configfilename{1});
    instruments2trade = STRAT_INSTANCE.getinstruments;
    ninstruments = size(instruments2trade,1);
    ctpcodelist = cell(ninstruments,1);
    
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
    
    loadhistlist = get(handles.generalsetup.loadhistdata_popupmenu,'string');
    loadhistidx = get(handles.generalsetup.loadhistdata_popupmenu,'value');
    loadhiststr = loadhistlist{loadhistidx};
    
    if strcmpi(loadhiststr,'yes')
        loadflag = 1;
    else
        loadflag = 0;
    end
        
    %load historical data
    if loadflag
        columnnames = {'last trade','bid','ask','update time','last close','change','wlhigh','wllow'};
    else
        columnnames = {'last trade','bid','ask','update time'};
    end
    data = cell(ninstruments,length(columnnames));

    if ~MDEFUT_INSTANCE.qms_.isconnect
        MDEFUT_INSTANCE.login('Connection','CTP','CounterName',countername);
    end
    
    MDEFUT_INSTANCE.qms_.refresh;
    MDEFUT_INSTANCE.qms_.refresh;
    
    for i = 1:ninstruments
        ctpcodelist{i} = instruments2trade{i}.code_ctp;
        quote = MDEFUT_INSTANCE.qms_.getquote(ctpcodelist{i});
        if loadflag
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
            data{i,1} = quote.last_trade;
            data{i,2} = quote.bid1;
            data{i,3} = quote.ask1;
%             histcandles = MDEFUT_INSTANCE.gethistcandles(instruments2trade{i});
            data{i,4} = datestr(quote.update_time1,'dd/mmm HH:MM');
            data{i,5} = num2str(wrinfo{1}(4));
            data{i,5} = 0;
            data{i,7} = num2str(wrinfo{1}(2));
            data{i,8} = num2str(wrinfo{1}(3));
        else
            data{i,1} = quote.last_trade;
            data{i,2} = quote.bid1;
            data{i,3} = quote.ask1;
            data{i,4} = datestr(quote.update_time1,'dd/mmm HH:MM');
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