function [ tradesfractalb1 ] = fractal_gentradesb1( idxfractalb1,px,HH,LL,bs,ss,varargin )
%FRACTAL_GENTRADESB1 Summary of this function goes here
%   Detailed explanation goes here
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('code','',@ischar);
    p.addParameter('freq','1d',@ischar);
    p.parse(varargin{:});
    code = p.Results.code;
    freq = p.Results.freq;
    
    variablenotused(bs);
    
    tradesfractalb1 = cTradeOpenArray;
    for i = 1:size(idxfractalb1,1)
        j = idxfractalb1(i);
        signalinfo = struct('name','fractal','hh',HH(j),'ll',LL(j),'frequency',freq);
        riskmanager = struct('hh0_',HH(j),'hh1_',HH(j),'ll0_',LL(j),'ll1_',LL(j),'type_','breachup-B');
        tradenew = cTradeOpen('id',i,'opendatetime',px(j,1),'openprice',px(j,5),...
            'opendirection',1,'openvolume',1,'code',code);
        tradenew.status_ = 'set';
        tradenew.setsignalinfo(signalinfo);
        tradenew.setriskmanager('name','spiderman','extrainfo',riskmanager);
        if ss(j) >= 9
            ssreached = ss(j);
            tradenew.riskmanager_.tdhigh_ = max(px(j-ssreached+1:j,3));
            tdidx = find(px(j-ssreached+1:end,3)==tradenew.riskmanager_.tdhigh_,1,'last')+j-ssreached;
            tradenew.riskmanager_.tdlow_ = px(tdidx,4);
            if tradenew.riskmanager_.tdlow_ - (tradenew.riskmanager_.tdhigh_-tradenew.riskmanager_.tdlow_) > tradenew.riskmanager_.pxstoploss_
                tradenew.riskmanager_.pxstoploss_ = tradenew.riskmanager_.tdlow_ - (tradenew.riskmanager_.tdhigh_-tradenew.riskmanager_.tdlow_);
            end
        end
        tradesfractalb1.push(tradenew);
    end

end

