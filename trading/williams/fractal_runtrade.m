function [ tradeout ] = fractal_runtrade( tradein,px,HH,LL,jaw,teeth,lips,bs,ss,bc,sc,lvlup,lvldn,wad )
%FRACTAL_RUNTRADE Summary of this function goes here
%   Detailed explanation goes here
    if nargin < 14
        wad = [];
    end
    tradeout = [];
    j = find(px(:,1)<=tradein.opendatetime1_,1,'last');
    for k = j+1:length(px)
        extrainfo = struct('p',px(1:k,:),'hh',HH(1:k),'ll',LL(1:k),...
            'jaw',jaw(1:k),'teeth',teeth(1:k),'lips',lips(1:k),...
            'bs',bs(1:k),'ss',ss(1:k),'bc',bc(1:k),'sc',sc(1:k),...
            'lvlup',lvlup(1:k),'lvldn',lvldn(1:k),'wad',wad(1:k));
        tradeout = tradein.riskmanager_.riskmanagementwithcandle(px(k,:),...
            'usecandlelastonly',false,...
            'debug',false,...
            'updatepnlforclosedtrade',true,...
            'extrainfo',extrainfo);
        if ~isempty(tradeout)
            tradein.closedatetime1_ = px(k,1);
            break;
        end
    end

end

