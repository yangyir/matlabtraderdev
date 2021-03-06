function [ tradesfractals1 ] = fractal_gentradess1( idxfractals1,px,HH,LL,bs,ss,lvlup,lvldn,bc,sc,varargin )
%FRACTAL_GENTRADESS1 Summary of this function goes here
%   Detailed explanation goes here
    
    variablenotused(lvldn);
    variablenotused(sc);
    
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('code','',@ischar);
    p.addParameter('freq','1d',@ischar);
    p.addParameter('lips',[],@isnumeric);
    p.addParameter('wad',[],@isnumeric);
    p.addParameter('nfractal',[],@isnumeric);
    p.addParameter('debug',[],@islogical);
    p.parse(varargin{:});
    code = p.Results.code;
    freq = p.Results.freq;
    lips = p.Results.lips;
    wad = p.Results.wad;
    nfractal = p.Results.nfractal;
    debug = p.Results.debug;
    
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
        
        if bc(j) == 13
            if debug
                fprintf('point %4s:excluded as buy countdown 13 reached\n',num2str(j));
            end
            continue;
        end
        
%         if LL(j)-px(j,5) <= adj, continue;end
        %double check to make sure that the price is well below lips
        if ~isempty(lips)
            if lips(j)-px(j,5) <= adj
                if debug
                    fprintf('point %4s:excluded as price is not well-below alligator lips\n',num2str(j));
                end
                continue;
            end
        end
        
        %WAD testing:make sure WAD movement is consistent with price
        %movement
        if ~isempty(wad)
            for jj = j-1:-1:1
                if LL(jj) ~= LL(j)
                    lastidx_ll = jj + 1;
                    break
                end
            end
%             lastidx_ll = find(idxLL(1:j-1)==-1,1,'last');
            if isempty(find(px(lastidx_ll:j-1,5)<LL(lastidx_ll),1,'last'))
                %this shall happen when the price has not breached LL yet
                %and it is the first time breach LL at time point j
                lastlow = min(px(lastidx_ll-2*nfractal:j-1,5));
                lastlow_idx = find(px(lastidx_ll-2*nfractal:j-1,5)==lastlow,1,'last')+lastidx_ll-2*nfractal-1;
                lastlow_wad = wad(lastlow_idx);
                if wad(j) > lastlow_wad && px(j,5) <= lastlow
                    if debug
                        fprintf('point %4s:px first time breached LL with WAD of %s but the WAD of the last low is %s at point %s...\n',...
                            num2str(j),num2str(wad(j)),num2str(lastlow_wad),num2str(lastlow_idx));
                    end
                    continue
                end
            else
                %this shall happen when the price beached LL and then
                %rally above again
                lastbreach_idx = find(px(lastidx_ll:j-1,5)<LL(lastidx_ll),1,'last')+lastidx_ll-1;
                lastbreach_px = px(lastbreach_idx,5);
                if px(j,5) <= lastbreach_px
                    if wad(j) > wad(lastbreach_idx)
                        if debug
                            fprintf('point %4s:px breached LL again at new low with WAD of %s but the WAD of the last low is %s at point %s...\n',...
                                num2str(j),num2str(wad(j)),num2str(wad(lastbreach_idx)),num2str(lastbreach_idx));
                        end
                        continue;
                    end
                else
                    lastlow = min(px(lastidx_ll-2*nfractal:lastidx_ll,5));
                    lastlow_idx = find(px(lastidx_ll-2*nfractal:lastidx_ll,5)==lastlow,1,'first')+lastidx_ll-2*nfractal-1;
                    lastlow_wad = wad(lastlow_idx);
                    if wad(j) > lastlow_wad
                        if debug
                            fprintf('point %4s:px breached LL again without new low with WAD of %s but the WAD of the last low is %s at point %s...\n',...
                            num2str(j),num2str(wad(j)),num2str(lastlow_wad),num2str(lastlow_idx));
                        end
                        continue
                    end
                end
            end
        end
        
        %perfect bs with 2 consective buy setup exclusion
        if bs(j) == 9
            low6 = px(j-3,4);
            low7 = px(j-2,4);
            low8 = px(j-1,4);
            low9 = px(j,4);
            close8 = px(j-1,5);
            close9 = px(j,5);
            if (low8 < min(low6,low7) || low9 < min(low6,low7)) && close9 < close8
                %also 2 consective TDST buy setup without any TDST sellsetup between
                %and also price never rally above
                last2bs = find(bs(1:j)==9,2,'last');
                if length(last2bs) >= 2
                    if isempty(find(ss(last2bs(1):j)==9,1,'last')) && isempty(find(px(last2bs(1):j,5) > lvlup(last2bs(1)),1,'first'))
                        if debug
                            fprintf('point %4s:perfect buysetup with more than 2 consective sequential\n',...
                                num2str(j));
                        end
                        continue;
                    end
                end
            end
        end
        %
        if bs(j) > 9
            lastbs9 = find(bs(1:j)==9,1,'last');
            if px(j,5) <= min(px(lastbs9-8:j,5)) && px(j,4) <= min(px(lastbs9-8:j,4))
                last2bs = find(bs(1:j)==9,2,'last');
                if length(last2bs) >= 2
                    if isempty(find(ss(last2bs(1):j)==9,1,'last')) && isempty(find(px(last2bs(1):j,5) > lvlup(last2bs(1)),1,'first'))
                        if debug
                            fprintf('point %4s:px reaches minimum close and high at the same candle stick with more than 2 consective sequential before\n',...
                                num2str(j));
                        end
                        continue;
                    end
                end
            end
        end
        
        signalinfo = struct('name','fractal','hh',HH(j),'ll',LL(j),'frequency',freq);
        riskmanager = struct('hh0_',HH(j),'hh1_',HH(j),'ll0_',px(j,4),'ll1_',px(j,4),'type_','breachdn-S');
        tradenew = cTradeOpen('id',i,'opendatetime',px(j,1),'openprice',px(j,5),...
            'opendirection',-1,'openvolume',1,'code',code);
        tradenew.status_ = 'set';
        tradenew.setsignalinfo('name','fractal','extrainfo',signalinfo);
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

