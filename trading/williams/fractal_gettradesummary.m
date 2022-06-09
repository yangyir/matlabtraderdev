function [tblb_headers,tblb_data,tbls_headers,tbls_data,data,tradesb,tradess] = fractal_gettradesummary(code,varargin)
%
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

if nargin > 1
    check_freq = varargin{1};
else
    check_freq = 'intraday';
end

if strcmpi(check_freq,'intraday')
    [tblb,~,tradesb,~,resstruct] = fractal_intraday_checker(code,...
            'type','all','direction',1,'plot',false);
    [~,tbls,tradess,~,~] = fractal_intraday_checker(code,...
            'type','all','direction',-1,'plot',false);
else
    [tblb,~,tradesb,~,resstruct] = fractal_daily_checker(code,...
            'type','all','direction',1,'plot',false);
    [~,tbls,tradess,~,~] = fractal_daily_checker(code,...
            'type','all','direction',-1,'plot',false);
end
    
data = resstruct{1};

nbtrades = tradesb.latest_;
nstrades = tradess.latest_;
tblbtrades = cell(nbtrades,26);
tblstrades = cell(nstrades,26);

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
n1 = length(tblb{1}.Properties.VariableNames);
n2 = size(tblbtrades,2);
tblb_headers = cell(1,n1+n2);tbls_headers = cell(1,n1+n2);
tblb_data = cell(length(tblb{1}.idx),n1+n2);tbls_data = cell(length(tbls{1}.idx),n1+n2);

for i = 1:n1
    tblb_headers{1,i} = tblb{1}.Properties.VariableNames{i};
    tbls_headers{1,i} = tbls{1}.Properties.VariableNames{i};
    for j = 1:length(tblb{1}.idx)
        try
            tblb_data{j,i} = tblb{1}.(tblb{1}.Properties.VariableNames{i}){j,1};
        catch
            tblb_data{j,i} = tblb{1}.(tblb{1}.Properties.VariableNames{i})(j,1);
        end
    end
    %
    for j = 1:length(tbls{1}.idx)
        try
            tbls_data{j,i} = tbls{1}.(tbls{1}.Properties.VariableNames{i}){j,1};
        catch
            tbls_data{j,i} = tbls{1}.(tbls{1}.Properties.VariableNames{i})(j,1);
        end
    end
end
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
%
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
%
tblb_headers{1,n1+1} = 'time';tbls_headers{1,n1+1} = 'time';
tblb_headers{1,n1+2} = 'code';tbls_headers{1,n1+2} = 'code';
tblb_headers{1,n1+3} = 'id';tbls_headers{1,n1+3} = 'id';
tblb_headers{1,n1+4} = 'direction';tbls_headers{1,n1+4} = 'direction';
tblb_headers{1,n1+5} = 'openprice';tbls_headers{1,n1+5} = 'openprice';
tblb_headers{1,n1+6} = 'closepnl';tbls_headers{1,n1+6} = 'closepnl';
tblb_headers{1,n1+7} = 'closestr';tbls_headers{1,n1+7} = 'closestr';
tblb_headers{1,n1+8} = 'idclose';tbls_headers{1,n1+8} = 'idclose';
tblb_headers{1,n1+9} = 'tdsqmomentum';tbls_headers{1,n1+9} = 'tdsqmomentum';
for i = 1:n2-9
    try
        tblb_headers{1,i+n1+9} = fldnamesb{i};
        tbls_headers{1,i+n1+9} = fldnamess{i};
    catch
    end
end


