function [trade] = fractal_gentrade2(resstruct,code,idx,freq,kellytables)

if strcmpi(freq,'30m')
    nfractal = 4;
elseif strcmpi(freq,'15m')
    nfractal = 4;
elseif strcmpi(freq,'5m')
    nfractal = 6;
elseif strcmpi(freq,'1440m') || strcmpi(freq,'daily')
    nfractal = 2;
else
    nfractal = 4;
end

fut = code2instrument(code);

idx_ = idx-1;
ei_ = fractal_truncate(resstruct,idx_);
condsignal = fractal_signal_conditional2('extrainfo',ei_,'ticksize',fut.tick_size,...
    'nfractal',nfractal,'kellytables',kellytables,'assetname',fut.asset_name);



%1.first check whether kelly is big enough for place an conditional entrust
if isempty(condsignal)
   trade = {};
   return
end
%
%
if condsignal.directionkellied == 0
    trade = {};
    return
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
        else
            mode = 'conditional-uptrendconfirmed';
        end
        signalinfo = struct('name','fractal','type','breachup-B',...
            'hh', condsignal.signalkellied(2),...
            'll', condsignal.signalkellied(3),...
            'mode',mode,'nfractal',nfractal,...
            'frequency',freq,...
            'hh1', condsignal.signalkellied(5),...
            'll1', condsignal.signalkellied(6));
        %
        riskmanager = struct('hh0_',signalinfo.hh,'hh1_',signalinfo.hh,...
            'll0_',signalinfo.ll,'ll1_',signalinfo.ll,...
            'type_','breachup-B',...
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
        if pxhigh>=condsignal.signalkellied(2)+fut.tick_size && ...
                pxopen<condsignal.signalkellied(2)+1.618*(condsignal.signalkellied(2)-condsignal.signalkellied(3))
            px = ei_.px;
            idxhh = ei_.idxhh;
            idx_lasthh = find(idxhh == 1,1,'last');
            nkfromhh = size(px,1) - idx_lasthh+nfractal+1;
            barsizerest = px(end-nkfromhh+1:end,3)-px(end-nkfromhh+1:end,4);
            if pxopen >= condsignal.signalkellied(2)+fut.tick_size
                lasttrade = pxopen;
            else
                lasttrade = condsignal.signalkellied(2)+fut.tick_size;
            end
            retlast = lasttrade-px(end,5);
            isvolblowup2 = retlast>0 & (retlast-mean(barsizerest))/std(barsizerest)>norminv(0.99);
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
                kelly = kelly_k('volblowup2',fut.asset_name,kellytables.signal_l,kellytables.asset_list,kellytables.kelly_matrix_l,0);
                wprob = kelly_k('volblowup2',fut.asset_name,kellytables.signal_l,kellytables.asset_list,kellytables.winprob_matrix_l,0);
                if ~isnan(kelly)
                    if kelly >= 0.146 || (kelly > 0.12 && wprob > 0.5)
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
            poptrade = false;
        end
        %
        if ~poptrade
            trade = {};
            return
        end
        %
        trade = cTradeOpen('id',idx,'code',code,...
            'opendatetime', resstruct.px(idx,1),...
            'openprice',max(pxopen,condsignal.signalkellied(2)+fut.tick_size),...
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
        if resstruct.teeth(idx-1) > trade.riskmanager_.pxstoploss_
            trade.riskmanager_.pxstoploss_ = floor(resstruct.teeth(idx-1)/fut.tick_size)*fut.tick_size;
            trade.riskmanager_.closestr_ = 'fractal:teeth';
        end
        %
        trade.status_ = 'set';
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
        else
            mode = 'conditional-dntrendconfirmed';
        end
        signalinfo = struct('name','fractal','type','breachdn-S',...
            'hh', condsignal.signalkellied(2),...
            'll', condsignal.signalkellied(3),...
            'mode',mode,'nfractal',nfractal,...
            'frequency',freq,...
            'hh1', condsignal.signalkellied(5),...
            'll1', condsignal.signalkellied(6));
        %
        riskmanager = struct('hh0_',signalinfo.hh,'hh1_',signalinfo.hh,...
            'll0_',signalinfo.ll,'ll1_',signalinfo.ll,...
            'type_','breachdn-S',...
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
        %2.check whether volblowup2,i.e.market jumps at begining
        if pxlow<=condsignal.signalkellied(3)-fut.tick_size && ...
                pxopen>condsignal.signalkellied(3)-1.618*(condsignal.signalkellied(2)-condsignal.signalkellied(3))
            px = ei_.px;
            idxll = ei_.idxll;
            idx_lastll = find(idxll == -1,1,'last');
            nkfromll = size(px,1) - idx_lastll+nfractal+1;
            barsizerest = px(end-nkfromll+1:end,3)-px(end-nkfromll+1:end,4);
            if pxopen <= condsignal.signalkellied(3)-fut.tick_size
                lasttrade = pxopen;
            else
                lasttrade = condsignal.signalkellied(3)-fut.tick_size;
            end
            retlast = lasttrade-px(end,5);
            isvolblowup2 = retlast<0 & (abs(retlast)-mean(barsizerest))/std(barsizerest)>norminv(0.99);
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
                kelly = kelly_k('volblowup2',fut.asset_name,kellytables.signal_s,kellytables.asset_list,kellytables.kelly_matrix_s,0);
                wprob = kelly_k('volblowup2',fut.asset_name,kellytables.signal_s,kellytables.asset_list,kellytables.winprob_matrix_s,0);
                if ~isnan(kelly)
                    if kelly >= 0.146 || (kelly > 0.12 && wprob > 0.5)
                        poptrade = true;
                    else
                        poptrade = false;
                    end
                else
                    poptrade = false;
                end
            end
        else
            poptrade = false;
        end
        %
        if ~poptrade
            trade = {};
            return
        end
        %
        trade = cTradeOpen('id',idx,'code',code,...
            'opendatetime', resstruct.px(idx,1),...
            'openprice',min(pxopen,condsignal.signalkellied(3)-fut.tick_size),...
            'opendirection',-1,...
            'openvolume',1);
        trade.setsignalinfo('name','fractal','extrainfo',signalinfo);
        trade.setriskmanager('name','spiderman','extrainfo',riskmanager);
        trade.riskmanager_.setusefractalupdateflag(false);
        trade.riskmanager_.setusefibonacciflag(true);
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
        if resstruct.teeth(idx) < trade.riskmanager_.pxstoploss_
            trade.riskmanager_.pxstoploss_ = ceil(resstruct.teeth(idx)/fut.tick_size)*fut.tick_size;
            trade.riskmanager_.closestr_ = 'fractal:teeth';
        end
        %
        trade.status_ = 'set';
    elseif condsignal.signalkellied(4) ~= -2
        error('not implemented yet!!!')
    end
end
    
    
end






