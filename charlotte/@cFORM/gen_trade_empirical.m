function [trade] = gen_trade_empirical(obj,varargin)
% a cFORM private function
% to generate a single trended trade with input information
% to satisty:
%   1. a conditional signal is available on the previous signal LF point
%   2. HF with close price either above or below the barrier
%
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('code','',@ischar);
    p.addParameter('idx',[],@isnumeric);
    p.addParameter('condsignal',[],@isstruct);
    p.addParameter('executionmethod','HFI',@ischar);
    p.parse(varargin{:});
    code = p.Results.code;
    [flag,idxcode] = obj.hascode(code);
    if ~flag
        trade = [];
        return
    end
    idx = p.Results.idx;
    condsignal = p.Results.condsignal;
    em = p.Results.executionmethod;

    if strcmpi(em,'HFI')
        %high-frequent close breakout and execute immediately with the next open
    elseif strcmpi(em,'HFW')
        %high-frequent close breakout and wait until the price reverses,but execute
        %at the end of the HF in case the price never reverses
    elseif strcmpi(em,'HFC')
        %a combination of HFI and HFW
        %first execute 50% with the high-frequent breakout close;
        %then execute 50% either the price reverse or the end of HF in case
        %it never reverses
    else
        trade = [];
        return
    end

    
    ei_hf = obj.ei_special_{idxcode};
    ei_lf = obj.ei_signal_{idxcode};
    ei_ = fractal_truncate(ei_lf,idx-1);
    fut = obj.instruments_{idxcode};
    freq = obj.signal_freq_;
    nfractal = charlotte_freq2nfractal(freq);

    if idx+1 > size(ei_lf.px,1)
        trade = [];
        return
    end

    if strcmpi(freq,'60m') || strcmpi(freq,'h1') || strcmpi(freq,'1h')
        atrsl = 1.8;
        atrtp = 5.0;
    elseif strcmpi(freq,'240m') || strcmpi(freq,'h4') || strcmpi(freq,'4h')
        atrsl = 1.8;
        if strcmpi(code,'audusd')
            atrtp = 4.2;
        elseif strcmpi(code,'eurusd')
            atrtp = 3.0;
        elseif strcmpi(code,'gbpusd')
            atrtp = 3.4;
        elseif strcmpi(code,'usdcad')
            atrtp = 4.8;
        elseif strcmpi(code,'usdchf')
            atrtp = 3.5;
        elseif strcmpi(code,'usdjpy')
            atrtp = 3.5;
        elseif strcmpi(code,'xauusd')
            atrtp = 3.5;
        else
            trade = [];
            return
        end
    else
        trade = [];
        return
    end

     pxhigh = ei_lf.px(idx,3);
     pxlow = ei_lf.px(idx,4);
     pxopen = ei_lf.px(idx,2);
     dtopen = ei_lf.px(idx,1);

    if condsignal.directionkellied == 1 && condsignal.signalkellied(4) == 2
        poptrade =  pxhigh-condsignal.signalkellied(2)-fut.tick_size > -1e-6 & ...
                pxopen<condsignal.signalkellied(2)+2.0*(condsignal.signalkellied(2)-condsignal.signalkellied(3));
        if ~poptrade
            trade = [];
            return
        end

        idx1 = find(ei_hf.px(:,1) >= dtopen,1,'first');
        idx2 = find(ei_hf.px(:,1) < ei_lf.px(idx+1,1),1,'last');
        ei_hf_ = fractal_truncate(ei_hf,idx2,idx1);
        idx3 = find(ei_hf_.px(:,5) > condsignal.signalkellied(2)+fut.tick_size,1,'first');
        if isempty(idx3)
            trade = [];
            return
        end

        if strcmpi(em,'HFI')
            tradeopenpx = ei_hf_.px(idx3,5);%maybe next open later
        elseif strcmpi(em,'HFW')
            nhf = size(ei_hf_.px,1);
            if idx3 == nhf
                % the breakout happens at the end of the HF sequence
                tradeopenpx = ei_hf_.px(idx3,5);
            else
                reversed = false;
                for j = idx3+1:nhf
                    if ei_hf_.px(j,4) <= condsignal.signalkellied(2)
                        reversed = true;
                        break
                    end
                end
                if reversed
                    tradeopenpx = condsignal.signalkellied(2);
                else
                    tradeopenpx = ei_hf_.px(nhf,5);
                end
            end
        elseif strcmpi(em,'HFC')
            nhf = size(ei_hf_.px,1);
            if idx3 == nhf
                % the breakout happens at the end of the HF sequence
                tradeopenpx = ei_hf_.px(idx3,5);
            else
                reversed = false;
                for j = idx3+1:nhf
                    if ei_hf_.px(j,4) <= condsignal.signalkellied(2)
                        reversed = true;
                        break
                    end
                end
                if reversed
                    tradeopenpx = 0.5*(ei_hf_.px(idx3,5) + condsignal.signalkellied(2));
                else
                    tradeopenpx = 0.5*(ei_hf_.px(idx3,5) + ei_hf_.px(nhf,5));
                end
            end
        end
        %
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
        %
        signalinfo = struct('name','fractal',...
            'type','breachup-B',...
            'hh', condsignal.signalkellied(2),...
            'll', condsignal.signalkellied(3),...
            'mode',mode,...
            'nfractal',nfractal,...
            'frequency',freq,...
            'hh1', condsignal.signalkellied(5),...
            'll1', condsignal.signalkellied(6),...
            'kelly',condsignal.kelly);
        %
        riskmanager = struct('hh0_',signalinfo.hh,...
            'hh1_',signalinfo.hh,...
            'll0_',signalinfo.ll,...
            'll1_',signalinfo.ll,...
            'type_','breachup-B',...
            'wadopen_',ei_.wad(end),...
            'cpopen_',ei_.px(end,5),...
            'wadhigh_',ei_.wad(end),...
            'cphigh_',ei_.px(end,5),...
            'wadlow_',ei_.wad(end),...
            'cplow_',ei_.px(end,5),...
            'fibonacci1_',0.618*signalinfo.hh+0.382*signalinfo.hh1,...
            'fibonacci0_',signalinfo.ll,...
            'status_','unset',...
            'pxtarget_',-9.99,...
            'pxstoploss_',-9.99,...
            'tdlow_',tdlow_,...
            'tdhigh_',tdhigh_,...
            'td13high_',td13high_,...
            'td13low_',td13low_,...
            'closestr_','none',...
            'atropen_',ei_.atr(end));
        riskmanager.pxstoploss2_ = riskmanager.hh0_ - atrsl*riskmanager.atropen_;
        riskmanager.pxtarget_ = riskmanager.hh0_ + atrtp*riskmanager.atropen_;
        riskmanager.pxstoploss_ = ei_.teeth(end);

        trade = cTradeOpen('id',idx,...
            'code',code,...
            'opendatetime',dtopen,...
            'openprice',tradeopenpx,...
            'opendirection',1,...
            'openvolume',1);
        trade.countername_ = ['tc-',em];
        if ei_.hh(end) - ei_.teeth(end) > -fut.tick_size
            if ~isempty(strfind(condsignal.op{1},'strong'))
                tradername = 'strong';
            else
                tradername = 'medium';
            end
        else
            tradername = 'weak';
        end
        trade.tradername_ = tradername;
        trade.setsignalinfo('name','fractal','extrainfo',signalinfo);
        trade.setriskmanager('name','spiderman','extrainfo',riskmanager);
        trade.riskmanager_.setusefractalupdateflag(0);
        trade.riskmanager_.setusefibonacciflag(1);
        trade.riskmanager_.atropen_ = riskmanager.atropen_;
        if ~isnan(trade.riskmanager_.tdlow_)
            if trade.riskmanager_.tdlow_ - (trade.riskmanager_.tdhigh_-trade.riskmanager_.tdlow_) > trade.riskmanager_.pxstoploss_
                trade.riskmanager_.pxstoploss_ = trade.riskmanager_.tdlow_ - (trade.riskmanager_.tdhigh_-trade.riskmanager_.tdlow_);
                trade.riskmanager_.closestr_ = 'tdsq:ssbreak';
            end
        end
        if ~isnan(trade.riskmanager_.td13low_)
            if trade.riskmanager_.td13low_ - (trade.riskmanager_.td13high_ - trade.riskmanager_.td13low_) > trade.riskmanager_.pxstoploss_
                trade.riskmanager_.pxstoploss_ = trade.riskmanager_.td13low_ - (trade.riskmanager_.td13high_ - trade.riskmanager_.td13low_);
                trade.riskmanager_.closestr_ = 'tdsq:sc13break';
            end
        end
        if ei_.teeth(end) > trade.riskmanager_.pxstoploss_
            trade.riskmanager_.pxstoploss_ = floor(ei_.teeth(end)/fut.tick_size)*fut.tick_size;
            trade.riskmanager_.closestr_ = 'fractal:teeth';
        end
        trade.status_ = 'set';
        trade.riskmanager_.status_ = 'set';

    elseif condsignal.directionkellied == -1 && condsignal.signalkellied(4) == -2
        poptrade = pxlow-condsignal.signalkellied(3)+fut.tick_size<=1e-6 && ...
                pxopen>condsignal.signalkellied(3)-2.0*(condsignal.signalkellied(2)-condsignal.signalkellied(3));
        if ~poptrade
            trade = [];
            return
        end

        idx1 = find(ei_hf.px(:,1) >= dtopen,1,'first');
        idx2 = find(ei_hf.px(:,1) < ei_lf.px(idx+1,1),1,'last');
        ei_hf_ = fractal_truncate(ei_hf,idx2,idx1);
        idx3 = find(ei_hf_.px(:,5) < condsignal.signalkellied(3)-fut.tick_size,1,'first');
        if isempty(idx3)
            trade = [];
            return
        end

        if strcmpi(em,'HFI')
            tradeopenpx = ei_hf_.px(idx3,5);%maybe next open later
        elseif strcmpi(em,'HFW')
            nhf = size(ei_hf_.px,1);
            if idx3 == nhf
                % the breakout happens at the end of the HF sequence
                tradeopenpx = ei_hf_.px(idx3,5);
            else
                reversed = false;
                for j = idx3+1:nhf
                    if ei_hf_.px(j,3) >= condsignal.signalkellied(3)
                        reversed = true;
                        break
                    end
                end
                if reversed
                    tradeopenpx = condsignal.signalkellied(3);
                else
                    tradeopenpx = ei_hf_.px(nhf,5);
                end
            end
        elseif strcmpi(em,'HFC')
            nhf = size(ei_hf_.px,1);
            if idx3 == nhf
                % the breakout happens at the end of the HF sequence
                tradeopenpx = ei_hf_.px(idx3,5);
            else
                reversed = false;
                for j = idx3+1:nhf
                    if ei_hf_.px(j,3) >= condsignal.signalkellied(3)
                        reversed = true;
                        break
                    end
                end
                if reversed
                    tradeopenpx = 0.5*(ei_hf_.px(idx3,5)+condsignal.signalkellied(3));
                else
                    tradeopenpx = 0.5*(ei_hf_.px(idx3,5)+ei_hf_.px(nhf,5));
                end
            end
        end
        %
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
        riskmanager = struct('hh0_',signalinfo.hh,...
            'hh1_',signalinfo.hh,...
            'll0_',signalinfo.ll,...
            'll1_',signalinfo.ll,...
            'type_','breachdn-S',...
            'wadopen_',ei_.wad(end),...
            'cpopen_',ei_.px(end,5),...
            'wadhigh_',ei_.wad(end),...
            'cphigh_',ei_.px(end,5),...
            'wadlow_',ei_.wad(end),...
            'cplow_',ei_.px(end,5),...
            'fibonacci1_',signalinfo.hh,...
            'fibonacci0_',0.618*signalinfo.ll+0.382*signalinfo.ll1,...
            'status_','unset',...
            'pxtarget_',-9.99,...
            'pxstoploss_',-9.99,...
            'tdlow_',tdlow_,...
            'tdhigh_',tdhigh_,...
            'td13high_',td13high_,...
            'td13low_',td13low_,...
            'closestr_','none',...
            'atropen_',ei_.atr(end));
        riskmanager.pxstoploss2_ = riskmanager.ll0_ + atrsl*riskmanager.atropen_;
        riskmanager.pxtarget_ = riskmanager.ll0_ - atrtp*riskmanager.atropen_;
        riskmanager.pxstoploss_ = ei_.teeth(end);
        trade = cTradeOpen('id',idx,...
            'code',code,...
            'opendatetime',dtopen,...
            'openprice',tradeopenpx,...
            'opendirection',-1,...
            'openvolume',1);
        trade.countername_ = ['tc-',em];
        if ei_.ll(end) - ei_.teeth(end) < fut.tick_size
            if ~isempty(strfind(condsignal.op{2},'strong'))
                tradername = 'strong';
            else
                tradername = 'medium';
            end
        else
            tradername = 'weak';
        end
        trade.tradername_ = tradername;
        trade.setsignalinfo('name','fractal','extrainfo',signalinfo);
        trade.setriskmanager('name','spiderman','extrainfo',riskmanager);
        trade.riskmanager_.setusefractalupdateflag(0);
        trade.riskmanager_.setusefibonacciflag(1);
        trade.riskmanager_.atropen_ = riskmanager.atropen_;
        if ~isnan(trade.riskmanager_.tdhigh_)
            if trade.riskmanager_.tdhigh_ + (trade.riskmanager_.tdhigh_-trade.riskmanager_.tdlow_) < trade.riskmanager_.pxstoploss_
                trade.riskmanager_.pxstoploss_ = trade.riskmanager_.tdhigh_ + (trade.riskmanager_.tdhigh_-trade.riskmanager_.tdlow_);
                trade.riskmanager_.closestr_ = 'tdsq:bsbreak';
            end
        end
        if ~isnan(trade.riskmanager_.td13low_)
            if trade.riskmanager_.td13high_ + (trade.riskmanager_.td13high_-trade.riskmanager_.td13low_) > trade.riskmanager_.pxstoploss_
                trade.riskmanager_.pxstoploss_ = trade.riskmanager_.td13high_ + (trade.riskmanager_.td13high_-trade.riskmanager_.td13low_);
                trade.riskmanager_.closestr_ = 'tdsq:bc13break';
            end
        end
        if ei_.teeth(end) < trade.riskmanager_.pxstoploss_
            trade.riskmanager_.pxstoploss_ = ceil(ei_.teeth(end)/fut.tick_size)*fut.tick_size;
            trade.riskmanager_.closestr_ = 'fractal:teeth';
        end
        trade.status_ = 'set';
        trade.riskmanager_.status_ = 'set';
    end

end