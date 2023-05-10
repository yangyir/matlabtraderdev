function [tblb_headers,tblb_data,tbls_headers,tbls_data,data,tradesb,tradess,validtradesb,validtradess,kellyb,kellys] = fractal_gettradesummary(code,varargin)
%20220725:add outputs validtradesb and validtradess for long/short 
%trades with useflag 1 only
%
%20230412:add outpust kellyb and kellys for Kelly Criterion of long/short
%trades with all open signal modes
[isequity,equitytype] = isinequitypool(code);

if isequity
    if equitytype == 1 || equitytype == 2   
        ticksize = 0.001;
    else
        ticksize = 0.01;
    end
else
    if strcmpi(code,'gzhy')
        ticksize = 0.0001;
    else
        try
            fut = code2instrument(code);
            ticksize = fut.tick_size;
        catch
            error('fractal_gettradesummary:invalid code input')
        end
    end
end
%
p = inputParser;
p.CaseSensitive = false;p.KeepUnmatched = true;
p.addParameter('frequency','daily',@ischar);
p.addParameter('usefractalupdate',1,@isnumeric);
p.addParameter('usefibonacci',1,@isnumeric);
p.addParameter('direction','both',@ischar);
p.addParameter('fromdate',{},@(x) validateattributes(x,{'char','numeric'},{},'','fromdate'));
p.addParameter('todate',{},@(x) validateattributes(x,{'char','numeric'},{},'','fromdate'));
p.parse(varargin{:});
checkfreq = p.Results.frequency;
usefractalupdateflag = p.Results.usefractalupdate;
usefibonacciflag = p.Results.usefibonacci;
directionin = p.Results.direction;
if strcmpi(directionin,'long')
    flag = 1;
elseif strcmpi(directionin,'short')
    flag = -1;
elseif strcmpi(directionin,'both')
    flag = 0;
else
    error('fractal_gettradesummary:invalid direction input')
end
dt1 = p.Results.fromdate;
dt2 = p.Results.todate;
if isempty(dt1), dt1 = '';end
if isempty(dt2), dt2 = '';end

if strcmpi(checkfreq,'intraday')
    if flag == 0
        [tblb,~,tradesb,~,resstruct] = fractal_intraday_checker(code,...
            'type','all','direction',1,'plot',false,...
            'usefractalupdate',usefractalupdateflag,...
            'usefibonacci',usefibonacciflag,...
            'fromdate',dt1,...
            'todate',dt2);
        [~,tbls,tradess,~,~] = fractal_intraday_checker(code,...
            'type','all','direction',-1,'plot',false,...
            'usefractalupdate',usefractalupdateflag,...
            'usefibonacci',usefibonacciflag,...
            'fromdate',dt1,...
            'todate',dt2);
    elseif flag == 1
        [tblb,~,tradesb,~,resstruct] = fractal_intraday_checker(code,...
            'type','all','direction',1,'plot',false,...
            'usefractalupdate',usefractalupdateflag,...
            'usefibonacci',usefibonacciflag,...
            'fromdate',dt1,...
            'todate',dt2);
        tbls = {};
        tradess = cTradeOpenArray;
    elseif flag == -1
        tblb = {};
        tradesb = cTradeOpenArray;
         [~,tbls,tradess,~,resstruct] = fractal_intraday_checker(code,...
            'type','all','direction',-1,'plot',false,...
            'usefractalupdate',usefractalupdateflag,...
            'usefibonacci',usefibonacciflag,...
            'fromdate',dt1,...
            'todate',dt2);
    end
else
    if flag == 0
        [tblb,~,tradesb,~,resstruct] = fractal_daily_checker(code,...
                'type','all','direction',1,'plot',false,...
                'usefractalupdate',usefractalupdateflag,...
                'usefibonacci',usefibonacciflag,...
                'fromdate',dt1,...
                'todate',dt2);
        [~,tbls,tradess,~,~] = fractal_daily_checker(code,...
                'type','all','direction',-1,'plot',false,...
                'usefractalupdate',usefractalupdateflag,...
                'usefibonacci',usefibonacciflag,...
                'fromdate',dt1,...
                'todate',dt2);
    elseif flag == 1
        [tblb,~,tradesb,~,resstruct] = fractal_daily_checker(code,...
                'type','all','direction',1,'plot',false,...
                'usefractalupdate',usefractalupdateflag,...
                'usefibonacci',usefibonacciflag,...
                'fromdate',dt1,...
                'todate',dt2);
        tbls = {};
        tradess = cTradeOpenArray;
    elseif flag == -1
        tblb = {};
        tradesb = cTradeOpenArray;
        [~,tbls,tradess,~,resstruct] = fractal_daily_checker(code,...
                'type','all','direction',-1,'plot',false,...
                'usefractalupdate',usefractalupdateflag,...
                'usefibonacci',usefibonacciflag,...
                'fromdate',dt1,...
                'todate',dt2);
    end
end
    
data = resstruct{1};

nbtrades = tradesb.latest_;
nstrades = tradess.latest_;
tblbtrades = cell(nbtrades,28);
tblstrades = cell(nstrades,28);

for i = 1:tradesb.latest_
    trade_i = tradesb.node_(i);
    extrainfo = fractal_genextrainfo(resstruct{1},trade_i.id_);
    tdsqmomentum = tdsq_momentum(extrainfo.p,extrainfo.bs,extrainfo.ss,extrainfo.lvlup,extrainfo.lvldn);
    if strcmpi(trade_i.opensignal_.frequency_,'daily')
        status = fractal_b1_status(2,extrainfo,ticksize);
    else
        status = fractal_b1_status(4,extrainfo,ticksize);
    end
    tblbtrades{i,1} = resstruct{1}.px(trade_i.id_,1);   %time
    tblbtrades{i,2} = trade_i.code_;            %code
    tblbtrades{i,3} = trade_i.id_;              %id
    tblbtrades{i,4} = 1;                        %direction
    tblbtrades{i,5} = trade_i.openprice_;       %open price
    %pnl:use running pnl if closed pnl is not available
    if ~isempty(trade_i.closepnl_)
        tblbtrades{i,6} = trade_i.closepnl_;
    else
        tblbtrades{i,6} = trade_i.runningpnl_;
    end
    tblbtrades{i,7} = trade_i.closestr_;        %closestr
    try
        tblbtrades{i,8} = find(resstruct{1}.px(:,1)>=trade_i.closedatetime1_,1,'first');
    catch
        tblbtrades{i,8} = [];
    end
    tblbtrades{i,9} = tdsqmomentum;             %TDSQ-Momentum
    fldnamesb = fieldnames(status);
    for k = 1:length(fldnamesb)
        tblbtrades{i,9+k} = status.(fldnamesb{k});
    end
end
%
for i = 1:tradess.latest_
    trade_i = tradess.node_(i);
    extrainfo = fractal_genextrainfo(resstruct{1},trade_i.id_);
    tdsqmomentum = tdsq_momentum(extrainfo.p,extrainfo.bs,extrainfo.ss,extrainfo.lvlup,extrainfo.lvldn);
    if strcmpi(trade_i.opensignal_.frequency_,'daily')
        status = fractal_s1_status(2,extrainfo,ticksize);
    else
        status = fractal_s1_status(4,extrainfo,ticksize);
    end
    tblstrades{i,1} = resstruct{1}.px(trade_i.id_,1);   %time
    tblstrades{i,2} = trade_i.code_;            %code
    tblstrades{i,3} = trade_i.id_;              %id
    tblstrades{i,4} = -1;                       %direction
    tblstrades{i,5} = trade_i.openprice_;
    %pnl:use running pnl if closed pnl is not available
    if ~isempty(trade_i.closepnl_)
        tblstrades{i,6} = trade_i.closepnl_;
    else
        tblstrades{i,6} = trade_i.runningpnl_;
    end
    tblstrades{i,7} = trade_i.closestr_;        %closestr
    try
        tblstrades{i,8} = find(resstruct{1}.px(:,1)>=trade_i.closedatetime1_,1,'first');
    catch
        tblstrades{i,8} = [];
    end
    tblstrades{i,9} = tdsqmomentum;             %TDSQ-Momentum
    fldnamess = fieldnames(status);
    for k = 1:length(fldnamess)
        tblstrades{i,9+k} = status.(fldnamess{k});
    end
end
%
%ouput
if ~isempty(tblb)
    n1 = length(tblb{1}.Properties.VariableNames);
    n2 = size(tblbtrades,2);
    tblb_headers = cell(1,n1+n2);
    if ~isempty(tbls)
        tbls_headers = cell(1,n1+n2);
    else
        tbls_headers = {};
    end
    tblb_data = cell(length(tblb{1}.idx),n1+n2);
    if ~isempty(tbls)
        tbls_data = cell(length(tbls{1}.idx),n1+n2);
    else
        tbls_data = {};
    end
else
    n1 = length(tbls{1}.Properties.VariableNames);
    n2 = size(tblstrades,2);
    tblb_headers = {};
    tbls_headers = cell(1,n1+n2);
    tblb_data = {};
    tbls_data = cell(length(tbls{1}.idx),n1+n2);
end


for i = 1:n1
    if ~isempty(tblb)
        tblb_headers{1,i} = tblb{1}.Properties.VariableNames{i};
    end
    if ~isempty(tbls)
        tbls_headers{1,i} = tbls{1}.Properties.VariableNames{i};
    end
    if ~isempty(tblb)
        for j = 1:length(tblb{1}.idx)
            try
                tblb_data{j,i} = tblb{1}.(tblb{1}.Properties.VariableNames{i}){j,1};
            catch
                tblb_data{j,i} = tblb{1}.(tblb{1}.Properties.VariableNames{i})(j,1);
            end
        end
    end
    %
    if ~isempty(tbls)
        for j = 1:length(tbls{1}.idx)
            try
                tbls_data{j,i} = tbls{1}.(tbls{1}.Properties.VariableNames{i}){j,1};
            catch
                tbls_data{j,i} = tbls{1}.(tbls{1}.Properties.VariableNames{i})(j,1);
            end
        end
    end
end

if ~isempty(tblb)
    itrade = 0;
    for i = 1:length(tblb{1}.idx)
        if isempty(tblb{1}.commentsb1{i}) || ...
                (~isempty(tblb{1}.commentsb1{i}) && tblb{1}.useflag(i))
            itrade = itrade+1;
            if itrade > size(tblbtrades,1), break;end
            for j = 1:n2
                tblb_data{i,j+n1} = tblbtrades{itrade,j};
            end
        end
    end
end
%
if ~isempty(tbls)
    itrade = 0;
    for i = 1:length(tbls{1}.idx)
        if isempty(tbls{1}.commentss1{i})
            itrade = itrade+1;
            if itrade > size(tblstrades,1), break;end
            for j = 1:n2
                tbls_data{i,j+n1} = tblstrades{itrade,j};
            end
        end
    end
end
%
if ~isempty(tblb)
    tblb_headers{1,n1+1} = 'time';
    tblb_headers{1,n1+2} = 'code';
    tblb_headers{1,n1+3} = 'id';
    tblb_headers{1,n1+4} = 'direction';
    tblb_headers{1,n1+5} = 'openprice';
    tblb_headers{1,n1+6} = 'closepnl';
    tblb_headers{1,n1+7} = 'closestr';
    tblb_headers{1,n1+8} = 'idclose';
    tblb_headers{1,n1+9} = 'tdsqmomentum';
end
if ~isempty(tbls)
    tbls_headers{1,n1+1} = 'time';
    tbls_headers{1,n1+2} = 'code';
    tbls_headers{1,n1+3} = 'id';
    tbls_headers{1,n1+4} = 'direction';
    tbls_headers{1,n1+5} = 'openprice';
    tbls_headers{1,n1+6} = 'closepnl';
    tbls_headers{1,n1+7} = 'closestr';
    tbls_headers{1,n1+8} = 'idclose';
    tbls_headers{1,n1+9} = 'tdsqmomentum';
end

for i = 1:n2-9
    try
        if ~isempty(tblb)
            tblb_headers{1,i+n1+9} = fldnamesb{i};
        end
        if ~isempty(tbls)
            tbls_headers{1,i+n1+9} = fldnamess{i};
        end
    catch
    end
end
%
%
nb = size(tblb_data,1);ns = size(tbls_data,1);
tradebidx = 0;tradesidx = 0;
nvalidltrade = 0;nvalidstrade = 0;
validtradesb = cTradeOpenArray;validtradess = cTradeOpenArray;

for i = 1:nb
    if isempty(tblb_data{i,10})
        tradebidx = tradebidx + 1;
        if tradebidx > tradesb.latest_, break;end
    else
        continue;
    end
    if tblb_data{i,9} == 1
        nvalidltrade = nvalidltrade + 1;
        validtradesb.push(tradesb.node_(tradebidx));
    end
end
%
for i = 1:ns
    if isempty(tbls_data{i,10})
        tradesidx = tradesidx + 1;
        if tradesidx > tradess.latest_, break;end
    else
        continue;
    end
    if tbls_data{i,9} == 1
        nvalidstrade = nvalidstrade + 1;
        validtradess.push(tradess.node_(tradesidx));
    end
end
%
% calculate kellyb and kellys
instrument = code2instrument(code);
if isempty(instrument.contract_size)
    contractsize = 100;
else
    contractsize = instrument.contract_size;
end
%
if ~isempty(tblb_data)
    opensignal_mode = tblb_data(:,11);
    opensignal_mode_unique = unique(opensignal_mode);
    outputstats = cell(length(opensignal_mode_unique),7);
    for j = 1:length(opensignal_mode_unique)
        this_mode = opensignal_mode_unique{j};
        idx = strcmpi(opensignal_mode,this_mode);
        tbl_this_mode = tblb_data(idx,:);
        wincount = 0;
        losscount = 0;
        wintotalpnl = 0;
        losstotalpnl = 0;
        for k = 1:size(tbl_this_mode,1)
            if tbl_this_mode{k,18} >= 0
                wincount = wincount + 1;
                wintotalpnl = wintotalpnl + tbl_this_mode{k,18}/tbl_this_mode{k,17}/contractsize;
            elseif tbl_this_mode{k,18} < 0
                losscount = losscount + 1;
                losstotalpnl = losstotalpnl + tbl_this_mode{k,18}/tbl_this_mode{k,17}/contractsize;
            end
        end
        winprob = wincount / (wincount + losscount);
        if wincount + losscount == 0, winprob = 0;end
        if wincount == 0
            winavgpnl = 0;
        else
            winavgpnl = wintotalpnl / wincount;
        end
        if losscount == 0
            lossavgpnl = 0;
        else
            lossavgpnl = losstotalpnl / losscount;
        end
        R = abs(winavgpnl/lossavgpnl);
        if winprob == 1
            kratio = 1;
            lossavgpnl = 0;
        else
            kratio = winprob - (1 - winprob)/R;
        end
        outputstats{j,1} = this_mode;
        outputstats{j,2} = wincount + losscount;
        outputstats{j,3} = winprob;
        outputstats{j,4} = winavgpnl;
        outputstats{j,5} = lossavgpnl;
        outputstats{j,6} = kratio;
        outputstats{j,7} = code;
    end
    OpenSignal = outputstats(:,1);
    NumOfTrades = outputstats(:,2);
    WinProb = outputstats(:,3);
    WinAvgPnL = outputstats(:,4);
    LossAvgPnL = outputstats(:,5);
    KellyRatio = outputstats(:,6);
    Code = outputstats(:,7);
    kellyb = table(OpenSignal,NumOfTrades,WinProb,WinAvgPnL,LossAvgPnL,KellyRatio,Code);
else
    kellyb = {};
end
%
%
if ~isempty(tbls_data)
    opensignal_mode = tbls_data(:,11);
    opensignal_mode_unique = unique(opensignal_mode);
    outputstats = cell(length(opensignal_mode_unique),7);
    for j = 1:length(opensignal_mode_unique)
        this_mode = opensignal_mode_unique{j};
        idx = strcmpi(opensignal_mode,this_mode);
        tbl_this_mode = tbls_data(idx,:);
        wincount = 0;
        losscount = 0;
        wintotalpnl = 0;
        losstotalpnl = 0;
        for k = 1:size(tbl_this_mode,1)
            if tbl_this_mode{k,18} >= 0
                wincount = wincount + 1;
                wintotalpnl = wintotalpnl + tbl_this_mode{k,18}/tbl_this_mode{k,17}/contractsize;
            elseif tbl_this_mode{k,18} < 0
                losscount = losscount + 1;
                losstotalpnl = losstotalpnl + tbl_this_mode{k,18}/tbl_this_mode{k,17}/contractsize;
            end
        end
        winprob = wincount / (wincount + losscount);
        if wincount + losscount == 0, winprob = 0;end
        if wincount == 0
            winavgpnl = 0;
        else
            winavgpnl = wintotalpnl / wincount;
        end
        if losscount == 0
            lossavgpnl = 0;
        else
            lossavgpnl = losstotalpnl / losscount;
        end
        R = abs(winavgpnl/lossavgpnl);
        if winprob == 1
            kratio = 1;
            lossavgpnl = 0;
        else
            kratio = winprob - (1 - winprob)/R;
        end
        outputstats{j,1} = this_mode;
        outputstats{j,2} = wincount + losscount;
        outputstats{j,3} = winprob;
        outputstats{j,4} = winavgpnl;
        outputstats{j,5} = lossavgpnl;
        outputstats{j,6} = kratio;
        outputstats{j,7} = code;
    end
    OpenSignal = outputstats(:,1);
    NumOfTrades = outputstats(:,2);
    WinProb = outputstats(:,3);
    WinAvgPnL = outputstats(:,4);
    LossAvgPnL = outputstats(:,5);
    KellyRatio = outputstats(:,6);
    Code = outputstats(:,7);
    kellys = table(OpenSignal,NumOfTrades,WinProb,WinAvgPnL,LossAvgPnL,KellyRatio,Code);
else
    kellys = {};
end


