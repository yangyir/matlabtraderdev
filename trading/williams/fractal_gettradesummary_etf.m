function [tblb_headers,tblb_data,data,tradesb] = fractal_gettradesummary_etf(code,cp,nfractal)
% 
ticksize = 0.001;
    
[tblb,tradesb,~,resstruct] = fractal_filter_etf(code,cp,nfractal,'all',1,false);
%
%backtest trade performance
n = tradesb.latest_;
pnl = cell(n,2);
for i = 1:n
    trade = tradesb.node_(i);
    j = trade.id_;
    d = resstruct;
    %
    for k = j+1:size(d.px,1)
        extrainfo = fractal_genextrainfo(d,k);
        if k == size(d.px,1)
            extrainfo.latestopen = d.px(k,5);
        else
            extrainfo.latestopen = d.px(k+1,2);
        end
        if strcmpi(trade.status_,'closed'),break;end
        tradeout = trade.riskmanager_.riskmanagementwithcandle([],...
            'usecandlelastonly',false,...
            'debug',false,...
            'updatepnlforclosedtrade',true,...
            'extrainfo',extrainfo);
        if ~isempty(tradeout)
            pnl{i,1} = tradeout.closepnl_;
            pnl{i,2} = tradeout.closestr_;
            break
        elseif isempty(tradeout) && k == size(d.px,1)
            pnl{i,1} = trade.runningpnl_;
            pnl{i,2} = 'timeseries limit reached';
        end
    end
end

data = resstruct.px;

nbtrades = tradesb.latest_;
tblbtrades = cell(nbtrades,25);

for i = 1:tradesb.latest_
    trade_i = tradesb.node_(i);
    extrainfo = fractal_genextrainfo(resstruct,trade_i.id_);
    tdsqmomentum = tdsq_momentum(extrainfo.p,extrainfo.bs,extrainfo.ss,extrainfo.lvlup,extrainfo.lvldn);
    status = fractal_b1_status(nfractal,extrainfo,ticksize);
    
    tblbtrades{i,1} = resstruct.px(trade_i.id_,1);   %time
    tblbtrades{i,2} = trade_i.code_;            %code
    tblbtrades{i,3} = trade_i.id_;              %id
    tblbtrades{i,4} = 1;                        %direction
    %pnl:use running pnl if closed pnl is not available
    if ~isempty(trade_i.closepnl_)
        tblbtrades{i,5} = trade_i.closepnl_;
    else
        tblbtrades{i,5} = trade_i.runningpnl_;
    end
    tblbtrades{i,6} = trade_i.closestr_;        %closestr
    try
        tblbtrades{i,7} = find(resstruct.px(:,1)>=trade_i.closedatetime1_,1,'first');
    catch
        tblbtrades{i,7} = [];
    end
    tblbtrades{i,8} = tdsqmomentum;             %TDSQ-Momentum
    fldnamesb = fieldnames(status);
    for k = 1:length(fldnamesb)
        tblbtrades{i,8+k} = status.(fldnamesb{k});
    end
end
%
%ouput
n1 = length(tblb.Properties.VariableNames);
n2 = size(tblbtrades,2);
tblb_headers = cell(1,n1+n2);
tblb_data = cell(length(tblb.idx),n1+n2);

for i = 1:n1
    tblb_headers{1,i} = tblb.Properties.VariableNames{i};
    for j = 1:length(tblb.idx)
        try
            tblb_data{j,i} = tblb.(tblb.Properties.VariableNames{i}){j,1};
        catch
            tblb_data{j,i} = tblb.(tblb.Properties.VariableNames{i})(j,1);
        end
    end
end
itrade = 0;
for i = 1:length(tblb.idx)
    if isempty(tblb.comments1{i})
        itrade = itrade+1;
        if itrade > size(tblbtrades,1), break;end
        for j = 1:n2
            tblb_data{i,j+n1} = tblbtrades{itrade,j};
        end
    end
end
%
tblb_headers{1,n1+1} = 'time';
tblb_headers{1,n1+2} = 'code';
tblb_headers{1,n1+3} = 'id';
tblb_headers{1,n1+4} = 'direction';
tblb_headers{1,n1+5} = 'closepnl';
tblb_headers{1,n1+6} = 'closestr';
tblb_headers{1,n1+7} = 'idclose';
tblb_headers{1,n1+8} = 'tdsqmomentum';
for i = 1:n2-8
    try
        tblb_headers{1,i+n1+8} = fldnamesb{i};
    catch
    end
end


