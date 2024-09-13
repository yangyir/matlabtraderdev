    function [ret] = fractal_tradeinfo_anys(varargin)
% fractal utility function
% to check any (SELL) trade information, i.e. open signal, status and
% parameter change during its life
%
p = inputParser;
p.CaseSensitive = false;p.KeepUnmatched = true;
p.addParameter('code','',@ischar);
p.addParameter('openid',[],@isnumeric);
p.addParameter('extrainfo','',@isstruct);
p.addParameter('frequency','daily',@ischar);
p.addParameter('debug',false,@islogical)
p.addParameter('plot',false,@islogical);
p.addParameter('usefractalupdate',1,@isnumeric);
p.addParameter('usefibonacci',1,@isnumeric);
p.parse(varargin{:});
code = p.Results.code;
openid = p.Results.openid;
ei = p.Results.extrainfo;
freq = p.Results.frequency;
debugflag = p.Results.debug;
plotflag = p.Results.plot;
usefracalupdateflag = p.Results.usefractalupdate;
usefibonacciflag = p.Results.usefibonacci;

if strcmpi(freq,'daily')
    nfractal = 2;
else
    if strcmpi(freq,'intraday') || strcmpi(freq,'intraday-30m')
        nfractal = 4;
    elseif strcmpi(freq,'intraday-15m')
        nfractal = 8;
    elseif strcmpi(freq,'intrday-5m')
        nfractal = 12;
    else
        error('fractal_tradeinfo_anys:invalid frequency input')
    end
end

asset = code2instrument(code);

[~,idxs1] = fractal_genindicators1(ei.px,...
            ei.hh,ei.ll,...
            ei.jaw,ei.teeth,ei.lips,...
            'instrument',asset);
idx = find(idxs1(:,1) == openid, 1);
if isempty(idx)
    ret = {};
    if debugflag
        fprintf('%s:invalid input openid as no open short signal was found then....\n',code);
    end
    return
end

s1type = idxs1(idx,2);
if s1type == 1
    ret = {};
    if debugflag
        fprintf('%s:invalid input openid as weak short signal was found then...\n',code);
    end
    return
end

d = fractal_truncate(ei,openid);
op = fractal_filters1_singleentry(s1type,nfractal,d,asset.tick_size);
statusstruct = fractal_s1_status(nfractal,d,asset.tick_size);
statusstr = fractal_s1_status2str(statusstruct);
% if op.use || (~op.use && statusstruct.istrendconfirmed)
    if strcmpi(freq,'daily')
        trade = fractal_gentrade(ei,code,openid,op.comment,-1,'daily');
    else
        trade = fractal_gentrade(ei,code,openid,op.comment,-1,'30m');
    end
    trade.riskmanager_.setusefractalupdateflag(usefracalupdateflag);
    trade.riskmanager_.setusefibonacciflag(usefibonacciflag);
    ret.opensignal = statusstr;
    ret.trade = trade;
% else
%     ret.opensignal = statusstr;
%     ret.trade = {};
%     if debugflag
%         fprintf('%s:invalid input openid as invalid breach signal was found then...\n',code);
%     end
%     return
% end
% run the trade with historical data
if debugflag
    fprintf('debug starts...\n');
    fprintf('%8s %8s %8s %8s %8s %10s %10s %8s %12s\n','code','date','price','tdhigh','tdlow','td13high','td13low','wad','pxstoploss');
    fprintf('%8s %8s %8.3f %8.3f %8.3f %10.3f %10.3f %8.3f %12.3f\n',...
        code,...
        datestr(ei.px(openid,1),'yymmdd'),...
        ei.px(openid,5),...
        trade.riskmanager_.tdhigh_,...
        trade.riskmanager_.tdlow_,...
        trade.riskmanager_.td13high_,...
        trade.riskmanager_.td13low_,...
        trade.riskmanager_.wadopen_,...
        trade.riskmanager_.pxstoploss_);
end
unwindtrade = {};
closeid = [];
if ~isempty(strfind(statusstr,'trendconfirmed'))
    checkstartid = openid;
else
    checkstartid = openid+1;
end

for k = checkstartid:size(ei.px,1)
    ei_k = fractal_truncate(ei,k);
    if k == size(ei.px,1)
        ei_k.latestopen = ei.px(k,5);
        ei_k.latestdt = ei.px(k,1);
    else
        ei_k.latestopen = ei.px(k+1,2);
        ei_k.latestdt = ei.px(k+1,1);
    end
    if strcmpi(trade.status_,'closed'),break;end
    %
    runflag = false;
    if trade.oneminb4close1_ == 914
        %govtbond
        if strcmpi(freq,'intraday-30m') || strcmpi(freq,'intraday')
            if hour(ei_k.px(end,1)) == 15, runflag = true;end
        elseif strcmpi(freq,'intraday-15m')
            if hour(ei_k.px(end,1)) == 15, runflag = true;end
        elseif strcmpi(freq,'intraday-5m')
            if hour(ei_k.px(end,1)) == 15 && minute(ei_k.px(end,1)) == 10, runflag = true;end
        end
    elseif trade.oneminb4close1_ == 899 && isnan(trade.oneminb4close2_)
        if ~(strcmpi(freq,'intraday-30m') || strcmpi(freq,'intraday')), error('fractal_tradeinfo_anys:invalid freq input....');end
        if hour(ei_k.px(end,1)) == 14 && minute(ei_k.px(end,1)) == 30, runflag = true;end
    elseif trade.oneminb4close1_ == 899 && trade.oneminb4close2_ == 1379
        if ~(strcmpi(freq,'intraday-30m') || strcmpi(freq,'intraday')), error('fractal_tradeinfo_anys:invalid freq input....');end
        if (hour(ei_k.px(end,1)) == 14 && minute(ei_k.px(end,1)) == 30) || ...
                (hour(ei_k.px(end,1)) == 22 && minute(ei_k.px(end,1)) == 30)
            runflag = true;
        end
    elseif trade.oneminb4close1_ == 899 && trade.oneminb4close2_ == 59
        if ~(strcmpi(freq,'intraday-30m') || strcmpi(freq,'intraday')), error('fractal_tradeinfo_anys:invalid freq input....');end
        if (hour(ei_k.px(end,1)) == 14 && minute(ei_k.px(end,1)) == 30) || ...
                (hour(ei_k.px(end,1)) == 0 && minute(ei_k.px(end,1)) == 30)
            runflag = true;
        end
    elseif trade.oneminb4close1_ == 899 && trade.oneminb4close2_ == 149
        if ~(strcmpi(freq,'intraday-30m') || strcmpi(freq,'intraday')), error('fractal_tradeinfo_anys:invalid freq input....');end
        if (hour(ei_k.px(end,1)) == 14 && minute(ei_k.px(end,1)) == 30) || ...
                (hour(ei_k.px(end,1)) == 2 && minute(ei_k.px(end,1)) == 30)
            runflag = true;
        end
    end
    
    %here we only check whether it is a long holiday afterwards
    if runflag && hour(ei_k.px(end,1)) <= 15
        lastbd = floor(ei_k.px(end,1));
        nextbd = dateadd(lastbd,'1b');
        if nextbd - lastbd > 3
            runflag = true;
        else
            runflag = false;
        end
    end
    
    unwindtrade = trade.riskmanager_.riskmanagementwithcandle([],...
        'usecandlelastonly',false,...
        'debug',false,...
        'updatepnlforclosedtrade',true,...
        'extrainfo',ei_k,...
        'RunRiskManagementBeforeMktClose',runflag);
    
    if debugflag
        fprintf('%8s %8s %8.3f %8.3f %8.3f %10.3f %10.3f %8.3f %12.3f\n',...
            code,...
            datestr(ei.px(k,1),'yymmdd'),...
            ei.px(k,5),...
            trade.riskmanager_.tdhigh_,...
            trade.riskmanager_.tdlow_,...
            trade.riskmanager_.td13high_,...
            trade.riskmanager_.td13low_,...
            ei_k.wad(k),...
            trade.riskmanager_.pxstoploss_);
    end
    if ~isempty(unwindtrade)
        closeid = find(ei.px(:,1) == unwindtrade.closedatetime1_,1,'first');
        break;
    end            
end

ret.openid = openid;
ret.closeid = closeid;

if debugflag
    fprintf('debug ends...\n');
end
if isempty(unwindtrade)
    ret.status = 'live';
else
    ret.status = ['closed:',trade.riskmanager_.closestr_];
    ret.closeprice = trade.closeprice_;
end

if plotflag
    set(0,'DefaultFigureWindowStyle','docked');
    if isempty(closeid)
        ei_plot = fractal_truncate(ei,size(ei.px,1),openid-13);
    else
        ei_plot = fractal_truncate(ei,min(closeid+5,size(ei.px,1)),openid-13);
    end
    tools_technicalplot2(ei_plot,2,code,true);
end

end