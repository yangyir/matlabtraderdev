function [ tradesfractalb1 ] = fractal_gentradesb1( idxfractalb1,px,HH,LL,bs,ss,varargin )
%FRACTAL_GENTRADESB1 Summary of this function goes here
%   Detailed explanation goes here
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('code','',@ischar);
    p.addParameter('freq','1d',@ischar);
    p.addParameter('lips',[],@isnumeric);
    p.addParameter('idxHH',[],@isnumeric);
    p.addParameter('wad',[],@isnumeric);
    p.addParameter('nfractal',[],@isnumeric);
    p.parse(varargin{:});
    code = p.Results.code;
    freq = p.Results.freq;
    lips = p.Results.lips;
    idxHH = p.Results.idxHH;
    wad = p.Results.wad;
    nfractal = p.Results.nfractal;
    
    variablenotused(bs);
    
    tradesfractalb1 = cTradeOpenArray;
    for i = 1:size(idxfractalb1,1)
        j = idxfractalb1(i);
        if ~isempty(code)
            instrument = code2instrument(code);
            adj = instrument.tick_size;
        else
            adj = 0;
        end
        
%         if px(j,5)-HH(j) <= adj, continue;end
        %double check to make sure that the price is well above lips
        if ~isempty(lips)
            if px(j,5) - lips(j) <= adj, continue;end
        end
        
        %WAD testing:make sure WAD movement is consistent with price
        %movement
        if ~isempty(wad)
            for jj = j-1:-1:1
                if HH(jj) ~= HH(j)
                    lastidx_hh = jj+1;
                    break
                end
            end
%             fprintf('%s:lastHH:%s\n',num2str(j),num2str(lastidx_hh));
%             lastidx_hh = find(HH(1:j)==HH(j),1,'first');
            if isempty(find(px(lastidx_hh:j-1,5)>HH(lastidx_hh),1,'first'))
                lasthigh = max(px(lastidx_hh-2*nfractal:j-1,5));
                lasthigh_idx = find(px(lastidx_hh-2*nfractal:j-1,5)==lasthigh,1,'first')+lastidx_hh-2*nfractal-1;
                lasthigh_wad = wad(lasthigh_idx);
                if wad(j) < lasthigh_wad && px(j,5) >= lasthigh
                    continue;
                end
            else
                %this shall happen when the price breached HH and then fell
                %below again
                lastbreach_idx = find(px(lastidx_hh:j-1,5)>HH(lastidx_hh),1,'last')+lastidx_hh-1;
                lastbreach_px = px(lastbreach_idx,5);
                if px(j,5) >= lastbreach_px
                    if wad(j) < wad(lastbreach_idx)
                        continue;
                    end
                else
                    lasthigh = max(px(lastidx_hh-2*nfractal:lastidx_hh,5));
                    lasthigh_idx = find(px(lastidx_hh-2*nfractal:lastidx_hh,5)==lasthigh,1,'first')+lastidx_hh-2*nfractal-1;
                    lasthigh_wad = wad(lasthigh_idx);
                    if wad(j) < lasthigh_wad
                        continue;
                    end
                end
            end
        end
                       
        %perfect ss with 3 consective sell setup exclusion
        if ss(j) == 9
            high6 = px(j-3,3);
            high7 = px(j-2,3);
            high8 = px(j-1,3);
            high9 = px(j,3);
            close8 = px(j-1,5);
            close9 = px(j,5);
            if (high8 > max(high6,high7) || high9 > max(high6,high7)) && close9 > close8
                %also 3 consective TDST sell setup without any TDST buysetup between
                last3ss = find(ss(1:j)==9,3,'last');
                if length(last3ss) >= 3
                    if isempty(find(bs(last3ss(1):j)==9,1,'last'))
                        continue;
                    end
                end
            end
            
        end
        
        signalinfo = struct('name','fractal','hh',HH(j),'ll',LL(j),'frequency',freq);
        riskmanager = struct('hh0_',px(j,3),'hh1_',px(j,3),'ll0_',LL(j),'ll1_',LL(j),'type_','breachup-B');
        
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

