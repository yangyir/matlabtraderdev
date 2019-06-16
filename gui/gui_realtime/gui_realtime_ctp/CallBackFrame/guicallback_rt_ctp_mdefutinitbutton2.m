function guicallback_rt_ctp_mdefutinitbutton2( hObject , eventdata , handles )
%MDEFUT only
    variablenotused(hObject);
    variablenotused(eventdata);

    global MDEFUT_INSTANCE;
    
    counterlist = get(handles.generalsetup.countername_popupmenu,'string');
    counteridx = get(handles.generalsetup.countername_popupmenu,'value');
    countername = counterlist{counteridx};
    
    vals = get(handles.generalsetup.mode_popupmenu,'string');
    idx = get(handles.generalsetup.mode_popupmenu,'value');
    mode = vals{idx};
        
    %load configurations
    configfilename = get(handles.generalsetup.riskconfigfile_edit,'string');
    riskcontrols = cStratConfigArray;
    riskcontrols.loadfromfile('filename',configfilename{1});
    
    ninstrument = riskcontrols.latest_;
    for i = 1:ninstrument
        if riskcontrols.node_(i).use_
            code = riskcontrols.node_(i).codectp_;
            MDEFUT_INSTANCE.registerinstrument(code);
            freqnum = str2double(riskcontrols.node_(i).samplefreq_(1:end-1));
            MDEFUT_INSTANCE.setcandlefreq(freqnum,code);
            try
                numofperiod = riskcontrols.getconfigvalue('code',code,'propname','numofperiod');
            catch
                numofperiod = 144;
            end
            MDEFUT_INSTANCE.wrnperiod_(i) = numofperiod;
        end
    end
    
    if strcmpi(mode,'replay')
        replaystartdtstr = get(handles.generalsetup.replaytimestart_edit,'string');
        replaystartdtstr = replaystartdtstr{1};
        for i = 1:ninstrument
            if riskcontrols.node_(i).use_
                code = riskcontrols.node_(i).codectp_;
                replay_filename = [code,'_',datestr(replaystartdtstr,'yyyymmdd'),'_tick.txt'];
                %here we shall put status bar
                MDEFUT_INSTANCE.initreplayer('code',code,'fn',replay_filename);
                
            end
        end
        MDEFUT_INSTANCE.settimerinterval(0.5/50);
    end
    
    instruments2trade = MDEFUT_INSTANCE.qms_.instruments_.getinstrument;
    
    ninstruments = size(instruments2trade,1);
    ctpcodelist = cell(ninstruments,1);
    
    columnnames = {'last trade','bid','ask','update time','last close','change','wr','max','min','bs','ss',...
        'levelup','leveldn','macd','sig'};

    data = cell(ninstruments,length(columnnames));
    
    if strcmpi(mode,'realtime')
        if ~MDEFUT_INSTANCE.qms_.isconnect
            MDEFUT_INSTANCE.login('Connection','CTP','CounterName',countername);
        end
        %refresh twice
        MDEFUT_INSTANCE.qms_.refresh;
        MDEFUT_INSTANCE.qms_.refresh;
    end
    
    for i = 1:ninstruments
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
%             statusstr = ['last close of ',instruments2trade{i}.code_ctp,'...not found!!!'];
%             set(handles.statusbar.statustext,'string',statusstr);
            pause(1);
            continue;
        end
        ctpcodelist{i} = instruments2trade{i}.code_ctp;
        
        pause(1);
        samplefreqstr = riskcontrols.getconfigvalue('code',ctpcodelist{i},'propname','samplefreq');
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

        wrinfo = MDEFUT_INSTANCE.calc_wr_(instruments2trade{i},'IncludeLastCandle',1);
        [macdvec,sigvec] = MDEFUT_INSTANCE.calc_macd_(instruments2trade{i},'IncludeLastCandle',1);
        [bs,ss,levelup,leveldn] = MDEFUT_INSTANCE.calc_tdsq_(instruments2trade{i},'IncludeLastCandle',1);

        data{i,1} = num2str(lastcloseprice);
        data{i,2} = num2str(lastcloseprice);
        data{i,3} = num2str(lastcloseprice);
        data{i,4} = datestr([datestr(lastbd,'yyyy-mm-dd'),' ',instruments2trade{i}.break_interval{2,end}],'dd/mmm HH:MM:SS');
        data{i,5} = num2str(lastcloseprice);
        temp = sprintf('%3.1f%%',0);
        data{i,6} = temp;
        temp = sprintf('%3.1f',wrinfo(1));
        data{i,7} = temp;
        data{i,8} = num2str(wrinfo(2));
        data{i,9} = num2str(wrinfo(3));
        data{i,10} = num2str(bs(end));
        data{i,11} = num2str(ss(end));
        data{i,12} = num2str(levelup(end));
        data{i,13} = num2str(leveldn(end));
        temp = sprintf('%3.3f',macdvec(end));
        data{i,14} = temp;
        temp = sprintf('%3.3f',sigvec(end));
        data{i,15} = temp;
    end

    %set table
    set(handles.mktdatatbl.table,'RowName',ctpcodelist,'Data',data,'ColumnName',columnnames);
    %
    if ninstruments > 0
        set(handles.mktdataplot.popupmenu,'String',ctpcodelist);
    else
        set(handles.mktdataplot.popupmenu,'String',{'none'});
    end
    
    MDEFUT_INSTANCE.gui_ = handles;
    
    fprintf('init done!\n');
    
end