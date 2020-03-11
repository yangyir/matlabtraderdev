function [ tradesfractals1 ] = fractal_gentradess1( idxfractals1,px,HH,LL,bs,ss,varargin )
%FRACTAL_GENTRADESS1 Summary of this function goes here
%   Detailed explanation goes here
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('code','',@ischar);
    p.addParameter('freq','1d',@ischar);
    p.parse(varargin{:});
    code = p.Results.code;
    freq = p.Results.freq;
    
    variablenotused(ss);
    
    tradesfractals1 = cTradeOpenArray;
    for i = 1:size(idxfractals1,1)
        j = idxfractals1(i);
        if ~isempty(code)
            instrument = code2instrument(code);
            adj = instrument.tick_size;
        else
            adj = 0;
        end
        
        if LL(j)-px(j,5) <= adj, continue;end
        
        signalinfo = struct('name','fractal','hh',HH(j),'ll',LL(j),'frequency',freq);
        riskmanager = struct('hh0_',HH(j),'hh1_',HH(j),'ll0_',px(j,4),'ll1_',px(j,4),'type_','breachdn-S');
        tradenew = cTradeOpen('id',i,'opendatetime',px(j,1),'openprice',px(j,5),...
            'opendirection',-1,'openvolume',1,'code',code);
        tradenew.status_ = 'set';
        tradenew.setsignalinfo(signalinfo);
        tradenew.setriskmanager('name','spiderman','extrainfo',riskmanager);
        if bs(j) >= 9
            bsreached = bs(j);
            tradenew.riskmanager_.tdlow_ = min(px(j-bsreached+1:j,4));
            tdidx = find(px(j-bsreached+1:end,4)==tradenew.riskmanager_.tdlow_,1,'last')+j-bsreached;
            tradenew.riskmanager_.tdhigh_ = px(tdidx,3);
            if tradenew.riskmanager_.tdhigh_ + (tradenew.riskmanager_.tdhigh_-tradenew.riskmanager_.tdlow_) < tradenew.riskmanager_.pxstoploss_
                tradenew.riskmanager_.pxstoploss_ = tradenew.riskmanager_.tdhigh_ + (tradenew.riskmanager_.tdhigh_-tradenew.riskmanager_.tdlow_);
            end
        end
        tradesfractals1.push(tradenew);
    end

end

