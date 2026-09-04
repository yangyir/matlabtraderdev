function [res] = calc_fx_sharp(varargin)
    % utility function to calc the stats of the trades with different
    % leverage, per asset stoploss and slippage
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('leverage',1,@isnumeric);
    p.addParameter('slpa',0.01,@isnumeric);
    p.addParameter('tbltrades',[],@istable);
    p.addParameter('tblstats',[],@istable);
    p.addParameter('nslippage',0,@isnumeric);

    p.parse(varargin{:});
    
    leverage = p.Results.leverage;
    slpa = p.Results.slpa;
    tbl_i = p.Results.tbltrades;
    sizing_i = p.Results.tblstats;
    nslippage = p.Results.nslippage;

    tbl_i = sortrows(tbl_i,'closedatetime','ascend');

    balance = 1;

    ntrades = size(tbl_i,1);

    weights = zeros(ntrades,1);
    costs = zeros(ntrades,1);
    nfx = size(sizing_i,1);

    for j = 1:nfx
        code_j = sizing_i.codes_fx{j};
        wj = sizing_i.f_opt(j);
        % aslo need to make sure single asset's MMD is below 5% of the
        % balance
        mdd = sizing_i.MDD(j);
        wj_ = abs(slpa(j) / (mdd*leverage));
        idx_j = strcmpi(tbl_i.code,code_j);
        weights(idx_j) = min(wj,wj_);        
    end
    
    for k = 1:length(costs)
        px_k = tbl_i.openprice(k);
        % the cost is commission + bid/ask spread + slippage + overnight swap
        if strcmpi(tbl_i.code{k},'audusd')
            costs(k) = 2.6/(px_k*1e5) + 2*1e-5/px_k + nslippage*2*1e-5/px_k; 
        elseif strcmpi(tbl_i.code{k},'eurusd')
            costs(k) = 2.6/(px_k*1e5) + 1*1e-5/px_k + nslippage*2*1e-5/px_k;
        elseif strcmpi(tbl_i.code{k},'gbpusd')
            costs(k) = 2.6/(px_k*1e5) + 2*1e-5/px_k + nslippage*2*1e-5/px_k;
        elseif strcmpi(tbl_i.code{k},'usdcad')
            costs(k) = 2.6/1e5 + 3*1e-5/px_k + nslippage*2*1e-5/px_k;
        elseif strcmpi(tbl_i.code{k},'usdchf')
            costs(k) = 2.6/1e5 + 3*1e-5/px_k + nslippage*2*1e-5/px_k;
        elseif strcmpi(tbl_i.code{k},'usdjpy')
            costs(k) = 2.6/1e5 + 0.02/px_k + nslippage*2*1e-3/px_k;
        elseif strcmpi(tbl_i.code{k},'xauusd')
            costs(k) = 10/(px_k*1e2) + 0.15/px_k + nslippage*2*1e-2/px_k;
        end
    end


    pnl_i = (tbl_i.pnlrel - costs).* weights * balance * leverage;
    % aggregate the pnl into days
    [dts,~,idx] = unique(floor(datenum(tbl_i.closedatetime,'yyyy-mm-dd HH:MM')));
    pnl_daily_i = zeros(length(dts),1);
    for k = 1:length(dts)
        pnl_daily_i(k) = sum(pnl_i(idx == k));
    end

    res.pnlpertrade = pnl_i;
    res.pnldaily = [dts,pnl_daily_i];

    idxstart = find(dts >= dateadd(dts(1),'1y'),1,'first');
    ndts = length(dts);
    annualret_rolling = zeros(ndts-idxstart+1,1);
    for i = 1:length(annualret_rolling)
        annualret_rolling(i) = sum(pnl_daily_i(i:i+idxstart-1));
    end

    output_trade = kellyratio2(pnl_i);
    output_daily = kellyratio2(pnl_daily_i);
    
    res.w = output_trade.w;
    res.r = output_trade.r;
    res.winavgtrade = output_trade.winavg;
    res.lossavgtrade = output_trade.lossavg;
    res.winavgdaily = output_daily.winavg;
    res.lossavgdaily = output_daily.lossavg;
    res.totalret = output_daily.totalpl / balance;
    res.annualret = output_daily.totalpl / (dts(end)-dts(1)) * 365;
    res.annualretmax = max(annualret_rolling);
    res.annualretmin = min(annualret_rolling);
    res.sharp = output_daily.sharp * sqrt(260);
    res.mdddaily = output_daily.maxdrawdown;
    res.mddtrade = output_trade.maxdrawdown;



end

