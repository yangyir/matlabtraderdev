function [pnlcell,pnlmat,sharpratio,maxdrawdown,maxdrawdownpct] = bkfunc_wrma_copper(varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('SampleFrequency','1m',@ischar);
    p.addParameter('NPeriod',144,@isnumeric);
    p.addParameter('Lead',1,@isnumeric);
    p.addParameter('Lag',12,@isnumeric);
    p.parse(varargin{:});
    ui_freq = p.Results.SampleFrequency;
    nperiod = p.Results.NPeriod;
    lead = p.Results.Lead;
    lag = p.Results.Lag;
    %
    dir_ = [getenv('BACKTEST'),'copper\'];
    fn = ['copper_intraday_',ui_freq];
    data = load([dir_,fn]);
    fldn = ['candles_',ui_freq];
    candles = data.(fldn);
    dt1 = floor(candles{1,2}(1,1));
    dt2 = floor(candles{end,2}(end,1));
    bds = gendates('fromdate',dt1,'todate',dt2);
    nbds = size(bds,1);
    nfuts = size(candles,1);
    
    pnlcell = cell(nfuts,1);
    for i = 1:nfuts
        futcode = candles{i,1};
        candlek = candles{i,2};
        [trades,~] = bkfunc_gentrades_wlprma(futcode,candlek,...
            'SampleFrequency',ui_freq,...
            'NPeriod',nperiod,...
            'Lead',lead,...
            'Lag',lag);
        ntrades = trades.latest_;
        pnl_i = zeros(ntrades,1);
        for itrade = 1:ntrades
            tradein2 = trades.node_(itrade).copy;
            [tradeout] = bkfunc_checksingletrade(tradein2,candlek,'WRWidth',10,'Print',0,...
                'OptionPremiumRatio',1,'stopratio',0,...
                'DoPlot',0,'buffer',1,'lead',lead,'lag',lag,...
                'UseDefaultFlashStopLoss',0);
            pnl_i(itrade) = tradeout.closepnl_;
        end
        pnlcell{i} = pnl_i;
    end
    %
    pnlmat = cell2mat(pnlcell);
    sharpratio = sqrt(nbds)*mean(pnlmat)/std(pnlmat);
    cumpnlmat = cumsum(pnlmat);
    maxcumpnlmat = zeros(size(cumpnlmat));
    for i = 1:size(cumpnlmat,1)
        maxcumpnlmat(i) = max(cumpnlmat(1:i));
    end
    drawdown = cumpnlmat - maxcumpnlmat;
    maxdrawdown = min(drawdown);
    idx = find(drawdown == maxdrawdown);
    maxdrawdownpct = maxdrawdown/maxcumpnlmat(idx);
    
end






