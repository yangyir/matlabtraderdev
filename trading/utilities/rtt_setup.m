function [rtt_output] = rtt_setup(varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('CounterName','ccb_ly_fut',@ischar);
    p.addParameter('BookName','book1',@ischar);
    p.addParameter('MarketType','futures',@ischar);
    p.addParameter('StrategyName','manual',@ischar);
    %note:20190718 from this date onwards, instruments are not given as
    %function direct input but are given in riskconfigfile instead
%     p.addParameter('Instruments',{},@iscell);
    p.addParameter('TradesFileName','',@ischar);
    p.addParameter('RiskConfigFileName','',@ischar);
    p.addParameter('InitialFundLevel',[],@isnumeric);
    p.addParameter('UseHistoricalData',true,@islogical);
    p.addParameter('Mode','realtime',@ischar);
    p.addParameter('ReplayFromDate','',@ischar);
    p.addParameter('ReplayToDate','',@ischar);
    p.addParameter('ReplaySpeed',50,@isnumeric);
        
    p.parse(varargin{:});
    
    configfn = p.Results.RiskConfigFileName;
    if isempty(configfn)
        error('rtt_setup:missing input of RiskConfigFile');
    end
    
    mode = p.Results.Mode;
    if ~(strcmpi(mode,'realtime') || strcmpi(mode,'replay'))
        error('rtt_setup:invalid mode input,must be realtime or replay')
    end
    
    if strcmpi(mode,'replay')
        replayfromdate = p.Results.ReplayFromDate;
        replaytodate = p.Results.ReplayToDate;
        if isempty(replayfromdate) || isempty(replaytodate)
            error('rtt_setup:missing replay fromdate and todate in replay mode')
        end
    end
            
    countername = p.Results.CounterName;
    %note:20180905:currently we only work with CTP counter
    %note:20180918:we can now have RH counter
    if strcmpi(countername,'rh_demo_tf')
        rtt_counter = CounterRH.(countername);
    else
        try
            rtt_counter = CounterCTP.(countername);
        catch e
            error('rtt_setup:%s',e.message);
        end
    end
        
    bookname = p.Results.BookName;
    markettype = p.Results.MarketType;
    stratname = p.Results.StrategyName;
    
    if ~isvalidstrategyname(stratname)
        error('rtt_setup:invalid input of strategy name')
    end
    
%     instruments = p.Results.Instruments;
    tfn = p.Results.TradesFileName;
    
    usemdeopt = false;
    if strcmpi(markettype,'futures')
        usemdefut = true;
    elseif strcmpi(markettype,'options')
        usemdefut = true;
        usemdeopt = true;
    else
        error('rtt_setup:invalid market type input, must either be futures or options')
    end
    
    helpername = [bookname,'-ops'];
    
    %first setup a book
    rtt_book = cBook('BookName',bookname,'CounterName',countername);
    %assign one ops for the book created
    rtt_helper = cOps('Name',helpername);
    
    if ~isempty(tfn)
        trades = cTradeOpenArray;
        trades.fromtxt(tfn);
        livetrades = trades.filterby('CounterName',countername,'BookName',bookname,'Status','live');
        positions = livetrades.convert2positions;
        rtt_book.setpositions(positions);
    end
    
    if usemdefut
        rtt_mdefut = cMDEFut;
        rtt_mdeopt = [];
    end
    if usemdefut && usemdeopt
        rtt_mdefut = cMDEFut;
        rtt_mdeopt = cMDEOpt;
%         if ~isempty(instruments)
%             error('rtt_setup:not implemented for option market type yet')
%         end
    end
    
    rtt_helper.registerbook(rtt_book);
    rtt_helper.registercounter(rtt_counter);
    rtt_helper.registermdefut(rtt_mdefut);
    if isa(rtt_mdeopt,'cMDEOpt'), rtt_helper.registermdeopt(rtt_mdeopt);end
    if ~isempty(tfn), rtt_helper.registerpasttrades(livetrades);end
    if strcmpi(mode,'realtime')
        dir_ = [getenv('DATAPATH'),'realtimetrading\'];
    else
        dir_ = [getenv('DATAPATH'),'replay\'];
    end
    if strcmpi(countername,'citic_kim_fut')
        dir_ = [dir_,'citickim\'];
    elseif strcmpi(countername,'ccb_ly_fut')
        dir_ = [dir_,'ccbly\'];
    elseif strcmpi(countername,'ccb_yy_fut')
        dir_ = [dir_,'ccbyy\'];
    elseif strcmpi(countername,'dh_professorWan_fut')
        dir_ = [dir_,'dhpw\'];
    else
        error('rtt_setup:invalid countername')
    end
    rtt_helper.savedir_ = dir_;
    rtt_helper.loaddir_ = dir_;
            
    if strcmpi(stratname,'wlpr')
        rtt_strategy = cStratFutMultiWR;
    elseif strcmpi(stratname,'batman')
        rtt_strategy = cStratFutMultiBatman;
    elseif strcmpi(stratname,'wlprbatman')
        rtt_strategy = cStratFutMultiWRPlusBatman;
    elseif strcmpi(stratname,'manual')
        rtt_strategy = cStratManual;
        rtt_strategy.printflag_ = false;
    elseif strcmpi(stratname,'pair')
        rtt_strategy = cStratFutPairCointegration;
    elseif strcmpi(stratname,'tdsq')
        rtt_strategy = cStratFutMultiTDSQ;
    else
    end
    
    rtt_strategy.registerhelper(rtt_helper);
    rtt_strategy.registermdefut(rtt_mdefut);
    if isa(rtt_mdeopt,'cMDEOpt'), rtt_strategy.registermdeopt(rtt_mdeopt);end
    
    rtt_strategy.loadriskcontrolconfigfromfile('filename',configfn);
    
    speedadj = 1;
    if strcmpi(mode,'replay')
        replaydts = gendates('fromdate',replayfromdate,'todate',replaytodate);
        try
            instruments = rtt_strategy.getinstruments;
            ninstruments = size(instruments,1);
            for i = 1:ninstruments
                code = instruments{i}.code_ctp;
                filenames = cell(size(replaydts,1),1);
                for j = 1:size(replaydts,1)
                    filenames{j} = [code,'_',datestr(replaydts(j),'yyyymmdd'),'_tick.txt'];
                end
                fprintf('load tick data of %s in replay mode...\n',code);
                rtt_mdefut.initreplayer('code',code,'filenames',filenames);
            end
        catch err
            error('rtt_setup:%s\n',err.message)
        end
        speedadj = p.Results.ReplaySpeed;
        fprintf('set replay speed to %s...\n',num2str(speedadj));
        rtt_mdefut.mode_ = 'replay';
        rtt_helper.mode_ = 'replay';
        rtt_strategy.mode_ = 'replay';
    end

    rtt_mdefut.settimerinterval(0.5/speedadj);
    rtt_helper.settimerinterval(0.5/speedadj);
    rtt_strategy.settimerinterval(1/speedadj);
    
    stratfund = p.Results.InitialFundLevel;
    if ~isempty(stratfund)
        rtt_strategy.setavailablefund(stratfund,'firstset',true,'checkavailablefund',false);
    end
    
    usehistoricaldata = p.Results.UseHistoricalData;
    if usehistoricaldata
        if strcmpi(stratname,'manual'), rtt_strategy.usehistoricaldata_ = true; end
        rtt_strategy.initdata;
    else
        if strcmpi(stratname,'manual'), rtt_strategy.usehistoricaldata_ = false;end
    end
    
    if strcmpi(mode,'realtime')
        rtt_mdefut.qms_.watcher_.conn = 'ctp';
        rtt_mdefut.qms_.watcher_.ds = cCTP.ccb_ly_fut;
    end
    
    rtt_output = struct('counter',rtt_counter,...
        'book',rtt_book,...
        'ops',rtt_helper,...
        'mdefut',rtt_mdefut,...
        'mdeopt',rtt_mdeopt,...
        'strategy',rtt_strategy);
    
    backhome;
    
    fprintf('%s trading ready...\n',mode);
    
end