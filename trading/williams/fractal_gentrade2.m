function [trade] = fractal_gentrade2(resstruct,code,idx,freq,nfractal,kellytables)

if strcmpi(freq,'30m')
%     nfractal = 4;
    tickratio = 0.5;
elseif strcmpi(freq,'15m')
%     nfractal = 4;
    tickratio = 0.5;
elseif strcmpi(freq,'5m')
%     nfractal = 6;
    tickratio = 0;
elseif strcmpi(freq,'1440m') || strcmpi(freq,'daily')
%     nfractal = 2;
    tickratio = 1;
else
%     nfractal = 4;
    tickratio = 0.5;
end

fut = code2instrument(code);

idx_ = idx-1;
ei_ = fractal_truncate(resstruct,idx_);
condsignal = fractal_signal_conditional2('extrainfo',ei_,'ticksize',fut.tick_size,...
    'nfractal',nfractal,'kellytables',kellytables,'assetname',fut.asset_name,...
    'ticksizeratio',tickratio);
ei = fractal_truncate(resstruct,idx); 
uncondsignal = fractal_signal_unconditional2('extrainfo',ei,...
        'ticksize',fut.tick_size,...
        'nfractal',nfractal,...
        'assetname',fut.asset_name,...
        'kellytables',kellytables,...
        'ticksizeratio',tickratio);

weiredcase = false;
if ~isempty(condsignal) && ~isempty(uncondsignal)
    if condsignal.directionkellied ~= 0 && ...
            uncondsignal.directionkellied ~= 0 && ...
            condsignal.directionkellied ~= uncondsignal.directionkellied && ...
            uncondsignal.status.istrendconfirmed
        weiredcase = true;
    end
    if weiredcase
        pxopen = ei.px(idx,2);
        pxhigh = ei.px(idx,3);
        pxlow = ei.px(idx,4);
        if condsignal.directionkellied == 1 && uncondsignal.directionkellied == -1
            %need to make sure whether fractal hh is breached
            breachflag = pxhigh>=condsignal.signalkellied(2)+fut.tick_size && ...
                pxopen<condsignal.signalkellied(2)+2.0*(condsignal.signalkellied(2)-condsignal.signalkellied(3));
            if breachflag
                fprintf('not support with conditional breachup and unconditional breachdn happenning on the same candle\n');
                trade = {};
                return
            else
                trade = fractal_gentrade(resstruct,code,idx,uncondsignal.op.comment,uncondsignal.directionkellied,freq,nfractal);
                return
            end
        elseif condsignal.directionkellied == -1 && uncondsignal.directionkellied == 1
            %need to make sure whether fractal ll is breached
            breachflag = pxlow<=condsignal.signalkellied(3)-fut.tick_size && ...
                pxopen>condsignal.signalkellied(3)-2.0*(condsignal.signalkellied(2)-condsignal.signalkellied(3));
            if breachflag
                fprintf('not support with conditional breachdn and unconditional breachup happenning on the same candle\n');
                trade = {};
                return
            else
                trade = fractal_gentrade(resstruct,code,idx,uncondsignal.op.comment,uncondsignal.directionkellied,freq,nfractal);
                return
            end
        end
    end
end
    
    
    

%1.first check whether kelly is big enough for place an conditional entrust
if isempty(condsignal)
    %2.check whether it is not a trending trade
    if isempty(uncondsignal)
        trade = {};
        return
    else
        if uncondsignal.directionkellied == 0
            trade = {};
            return
        end
        if uncondsignal.status.istrendconfirmed
            %filter out case that the empty condsignal was returned because
            %of fractal barrier update
            if uncondsignal.directionkellied == 1
%                 highs = ei.px(end-nfractal:end-1,3);
%                 highest = max(highs);
%                 if highest == highs(1) && highest > ei.hh(end-1) && nfractal ~= 6
%                     trade = fractal_gentrade(resstruct,code,idx,uncondsignal.op.comment,uncondsignal.directionkellied,freq);
%                     trade.openprice_ = ei.px(end,5);
%                     trade.riskmanager_.setusefractalupdateflag(0);
%                     return
%                 else
                    trade = {};
                    return
%                 end
            elseif uncondsignal.directionkellied == -1
%                 lows = ei.px(end-nfractal:end-1,4);
%                 lowest = min(lows);
%                 if lowest == lows(1) && lowest < ei.ll(end-1) && nfractal ~= 6
%                     trade = fractal_gentrade(resstruct,code,idx,uncondsignal.op.comment,uncondsignal.directionkellied,freq);
%                     trade.openprice_ = ei.px(end,5);
%                     trade.riskmanager_.setusefractalupdateflag(0);
%                     return
%                 else
                if uncondsignal.status.islvldnbreach
                    trade = fractal_gentrade(resstruct,code,idx,uncondsignal.op.comment,uncondsignal.directionkellied,freq,nfractal);
                    trade.riskmanager_.setusefractalupdateflag(0);
                    trade.opensignal_.kelly_ = uncondsignal.kelly;
                    return
                else
                    trade = {};
                    return
%                 end
                end
            end
        else
            if isfx(code)
                openpx = resstruct.px(idx,5);
            else
                try
                    openpx = resstruct.px(idx+1,2);
                catch
                    openpx = resstruct.px(idx,5);
                end
            end
            if uncondsignal.directionkellied == 1 && openpx >= uncondsignal.signalkellied(2)
                trade = fractal_gentrade(resstruct,code,idx,uncondsignal.op.comment,uncondsignal.directionkellied,freq,nfractal);
                trade.riskmanager_.setusefractalupdateflag(0);
                trade.opensignal_.kelly_ = uncondsignal.kelly;
            elseif uncondsignal.directionkellied == -1 && openpx <= uncondsignal.signalkellied(3)
                trade = fractal_gentrade(resstruct,code,idx,uncondsignal.op.comment,uncondsignal.directionkellied,freq,nfractal);
                trade.riskmanager_.setusefractalupdateflag(0);
                trade.opensignal_.kelly_ = uncondsignal.kelly;
            else
                trade = {};
            end
            return
        end
    end
end
%
%
if condsignal.directionkellied == 0
    if ~isempty(uncondsignal)
        if uncondsignal.directionkellied == 0
            trade = {};
            return
        else
            if ~uncondsignal.status.istrendconfirmed
                trade = fractal_gentrade(resstruct,code,idx,uncondsignal.op.comment,uncondsignal.directionkellied,freq,nfractal,0);
                trade.riskmanager_.setusefractalupdateflag(0);
                trade.opensignal_.kelly_ = uncondsignal.kelly;
                return
            else
                trade = {};
                return
            end
        end
    else
        trade = {};
        return
    end
elseif condsignal.directionkellied == 1
    if condsignal.signalkellied(4) == 2
        td13high_ = NaN;
        td13low_ = NaN;
        tdlow_ = NaN;
        tdhigh_ = NaN;
        if condsignal.signalkellied(9) == 21
            mode = 'conditional-uptrendconfirmed-1';
        elseif condsignal.signalkellied(9) == 22
            mode = 'conditional-uptrendconfirmed-2';
            sslastidx = find(ei_.ss>=9,1,'last');
            sslastval = ei_.ss(sslastidx);
            tdhigh_ = max(ei_.px(sslastidx-sslastval+1:sslastidx,3));
            tdidx_ = find(ei_.px(sslastidx-sslastval+1:sslastidx,3) == tdhigh_,1,'last') + sslastidx-sslastval;
            tdlow_ = ei_.px(tdidx_,4);
        elseif condsignal.signalkellied(9) == 23
            mode = 'conditional-uptrendconfirmed-3';
            sclastidx = find(ei_.sc==13,1,'last');
            td13low_ = ei_.px(sclastidx,4);
            td13high_ = ei_.px(sclastidx,3);
        else
            mode = 'conditional-uptrendconfirmed';
        end
        signalinfo = struct('name','fractal','type','breachup-B',...
            'hh', condsignal.signalkellied(2),...
            'll', condsignal.signalkellied(3),...
            'mode',mode,'nfractal',nfractal,...
            'frequency',freq,...
            'hh1', condsignal.signalkellied(5),...
            'll1', condsignal.signalkellied(6),...
            'kelly',condsignal.kelly);
        %
        riskmanager = struct('hh0_',signalinfo.hh,'hh1_',signalinfo.hh,...
            'll0_',signalinfo.ll,'ll1_',signalinfo.ll,...
            'type_','breachup-B',...
            'wadopen_',resstruct.wad(idx),...
            'cpopen_',resstruct.px(idx,5),'wadhigh_',resstruct.wad(idx),...
            'cphigh_',resstruct.px(idx,5),'wadlow_',resstruct.wad(idx),...
            'fibonacci1_',0.618*signalinfo.hh+0.382*signalinfo.hh1,...
            'fibonacci0_',signalinfo.ll,...
            'status_','unset',...
            'pxtarget_',-9.99,...
            'pxstoploss_',-9.99,...
            'tdlow_',tdlow_,...
            'tdhigh_',tdhigh_,...
            'td13high_',td13high_,...
            'td13low_',td13low_,...
            'closestr_','none');
        %
        pxhigh = resstruct.px(idx,3);
        pxopen = resstruct.px(idx,2);
        %2.check whether volblowup2,i.e.market jumps at beginning
        if tickratio == 0
            tickratio_ = 0;
        else
            tickratio_ = 1;
        end
        
        if pxhigh-condsignal.signalkellied(2)-fut.tick_size*tickratio_ > -1e-6 && ...
                pxopen<condsignal.signalkellied(2)+2.0*(condsignal.signalkellied(2)-condsignal.signalkellied(3))
            px = ei_.px;
            idxhh = ei_.idxhh;
            idx_lasthh = find(idxhh == 1,1,'last');
            nkfromhh = size(px,1) - idx_lasthh+nfractal+1;
            barsizerest = px(end-nkfromhh+1:end,3)-px(end-nkfromhh+1:end,4);
            if pxopen >= condsignal.signalkellied(2)+fut.tick_size*tickratio_
                lasttrade = pxopen;
                retlast = lasttrade-px(end,5);
                isvolblowup2 = retlast>0 & (retlast-mean(barsizerest))/std(barsizerest)>norminv(0.975);
            else
                isvolblowup2 = false;
            end
            
            hhlast = ei_.hh(end);
            ssidxlast = find(ei_.ss>=9,1,'last');
            if ~isempty(ssidxlast)
                ssvallast = ei_.ss(ssidxlast);
                sshigh = max(px(ssidxlast-ssvallast+1:ssidxlast,3));
                issshighbreach = hhlast == sshigh;
            else
                issshighbreach = false;
            end
            if isvolblowup2 && ~issshighbreach
                try
                    kelly = kelly_k('volblowup2',fut.asset_name,kellytables.signal_l,kellytables.asset_list,kellytables.kelly_matrix_l,0);
                catch
                    idxvolblowup2 = strcmpi(kellytables.kelly_table_l.opensignal_unique_l,'volblowup2');
                    kelly = kellytables.kelly_table_l.kelly_unique_l(idxvolblowup2);
                end
                if ~isnan(kelly)
                    if kelly >= 0.088
                        poptrade = true;
                    else
                        poptrade = false;
                    end
                else
                    poptrade = false;
                end
            else
                poptrade = true;
            end
        else
            if isempty(uncondsignal)
                poptrade = false;
            else
                if uncondsignal.directionkellied == -1
                    trade = fractal_gentrade(resstruct,code,idx,uncondsignal.op.comment,uncondsignal.directionkellied,freq,nfractal);
                    trade.riskmanager_.setusefractalupdateflag(0);
                    trade.opensignal_.kelly_ = uncondsignal.kelly;
                    return
                elseif uncondsignal.directionkellied == 1
                    %here due to conditional barrier shifting up
                    if condsignal.signalkellied(2) > uncondsignal.signalkellied(2)
                        lastss = find(ei.ss >= 9,1,'last');
                        if size(ei.ss,1) - lastss <= nfractal
                            poptrade = false;
                        else
                            if pxhigh-uncondsignal.signalkellied(2)-fut.tick_size*tickratio_ >= -1e-6 && ...
                                    pxopen<uncondsignal.signalkellied(2)+2.0*(uncondsignal.signalkellied(2)-uncondsignal.signalkellied(3))
                                trade = fractal_gentrade(resstruct,code,idx,uncondsignal.op.comment,uncondsignal.directionkellied,freq,nfractal,0);
                                trade.riskmanager_.setusefractalupdateflag(0);
                                trade.opensignal_.kelly_ = uncondsignal.kelly;
                                return
                            else
                                poptrade = false;
                            end
                        end
                    else
                        poptrade = false;
                    end
                else
                    poptrade = false;
                end
            end
        end
        %
        if ~poptrade
            trade = {};
            return
        end
        %
        trade = cTradeOpen('id',idx,'code',code,...
            'opendatetime', resstruct.px(idx,1),...
            'openprice',max(pxopen,condsignal.signalkellied(2)+tickratio_*fut.tick_size),...
            'opendirection',1,...
            'openvolume',1);
        trade.setsignalinfo('name','fractal','extrainfo',signalinfo);
        trade.setriskmanager('name','spiderman','extrainfo',riskmanager);
        trade.riskmanager_.setusefractalupdateflag(0);
        trade.riskmanager_.setusefibonacciflag(1);
        %
        if ei_.ss(end) >= 9
            ssreached = ei_.ss(end);
            trade.riskmanager_.tdhigh_ = max(ei_.px(end-ssreached+1:end,3));
            tdidx = find(ei_.px(end-ssreached+1:end,3)==trade.riskmanager_.tdhigh_,1,'last')+size(ei_.px,1)-ssreached;
            trade.riskmanager_.tdlow_ = ei_.px(tdidx,4);
            if trade.riskmanager_.tdlow_ - (trade.riskmanager_.tdhigh_-trade.riskmanager_.tdlow_) > trade.riskmanager_.pxstoploss_
                trade.riskmanager_.pxstoploss_ = trade.riskmanager_.tdlow_ - (trade.riskmanager_.tdhigh_-trade.riskmanager_.tdlow_);
                trade.riskmanager_.closestr_ = 'tdsq:ssbreak';
            end
        end
        %
        if ~isnan(trade.riskmanager_.tdlow_)
            if trade.riskmanager_.tdlow_ - (trade.riskmanager_.tdhigh_-trade.riskmanager_.tdlow_) > trade.riskmanager_.pxstoploss_
                trade.riskmanager_.pxstoploss_ = trade.riskmanager_.tdlow_ - (trade.riskmanager_.tdhigh_-trade.riskmanager_.tdlow_);
                trade.riskmanager_.closestr_ = 'tdsq:ssbreak';
            end
        end
        %
        if ei_.sc(end) == 13
            trade.riskmanager_.td13high_ = ei_.px(end,3);
            trade.riskmanager_.td13low_ = ei_.px(end,4);
            if trade.riskmanager_.td13low_ - (trade.riskmanager_.td13high_ - trade.riskmanager_.td13low_) > trade.riskmanager_.pxstoploss_
                trade.riskmanager_.pxstoploss_ = trade.riskmanager_.td13low_ - (trade.riskmanager_.td13high_ - trade.riskmanager_.td13low_);
                trade.riskmanager_.closestr_ = 'tdsq:sc13break';
            end
        end
        %
        if ~isnan(trade.riskmanager_.td13low_)
            if trade.riskmanager_.td13low_ - (trade.riskmanager_.td13high_ - trade.riskmanager_.td13low_) > trade.riskmanager_.pxstoploss_
                trade.riskmanager_.pxstoploss_ = trade.riskmanager_.td13low_ - (trade.riskmanager_.td13high_ - trade.riskmanager_.td13low_);
                trade.riskmanager_.closestr_ = 'tdsq:sc13break';
            end
        end
        %
        if resstruct.teeth(idx-1) > trade.riskmanager_.pxstoploss_
            trade.riskmanager_.pxstoploss_ = floor(resstruct.teeth(idx-1)/fut.tick_size)*fut.tick_size;
            trade.riskmanager_.closestr_ = 'fractal:teeth';
        end
        %
        trade.status_ = 'set';
        trade.riskmanager_.status_ = 'set';
    elseif condsignal.signalkellied(4) ~= 2
        error('not implemented yet!!!')
    end
elseif condsignal.directionkellied == -1
    if condsignal.signalkellied(4) == -2
        td13high_ = NaN;
        td13low_ = NaN;
        tdlow_ = NaN;
        tdhigh_ = NaN;
        if condsignal.signalkellied(9) == -21
            mode = 'conditional-dntrendconfirmed-1';
        elseif condsignal.signalkellied(9) == -22
            mode = 'conditional-dntrendconfirmed-2';
            bslastidx = find(ei_.bs>=9,1,'last');
            bslastval = ei_.bs(bslastidx);
            tdlow_ = min(ei_.px(bslastidx-bslastval+1:bslastidx,4));
            tdidx_ = find(ei_.px(bslastidx-bslastval+1:bslastidx,4) == tdlow_,1,'last') + bslastidx-bslastval;
            tdhigh_ = ei_.px(tdidx_,3);
        elseif condsignal.signalkellied(9) == -23
            mode = 'conditional-dntrendconfirmed-3';
            bclastidx = find(ei_.bc==13,1,'last');
            td13high_ = ei_.px(bclastidx,3);
            td13low_ = ei_.px(bclastidx,4);
        else
            mode = 'conditional-dntrendconfirmed';
        end
        signalinfo = struct('name','fractal','type','breachdn-S',...
            'hh', condsignal.signalkellied(2),...
            'll', condsignal.signalkellied(3),...
            'mode',mode,'nfractal',nfractal,...
            'frequency',freq,...
            'hh1', condsignal.signalkellied(5),...
            'll1', condsignal.signalkellied(6),...
            'kelly',condsignal.kelly);
        %
        riskmanager = struct('hh0_',signalinfo.hh,'hh1_',signalinfo.hh,...
            'll0_',signalinfo.ll,'ll1_',signalinfo.ll,...
            'type_','breachdn-S',...
            'wadopen_',resstruct.wad(idx),...
            'cpopen_',resstruct.px(idx,5),'wadhigh_',resstruct.wad(idx),...
            'cphigh_',resstruct.px(idx,5),'wadlow_',resstruct.wad(idx),...
            'cplow_',resstruct.px(idx,5),...
            'fibonacci1_',signalinfo.hh,...
            'fibonacci0_',0.618*signalinfo.ll+0.382*signalinfo.ll1,...
            'status_','unset',...
            'pxtarget_',-9.99,...
            'pxstoploss_',-9.99,...
            'tdlow_',tdlow_,...
            'tdhigh_',tdhigh_,...
            'td13high_',td13high_,...
            'td13low_',td13low_,...
            'closestr_','none');
        %
        pxlow = resstruct.px(idx,4);
        pxopen = resstruct.px(idx,2);
        %
        if tickratio == 0
            tickratio_ = 0;
        else
            tickratio_ = 1;
        end
        %2.check whether volblowup2,i.e.market jumps at begining
        if pxlow-condsignal.signalkellied(3)+tickratio_*fut.tick_size<=1e-6 && ...
                pxopen>condsignal.signalkellied(3)-2.0*(condsignal.signalkellied(2)-condsignal.signalkellied(3))
            px = ei_.px;
            idxll = ei_.idxll;
            idx_lastll = find(idxll == -1,1,'last');
            nkfromll = size(px,1) - idx_lastll+nfractal+1;
            barsizerest = px(end-nkfromll+1:end,3)-px(end-nkfromll+1:end,4);
            if pxopen <= condsignal.signalkellied(3)-tickratio_*fut.tick_size
                lasttrade = pxopen;
                retlast = lasttrade-px(end,5);
                isvolblowup2 = retlast<0 & (abs(retlast)-mean(barsizerest))/std(barsizerest)>norminv(0.975);
            else
                isvolblowup2 = false;
            end
            
            lllast = ei_.ll(end);
            bsidxlast = find(ei_.bs>=9,1,'last');
            if ~isempty(bsidxlast)
                bsvallast = ei_.bs(bsidxlast);
                bslow = min(px(bsidxlast-bsvallast+1:bsidxlast,4));
                isbslowbreach = lllast == bslow;
            else
                isbslowbreach = false;
            end
            if isvolblowup2 && ~isbslowbreach
                try
                    kelly = kelly_k('volblowup2',fut.asset_name,kellytables.signal_s,kellytables.asset_list,kellytables.kelly_matrix_s,0);
                catch
                    idxvolblowup2 = strcmpi(kellytables.kelly_table_s.opensignal_unique_s,'volblowup2');
                    kelly = kellytables.kelly_table_s.kelly_unique_s(idxvolblowup2);
                end
                if ~isnan(kelly)
                    if kelly >= 0.088
                        poptrade = true;
                    else
                        poptrade = false;
                    end
                else
                    poptrade = false;
                end
            else
                poptrade = true;
            end
        else
            if isempty(uncondsignal)
                poptrade = false;
            else
                if uncondsignal.directionkellied == 1
                    trade = fractal_gentrade(resstruct,code,idx,uncondsignal.op.comment,uncondsignal.directionkellied,freq,nfractal);
                    trade.riskmanager_.setusefractalupdateflag(0);
                    trade.opensignal_.kelly_ = uncondsignal.kelly;
                    return
                elseif uncondsignal.directionkellied == -1
                    if condsignal.signalkellied(3) < uncondsignal.signalkellied(3)
                        lastbs = find(ei.bs >= 9,1,'last');
                        if ~isempty(lastbs) && size(ei.bs,1) - lastbs <= nfractal && ~strcmpi(uncondsignal.opkellied,'breachdn-bshighvalue')
                            poptrade = false;
                        else
                            if pxlow-uncondsignal.signalkellied(3)+tickratio_*fut.tick_size <= 1e-6 && ...
                                    pxopen>uncondsignal.signalkellied(3)-2.0*(uncondsignal.signalkellied(2)-uncondsignal.signalkellied(3))
                                trade = fractal_gentrade(resstruct,code,idx,uncondsignal.op.comment,uncondsignal.directionkellied,freq,nfractal,0);
                                trade.riskmanager_.setusefractalupdateflag(0);
                                trade.opensignal_.kelly_ = uncondsignal.kelly;
                                return
                            else
                                poptrade = false;
                            end
                        end 
                    else
                        poptrade = false;
                    end 
                else
                    poptrade = false;
                end
            end
        end
        %
        if ~poptrade
            trade = {};
            return
        end
        %
        trade = cTradeOpen('id',idx,'code',code,...
            'opendatetime', resstruct.px(idx,1),...
            'openprice',min(pxopen,condsignal.signalkellied(3)-tickratio_*fut.tick_size),...
            'opendirection',-1,...
            'openvolume',1);
        trade.setsignalinfo('name','fractal','extrainfo',signalinfo);
        trade.setriskmanager('name','spiderman','extrainfo',riskmanager);
        trade.riskmanager_.setusefractalupdateflag(0);
        trade.riskmanager_.setusefibonacciflag(1);
        %
        if ei_.bs(end) >= 9
            bsreached = ei_.bs(end);
            trade.riskmanager_.tdlow_ = min(ei_.px(end-bsreached+1:end,4));
            tdidx = find(ei_.px(end-bsreached+1:end,4)==trade.riskmanager_.tdlow_,1,'last')+size(ei_.px,1)-bsreached;
            trade.riskmanager_.tdhigh_ = ei_.px(tdidx,3);
            if trade.riskmanager_.tdhigh_ + (trade.riskmanager_.tdhigh_-trade.riskmanager_.tdlow_) < trade.riskmanager_.pxstoploss_
                trade.riskmanager_.pxstoploss_ = trade.riskmanager_.tdhigh_ + (trade.riskmanager_.tdhigh_-trade.riskmanager_.tdlow_);
                trade.riskmanager_.closestr_ = 'tdsq:bsbreak';
            end
        end
        %
        if ~isnan(trade.riskmanager_.tdhigh_)
            if trade.riskmanager_.tdhigh_ + (trade.riskmanager_.tdhigh_-trade.riskmanager_.tdlow_) < trade.riskmanager_.pxstoploss_
                trade.riskmanager_.pxstoploss_ = trade.riskmanager_.tdhigh_ + (trade.riskmanager_.tdhigh_-trade.riskmanager_.tdlow_);
                trade.riskmanager_.closestr_ = 'tdsq:bsbreak';
            end
        end
        %
        if ei_.bc(end) == 13
            trade.riskmanager_.td13low_ = ei_.px(end,4);
            trade.riskmanager_.td13high_ = ei_.px(end,3);
            if trade.riskmanager_.td13high_ + (trade.riskmanager_.td13high_-trade.riskmanager_.td13low_) > trade.riskmanager_.pxstoploss_
                trade.riskmanager_.pxstoploss_ = trade.riskmanager_.td13high_ + (trade.riskmanager_.td13high_-trade.riskmanager_.td13low_);
                trade.riskmanager_.closestr_ = 'tdsq:bc13break';
            end
        end
        %
        if ~isnan(trade.riskmanager_.td13low_)
            if trade.riskmanager_.td13high_ + (trade.riskmanager_.td13high_-trade.riskmanager_.td13low_) > trade.riskmanager_.pxstoploss_
                trade.riskmanager_.pxstoploss_ = trade.riskmanager_.td13high_ + (trade.riskmanager_.td13high_-trade.riskmanager_.td13low_);
                trade.riskmanager_.closestr_ = 'tdsq:bc13break';
            end
        end
        %
        if resstruct.teeth(idx) < trade.riskmanager_.pxstoploss_
            trade.riskmanager_.pxstoploss_ = ceil(resstruct.teeth(idx)/fut.tick_size)*fut.tick_size;
            trade.riskmanager_.closestr_ = 'fractal:teeth';
        end
        %
        trade.status_ = 'set';
        trade.riskmanager_.status_ = 'set';
    elseif condsignal.signalkellied(4) ~= -2
        error('not implemented yet!!!')
    end
end
    
    
end






