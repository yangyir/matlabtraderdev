function [ret] = fractal_tradeinfo_lastb(varargin)
% fractal utility function
% to check the last (BUY) trade information, i.e. open signal, live 
% or closed condition
p = inputParser;
p.CaseSensitive = false;p.KeepUnmatched = true;
p.addParameter('code','',@ischar);
p.addParameter('extrainfo','',@isstruct);
p.addParameter('frequency','daily',@ischar);
p.addParameter('usefractalupdate',1,@isnumeric);
p.addParameter('usefibonacci',1,@isnumeric);
p.parse(varargin{:});
code = p.Results.code;
ei = p.Results.extrainfo;
freq = p.Results.frequency;
usefracalupdateflag = p.Results.usefractalupdate;
usefibonacciflag = p.Results.usefibonacci;

if strcmpi(freq,'daily')
    nfractal = 2;
else
    if strcmpi(freq,'intraday-30m') || strcmpi(freq,'intraday')
        nfractal = 4;
    elseif strcmpi(freq,'intraday-15m')
        nfractal = 4;
    elseif strcmpi(freq,'intraday-5m')
        nfractal = 6;
    else
        error('fractal_tradeinfo_anyb:invalud frequency input')
    end
end

asset = code2instrument(code);

[idxb1,~] = fractal_genindicators1(ei.px,...
            ei.hh,ei.ll,...
            ei.jaw,ei.teeth,ei.lips,...
            'instrument',asset);
b1type = idxb1(end,2);
%do nothing if it was a weak breach
if b1type == 1
    ret.status = 'n/a';
    ret.opensignal = 'invalid weak breach';
    ret.trade = [];
    return;
end
j = idxb1(end,1);
d = fractal_truncate(ei,j);
op = fractal_filterb1_singleentry(b1type,nfractal,d,asset.tick_size); 
statusstruct = fractal_b1_status(nfractal,d,asset.tick_size);
statusstr = fractal_b1_status2str(statusstruct);

if op.use || (~op.use && statusstruct.istrendconfirmed)
    trade = fractal_gentrade(ei,code,j,op.comment,1,'daily');
    trade.riskmanager_.setusefractalupdateflag(usefracalupdateflag);
    trade.riskmanager_.setusefibonacciflag(usefibonacciflag);
    ret.opensignal = statusstr;
else
    ret.status = 'n/a';
    ret.opensignal = ['invalid ',op.comment];
    ret.trade = [];
    return
end
% run trade with historical data
unwindtrade = {};
for k = j+1:size(ei.px,1)
    if strcmpi(trade.status_,'closed'),break;end
    ei_k = fractal_truncate(ei,k);
    if k == size(ei.px,1)
        ei_k.latestopen = ei.px(k,5);
        ei_k.latestdt = ei.px(k,1);
    else
        ei_k.latestopen = ei.px(k+1,2);
        ei_k.latestdt = ei.px(k+1,1);
    end
    unwindtrade = trade.riskmanager_.riskmanagementwithcandle([],...
        'usecandlelastonly',false,...
        'debug',false,...
        'updatepnlforclosedtrade',true,...
        'extrainfo',ei_k);
    if ~isempty(unwindtrade), break;end
end

if isempty(unwindtrade)
    ret.status = 'live';
else
    ret.status = ['closed:',trade.riskmanager_.closestr_];
end

ret.trade = trade;


end

