function [ret] = fractal_tradeinfo_last(varargin)
% fractal utility function
% to check the last trade information, i.e. open signal, live or closed
% condtion
p = inputParser;
p.CaseSensitive = false;p.KeepUnmatched = true;
p.addParameter('code','',@ischar);
p.addParameter('extrainfo','',@isstruct);
p.addParameter('frequency','daily',@ischar);
p.addParameter('repeat',true,@islogical);
p.parse(varargin{:});
code = p.Results.code;
ei = p.Results.extrainfo;
freq = p.Results.frequency;
repeatflag = p.Results.repeat;

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

[idxb1,idxs1] = fractal_genindicators1(ei.px,...
            ei.hh,ei.ll,...
            ei.jaw,ei.teeth,ei.lips,...
            'instrument',asset);
idxb1 = [idxb1,ones(size(idxb1,1),1)];
idxs1 = [idxs1,-ones(size(idxs1,1),1)];
idx = [idxb1;idxs1];
idx = sortrows(idx);
lastbidx = find(idx(:,end) == 1,1,'last');
lastsidx = find(idx(:,end) == -1,1,'last');
if lastbidx > lastsidx
    ret.opendirection = 'long';
    b1type = idx(lastbidx,2);
    if b1type == 1
        ret.status = 'n/a';
        ret.opensignal = 'invalid weak long breach';
        ret.trade = [];
        return
    end
    j = idx(lastbidx,1);
    d = fractal_truncate(ei,j);
    op = fractal_filterb1_singleentry(b1type,nfractal,d,asset.tick_size); 
    statusstruct = fractal_b1_status(nfractal,d,asset.tick_size);
    statusstr = fractal_b1_status2str(statusstruct);
    
    if op.use || (~op.use && statusstruct.istrendconfirmed)
        trade = fractal_gentrade(ei,code,j,op.comment,1,'daily');
        if strcmpi(statusstr,'mediumbreach-trendbreak') || ...
                strcmpi(statusstr,'strongbreach-trendbreak')
            ret.opensignal = op.comment;
        else
            ret.opensignal = statusstr;
        end
    else
        ret.status = 'n/a';
        ret.opensignal = ['invalid long ',op.comment];
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
        ret.status = ['long closed:',trade.riskmanager_.closestr_];
    end
    ret.trade = trade;
elseif lastbidx < lastsidx
    ret.opendirection = 'short';
    s1type = idx(lastsidx,2);
    if s1type == 1
        ret.status = 'n/a';
        ret.opensignal = 'invalid weak short breach';
        ret.trade = [];
        return
    end
    j = idx(lastsidx,1);
    d = fractal_truncate(ei,j);
    op = fractal_filters1_singleentry(s1type,nfractal,d,asset.tick_size); 
    statusstruct = fractal_s1_status(nfractal,d,asset.tick_size);
    statusstr = fractal_s1_status2str(statusstruct);
    
    if op.use || (~op.use && statusstruct.istrendconfirmed)
        trade = fractal_gentrade(ei,code,j,op.comment,-1,'daily');
        if strcmpi(statusstr,'mediumbreach-trendbreak') || ...
                strcmpi(statusstr,'strongbreach-trendbreak')
            ret.opensignal = op.comment;
        else
            ret.opensignal = statusstr;
        end
    else
        ret.status = 'n/a';
        ret.opensignal = ['invalid short ',op.comment];
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
        ret.status = ['short closed:',trade.riskmanager_.closestr_];
    end
    ret.trade = trade;
else
    error('internal error')
end

end