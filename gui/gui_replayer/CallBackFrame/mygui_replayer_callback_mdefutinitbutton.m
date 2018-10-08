function mygui_replayer_callback_mdefutinitbutton( hObject , eventdata , handles )
    variablenotused(hObject);
    variablenotused(eventdata);

    global MDEFUT_INSTANCE;

    replayspeedcell = get(handles.generalsetup.ReplaySpeed_PopupMenu,'string');
    idx = get(handles.generalsetup.ReplaySpeed_PopupMenu,'value');
    replayspeedval = str2double(replayspeedcell{idx});
    MDEFUT_INSTANCE.settimerinterval(0.5/replayspeedval);

    samplefreqs = get(handles.generalsetup.SampleFreq_PopupMenu,'string');
    idx = get(handles.generalsetup.SampleFreq_PopupMenu,'value');
    samplefreqstr = samplefreqs{idx};
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
    end

    wlprparams = struct('name','WilliamR','values',{{'numofperiods',144}});

    replay_startdt = get(handles.generalsetup.StartDate_Edit,'string');
    replay_enddt = get(handles.generalsetup.EndDate_Edit,'string');
    replay_dates = gendates('fromdate',replay_startdt{1},'todate',replay_enddt{1});
    ndates = size(replay_dates,1);
    replay_filenames = cell(ndates,1);

    %note:here the active futures directory is hard-coded:
    %todo:rename the active futures directory in enviromental variable
    %setup
    activefuts = cDataFileIO.loadDataFromTxtFile(['C:\yangyiran\activefutures\activefutures_',datestr(replay_startdt,'yyyymmdd'),'.txt']);

    tradeCSI300 = get(handles.instruments.CSI300_CheckoutBox,'value');
    if tradeCSI300
        set(handles.statusbar.statustext,'string','status:init tick data of CSI300...');
        MDEFUT_INSTANCE.registerinstrument(activefuts{1});
        MDEFUT_INSTANCE.setcandlefreq(samplefreqnum,activefuts{1});
        for i = 1:ndates
            replay_filenames{i,1} = [activefuts{1},'_',datestr(replay_dates(i),'yyyymmdd'),'_tick.txt'];
        end
        MDEFUT_INSTANCE.initreplayer('code',activefuts{1},'filenames',replay_filenames);
    end
    %
    tradeSSE50 = get(handles.instruments.SSE50_CheckoutBox,'value');
    if tradeSSE50
        set(handles.statusbar.statustext,'string','status:init tick data of SSE50...');
        MDEFUT_INSTANCE.registerinstrument(activefuts{2});
        MDEFUT_INSTANCE.setcandlefreq(samplefreqnum,activefuts{2});
        for i = 1:ndates
            replay_filenames{i,1} = [activefuts{2},'_',datestr(replay_dates(i),'yyyymmdd'),'_tick.txt'];
        end
        MDEFUT_INSTANCE.initreplayer('code',activefuts{2},'filenames',replay_filenames);
    end
    %
    tradeCSI500 = get(handles.instruments.CSI500_CheckoutBox,'value');
    if tradeCSI500
        set(handles.statusbar.statustext,'string','status:init tick data of CSI500...');
        MDEFUT_INSTANCE.registerinstrument(activefuts{3});
        MDEFUT_INSTANCE.setcandlefreq(samplefreqnum,activefuts{3});
        for i = 1:ndates
            replay_filenames{i,1} = [activefuts{3},'_',datestr(replay_dates(i),'yyyymmdd'),'_tick.txt'];
        end
        MDEFUT_INSTANCE.initreplayer('code',activefuts{3},'filenames',replay_filenames);
    end
    %
    tradeGovtBond5y = get(handles.instruments.GovtBond5y_CheckoutBox,'value');
    if tradeGovtBond5y
        set(handles.statusbar.statustext,'string','status:init tick data of 5y-GovtBond...');
        MDEFUT_INSTANCE.registerinstrument(activefuts{4});
        MDEFUT_INSTANCE.setcandlefreq(samplefreqnum,activefuts{4});
        for i = 1:ndates
            replay_filenames{i,1} = [activefuts{4},'_',datestr(replay_dates(i),'yyyymmdd'),'_tick.txt'];
        end
        MDEFUT_INSTANCE.initreplayer('code',activefuts{4},'filenames',replay_filenames);
    end
    %
    tradeGovtBond10y = get(handles.instruments.GovtBond10y_CheckoutBox,'value');
    if tradeGovtBond10y
        set(handles.statusbar.statustext,'string','status:init tick data of 10y-GovtBond...');
        MDEFUT_INSTANCE.registerinstrument(activefuts{5});
        MDEFUT_INSTANCE.setcandlefreq(samplefreqnum,activefuts{5});
        for i = 1:ndates
            replay_filenames{i,1} = [activefuts{5},'_',datestr(replay_dates(i),'yyyymmdd'),'_tick.txt'];
        end
        MDEFUT_INSTANCE.initreplayer('code',activefuts{5},'filenames',replay_filenames);
    end
    %
    tradeGold = get(handles.instruments.Gold_CheckoutBox,'value');
    if tradeGold
        set(handles.statusbar.statustext,'string','status:init tick data of gold...');
        MDEFUT_INSTANCE.registerinstrument(activefuts{6});
        MDEFUT_INSTANCE.setcandlefreq(samplefreqnum,activefuts{6});
        for i = 1:ndates
            replay_filenames{i,1} = [activefuts{6},'_',datestr(replay_dates(i),'yyyymmdd'),'_tick.txt'];
        end
        MDEFUT_INSTANCE.initreplayer('code',activefuts{6},'filenames',replay_filenames);
    end
    %
    tradeSilver = get(handles.instruments.Silver_CheckoutBox,'value');
    if tradeSilver
        set(handles.statusbar.statustext,'string','status:init tick data of silver...');
        MDEFUT_INSTANCE.registerinstrument(activefuts{7});
        MDEFUT_INSTANCE.setcandlefreq(samplefreqnum,activefuts{7});
        for i = 1:ndates
            replay_filenames{i,1} = [activefuts{7},'_',datestr(replay_dates(i),'yyyymmdd'),'_tick.txt'];
        end
        MDEFUT_INSTANCE.initreplayer('code',activefuts{7},'filenames',replay_filenames);
    end
    %
    tradeCopper = get(handles.instruments.Copper_CheckoutBox,'value');
    if tradeCopper
        set(handles.statusbar.statustext,'string','status:init tick data of copper...');
        MDEFUT_INSTANCE.registerinstrument(activefuts{8});
        MDEFUT_INSTANCE.setcandlefreq(samplefreqnum,activefuts{8});
        for i = 1:ndates
            replay_filenames{i,1} = [activefuts{8},'_',datestr(replay_dates(i),'yyyymmdd'),'_tick.txt'];
        end
        MDEFUT_INSTANCE.initreplayer('code',activefuts{8},'filenames',replay_filenames);
    end
    %
    tradeAluminum = get(handles.instruments.Aluminum_CheckoutBox,'value');
    if tradeAluminum
        set(handles.statusbar.statustext,'string','status:init tick data of aluminum...');
        MDEFUT_INSTANCE.registerinstrument(activefuts{9});
        MDEFUT_INSTANCE.setcandlefreq(samplefreqnum,activefuts{9});
        for i = 1:ndates
            replay_filenames{i,1} = [activefuts{9},'_',datestr(replay_dates(i),'yyyymmdd'),'_tick.txt'];
        end
        MDEFUT_INSTANCE.initreplayer('code',activefuts{9},'filenames',replay_filenames);
    end
    %
    tradeZinc = get(handles.instruments.Zinc_CheckoutBox,'value');
    if tradeZinc
        set(handles.statusbar.statustext,'string','status:init tick data of zinc...');
        MDEFUT_INSTANCE.registerinstrument(activefuts{10});
        MDEFUT_INSTANCE.setcandlefreq(samplefreqnum,activefuts{10});
        for i = 1:ndates
            replay_filenames{i,1} = [activefuts{10},'_',datestr(replay_dates(i),'yyyymmdd'),'_tick.txt'];
        end
        MDEFUT_INSTANCE.initreplayer('code',activefuts{10},'filenames',replay_filenames);
    end
    %
    tradeLead = get(handles.instruments.Lead_CheckoutBox,'value');
    if tradeLead
        set(handles.statusbar.statustext,'string','status:init tick data of lead...');
        MDEFUT_INSTANCE.registerinstrument(activefuts{11});
        MDEFUT_INSTANCE.setcandlefreq(samplefreqnum,activefuts{11});
        for i = 1:ndates
            replay_filenames{i,1} = [activefuts{11},'_',datestr(replay_dates(i),'yyyymmdd'),'_tick.txt'];
        end
        MDEFUT_INSTANCE.initreplayer('code',activefuts{11},'filenames',replay_filenames);
    end
    %
    tradeNickel = get(handles.instruments.Nickel_CheckoutBox,'value');
    if tradeNickel
        set(handles.statusbar.statustext,'string','status:init tick data of nickel...');
        MDEFUT_INSTANCE.registerinstrument(activefuts{12});
        MDEFUT_INSTANCE.setcandlefreq(samplefreqnum,activefuts{12});
        for i = 1:ndates
            replay_filenames{i,1} = [activefuts{12},'_',datestr(replay_dates(i),'yyyymmdd'),'_tick.txt'];
        end
        MDEFUT_INSTANCE.initreplayer('code',activefuts{12},'filenames',replay_filenames);
    end
    %
    tradeCrude = get(handles.instruments.Crude_CheckoutBox,'value');
    if tradeCrude
        set(handles.statusbar.statustext,'string','status:init tick data of crude oil...');
        MDEFUT_INSTANCE.registerinstrument(activefuts{13});
        MDEFUT_INSTANCE.setcandlefreq(samplefreqnum,activefuts{13});
        for i = 1:ndates
            replay_filenames{i,1} = [activefuts{13},'_',datestr(replay_dates(i),'yyyymmdd'),'_tick.txt'];
        end
        MDEFUT_INSTANCE.initreplayer('code',activefuts{13},'filenames',replay_filenames);
    end
    %
    tradePTA = get(handles.instruments.PTA_CheckoutBox,'value');
    if tradePTA
        set(handles.statusbar.statustext,'string','status:init tick data of PTA...');
        MDEFUT_INSTANCE.registerinstrument(activefuts{14});
        MDEFUT_INSTANCE.setcandlefreq(samplefreqnum,activefuts{14});
        for i = 1:ndates
            replay_filenames{i,1} = [activefuts{14},'_',datestr(replay_dates(i),'yyyymmdd'),'_tick.txt'];
        end
        MDEFUT_INSTANCE.initreplayer('code',activefuts{14},'filenames',replay_filenames);
    end
    %
    tradeLLDPE = get(handles.instruments.LLDPE_CheckoutBox,'value');
    if tradeLLDPE
        set(handles.statusbar.statustext,'string','status:init tick data of LLDPE...');
        MDEFUT_INSTANCE.registerinstrument(activefuts{15});
        MDEFUT_INSTANCE.setcandlefreq(samplefreqnum,activefuts{15});
        for i = 1:ndates
            replay_filenames{i,1} = [activefuts{15},'_',datestr(replay_dates(i),'yyyymmdd'),'_tick.txt'];
        end
        MDEFUT_INSTANCE.initreplayer('code',activefuts{15},'filenames',replay_filenames);
    end
    %
    tradePP = get(handles.instruments.PP_CheckoutBox,'value');
    if tradePP
        set(handles.statusbar.statustext,'string','status:init tick data of pp...');
        MDEFUT_INSTANCE.registerinstrument(activefuts{16});
        MDEFUT_INSTANCE.setcandlefreq(samplefreqnum,activefuts{16});
        for i = 1:ndates
            replay_filenames{i,1} = [activefuts{16},'_',datestr(replay_dates(i),'yyyymmdd'),'_tick.txt'];
        end
        MDEFUT_INSTANCE.initreplayer('code',activefuts{16},'filenames',replay_filenames);
    end
    %
    tradeMethanol = get(handles.instruments.Methanol_CheckoutBox,'value');
    if tradeMethanol
        set(handles.statusbar.statustext,'string','status:init tick data of methanol...');
        MDEFUT_INSTANCE.registerinstrument(activefuts{17});
        MDEFUT_INSTANCE.setcandlefreq(samplefreqnum,activefuts{17});
        for i = 1:ndates
            replay_filenames{i,1} = [activefuts{17},'_',datestr(replay_dates(i),'yyyymmdd'),'_tick.txt'];
        end
        MDEFUT_INSTANCE.initreplayer('code',activefuts{17},'filenames',replay_filenames);
    end
    %
    tradeRebar = get(handles.instruments.Rebar_CheckoutBox,'value');
    if tradeRebar
        set(handles.statusbar.statustext,'string','status:init tick data of rebar...');
        MDEFUT_INSTANCE.registerinstrument(activefuts{18});
        MDEFUT_INSTANCE.setcandlefreq(samplefreqnum,activefuts{18});
        for i = 1:ndates
            replay_filenames{i,1} = [activefuts{18},'_',datestr(replay_dates(i),'yyyymmdd'),'_tick.txt'];
        end
        MDEFUT_INSTANCE.initreplayer('code',activefuts{18},'filenames',replay_filenames);
    end
    %
    tradeIronOre = get(handles.instruments.IronOre_CheckoutBox,'value');
    if tradeIronOre
        set(handles.statusbar.statustext,'string','status:init tick data of iron ore...');
        MDEFUT_INSTANCE.registerinstrument(activefuts{19});
        MDEFUT_INSTANCE.setcandlefreq(samplefreqnum,activefuts{19});
        for i = 1:ndates
            replay_filenames{i,1} = [activefuts{19},'_',datestr(replay_dates(i),'yyyymmdd'),'_tick.txt'];
        end
        MDEFUT_INSTANCE.initreplayer('code',activefuts{19},'filenames',replay_filenames);
    end
    %
    tradeSoymeal = get(handles.instruments.Soymeal_CheckoutBox,'value');
    if tradeSoymeal
        set(handles.statusbar.statustext,'string','status:init tick data of soymeal...');
        MDEFUT_INSTANCE.registerinstrument(activefuts{20});
        MDEFUT_INSTANCE.setcandlefreq(samplefreqnum,activefuts{20});
        for i = 1:ndates
            replay_filenames{i,1} = [activefuts{20},'_',datestr(replay_dates(i),'yyyymmdd'),'_tick.txt'];
        end
        MDEFUT_INSTANCE.initreplayer('code',activefuts{20},'filenames',replay_filenames);
    end
    %
    tradeSugar = get(handles.instruments.Sugar_CheckoutBox,'value');
    if tradeSugar
        set(handles.statusbar.statustext,'string','status:init tick data of sugar...');
        MDEFUT_INSTANCE.registerinstrument(activefuts{21});
        MDEFUT_INSTANCE.setcandlefreq(samplefreqnum,activefuts{21});
        for i = 1:ndates
            replay_filenames{i,1} = [activefuts{21},'_',datestr(replay_dates(i),'yyyymmdd'),'_tick.txt'];
        end
        MDEFUT_INSTANCE.initreplayer('code',activefuts{21},'filenames',replay_filenames);
    end
    %
    tradeCorn = get(handles.instruments.Corn_CheckoutBox,'value');
    if tradeCorn
        set(handles.statusbar.statustext,'string','status:init tick data of corn...');
        MDEFUT_INSTANCE.registerinstrument(activefuts{22});
        MDEFUT_INSTANCE.setcandlefreq(samplefreqnum,activefuts{22});
        for i = 1:ndates
            replay_filenames{i,1} = [activefuts{22},'_',datestr(replay_dates(i),'yyyymmdd'),'_tick.txt'];
        end
        MDEFUT_INSTANCE.initreplayer('code',activefuts{22},'filenames',replay_filenames);
    end
    %
    tradeRubber = get(handles.instruments.Rubber_CheckoutBox,'value');
    if tradeRubber
        set(handles.statusbar.statustext,'string','status:init tick data of rubber...');
        MDEFUT_INSTANCE.registerinstrument(activefuts{23});
        MDEFUT_INSTANCE.setcandlefreq(samplefreqnum,activefuts{23});
        for i = 1:ndates
            replay_filenames{i,1} = [activefuts{23},'_',datestr(replay_dates(i),'yyyymmdd'),'_tick.txt'];
        end
        MDEFUT_INSTANCE.initreplayer('code',activefuts{23},'filenames',replay_filenames);
    end
    %
    tradeApple = get(handles.instruments.Apple_CheckoutBox,'value');
    set(handles.statusbar.statustext,'string','status:init tick data of apple...');
    if tradeApple
        MDEFUT_INSTANCE.registerinstrument(activefuts{24});
        MDEFUT_INSTANCE.setcandlefreq(samplefreqnum,activefuts{24});
        for i = 1:ndates
            replay_filenames{i,1} = [activefuts{24},'_',datestr(replay_dates(i),'yyyymmdd'),'_tick.txt'];
        end
        MDEFUT_INSTANCE.initreplayer('code',activefuts{24},'filenames',replay_filenames);
    end

    instruments2trade = MDEFUT_INSTANCE.qms_.instruments_.getinstrument;
    ninstruments = size(instruments2trade,1);
    ctpcodelist = cell(ninstruments,1);

    columnnames = {'last trade','bid','ask','update time','last close','change','wlhight','wllow'};
    data = zeros(ninstruments,length(columnnames));

    for i = 1:ninstruments
        ctpcodelist{i} = instruments2trade{i}.code_ctp;
        %init data
        statusstr = ['status:load historical candles of ',ctpcodelist{i},'...'];
        set(handles.statusbar.statustext,'string',statusstr);
        MDEFUT_INSTANCE.initcandles(instruments2trade{i},'NumberofPeriods',nbdays);
        MDEFUT_INSTANCE.settechnicalindicator(instruments2trade{i},wlprparams);
        wrinfo = MDEFUT_INSTANCE.calc_technical_indicators(instruments2trade{i});
        data(i,7) = wrinfo{1}(2);
        data(i,8) = wrinfo{1}(3);
        data(i,5) = wrinfo{1}(4);
    end

    set(handles.mdefut.table,'RowName',ctpcodelist,'Data',num2cell(data));
    %
    if ninstruments > 0
        set(handles.marketdataPlot.popupmenu,'String',ctpcodelist);
    else
        set(handles.marketdataPlot.popupmenu,'String',{'none'});
    end

    statusstr = 'status:market data engine initialized...';
    set(handles.statusbar.statustext,'string',statusstr);
end