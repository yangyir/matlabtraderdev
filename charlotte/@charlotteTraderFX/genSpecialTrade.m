function [trade,sametradefound] = genSpecialTrade(obj,condsignal,eisignal,pxspecial,ordertype)
% a charlotteTraderFX method
% it is ONLY used when there is an conditional signal with resistance
% above current spot or support under current spot
% the trade was executed once the high or low hit the barrier and this
% ended up with lots of false breakouts
% NOW the trade is executed if and only if the close of a higher frequent
% bar is above/below the barrier within the signal bar time range
% that's why we call it special trade
% pxspecial is the close price of a particular bar with its close
% above/below the resistance/support

    sametradefound = false;
    
    if ~(strcmpi(ordertype,'market') || strcmpi(ordertype,'limit') || strcmpi(ordertype,'stop'))
        error('genSpecialTrade:invalid ordertype...');
    end    

    freq = condsignal.frequency;
    code = condsignal.code;
    direction = condsignal.directionkellied;
    
    % first need to make sure there is no same special trade already
    nspecialtrades = obj.specialbook_.latest_;
    for i = 1:nspecialtrades
        trade_i = obj.specialbook_.node_(i);
        if strcmpi(trade_i.status_,'closed'), continue;end
        if strcmpi(trade_i.riskmanager_.status_,'closed'),continue;end
        if strcmpi(trade_i.code_,code) && ...
                strcmpi(trade_i.opensignal_.frequency_,freq) && ...
                sign(trade_i.opendirection_) == direction && ...
                abs(trade_i.opendatetime1_ - eisignal.px(end,1)) < 1/1440
            sametradefound = true;
            break
        end
    end
    
    if sametradefound
        trade = [];
        return
    end
    
    nfractal = charlotte_freq2nfractal(freq);
    
    if strcmpi(freq,'5m') || strcmpi(freq,'m5') 
        tickratio = 0;
    else
        tickratio = 1;
    end
    
    if strcmpi(freq,'240m') || strcmpi(freq,'4h') || strcmpi(freq,'h4')
        if strcmpi(code,'audusd')
            atrsl = 1.5;
            atrtp = 4.2;
        elseif strcmpi(code,'eurusd')
            atrsl = 1.5;
            atrtp = 3.0;
        elseif strcmpi(code,'gbpusd')
            atrsl = 1.5;
            atrtp = 3.4;
        elseif strcmpi(code,'usdcad')
            atrsl = 1.8;
            atrtp = 4.8;
        elseif strcmpi(code,'usdchf')
            atrsl = 1.7;
            atrtp = 3.5;
        elseif strcmpi(code,'usdjpy')
            atrsl = 1.6;
            atrtp = 3.5;
        elseif strcmpi(code,'xauusd')
            atrsl = 1.8;
            atrtp = 3.5;
        else
            atrsl = 2.0;
            atrtp = 4.0;
        end
    else
        %TODO:WE NEED TO DO THE SAME CALIBRATION FOR H1 CASES...
        atrsl = 2.0;
        atrtp = 4.0;
    end

    fut = code2instrument(code);

    if direction == 1
        if condsignal.signalkellied(4) == 2
            td13high_ = NaN;
            td13low_ = NaN;
            tdlow_ = NaN;
            tdhigh_ = NaN;
            if condsignal.signalkellied(9) == 21
                mode = 'conditional-uptrendconfirmed-1';
            elseif condsignal.signalkellied(9) == 22
                mode = 'conditional-uptrendconfirmed-2';
                sslastidx = find(eisignal.ss>=9,1,'last');
                sslastval = eisignal.ss(sslastidx);
                tdhigh_ = max(eisignal.px(sslastidx-sslastval+1:sslastidx,3));
                tdidx_ = find(eisignal.px(sslastidx-sslastval+1:sslastidx,3) == tdhigh_,1,'last') + sslastidx-sslastval;
                tdlow_ = eisignal.px(tdidx_,4);
            elseif condsignal.signalkellied(9) == 23
                mode = 'conditional-uptrendconfirmed-3';
                sclastidx = find(eisignal.sc==13,1,'last');
                td13low_ = eisignal.px(sclastidx,4);
                td13high_ = eisignal.px(sclastidx,5);
            else
                mode = 'conditional-uptrendconfirmed';
            end
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
            riskmanager = struct('hh0_',signalinfo.hh,'hh1_',signalinfo.hh,...
                'll0_',signalinfo.ll,'ll1_',signalinfo.ll,...
                'type_','breachup-B',...
                'wadopen_',eisignal.wad(end),...
                'cpopen_',eisignal.px(end,5),...
                'wadhigh_',eisignal.wad(end),...
                'cphigh_',eisignal.px(end,5),...
                'wadlow_',eisignal.wad(end),...
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
                'atropen_',eisignal.atr(end));
            %
            if strcmpi(ordertype,'market')
                tradeopenpx = pxspecial;
            else
                tradeopenpx = condsignal.signalkellied(2) + tickratio*fut.tick_size;
            end
            riskmanager.pxstoploss2_ = tradeopenpx - atrsl*riskmanager.atropen_;
            riskmanager.pxtarget_ = tradeopenpx + atrtp*riskmanager.atropen_;
            riskmanager.pxstoploss_ = eisignal.teeth(end);
            
            %TODO:MAYBE WE NEED TO CHECK THE VOLBLOWUP2 CASE...
            trade = cTradeOpen('id',length(eisignal.atr),'code',code,...
                'opendatetime', eisignal.px(end,1),...
                'openprice',tradeopenpx,...
                'opendirection',3,...
                'openvolume',1);
            if eisignal.hh(end) - eisignal.teeth(end) > -fut.tick_size
                if ~isempty(strfind(condsignal.op{1},'strong'))
                    tradername = 'strong';
                else
                    tradername = 'medium';
                end
            else
                tradername = 'weak';
            end
            trade.tradername_ = tradername;
            trade.countername_ = 'tc';
            
            trade.setsignalinfo('name','fractal','extrainfo',signalinfo);
            trade.setriskmanager('name','spiderman','extrainfo',riskmanager);
            trade.riskmanager_.setusefractalupdateflag(0);
            trade.riskmanager_.setusefibonacciflag(1);
            trade.riskmanager_.atropen_ = riskmanager.atropen_;
            %
            if ~isnan(trade.riskmanager_.tdlow_)
                if trade.riskmanager_.tdlow_ - (trade.riskmanager_.tdhigh_-trade.riskmanager_.tdlow_) > trade.riskmanager_.pxstoploss_
                    trade.riskmanager_.pxstoploss_ = trade.riskmanager_.tdlow_ - (trade.riskmanager_.tdhigh_-trade.riskmanager_.tdlow_);
                    trade.riskmanager_.closestr_ = 'tdsq:ssbreak';
                end
            elseif ~isnan(trade.riskmanager_.td13low_)
                if trade.riskmanager_.td13low_ - (trade.riskmanager_.td13high_ - trade.riskmanager_.td13low_) > trade.riskmanager_.pxstoploss_
                    trade.riskmanager_.pxstoploss_ = trade.riskmanager_.td13low_ - (trade.riskmanager_.td13high_ - trade.riskmanager_.td13low_);
                    trade.riskmanager_.closestr_ = 'tdsq:sc13break';
                end
            else
                %
            end
            %
            trade.status_ = 'unset';
            trade.riskmanager_.status_ = 'unset';
        elseif condsignal.signalkellied(4) ~= 2
            error('not implemented yet!!!')
        end
    elseif direction == -1
        if condsignal.signalkellied(4) == -2
            td13high_ = NaN;
            td13low_ = NaN;
            tdlow_ = NaN;
            tdhigh_ = NaN;
            if condsignal.signalkellied(9) == -21
                mode = 'conditional-dntrendconfirmed-1';
            elseif condsignal.signalkellied(9) == -22
                mode = 'conditional-dntrendconfirmed-2';
                bslastidx = find(eisignal.bs>=9,1,'last');
                bslastval = eisignal.bs(bslastidx);
                tdlow_ = min(eisignal.px(bslastidx-bslastval+1:bslastidx,4));
                tdidx_ = find(eisignal.px(bslastidx-bslastval+1:bslastidx,4) == tdlow_,1,'last') + bslastidx-bslastval;
                tdhigh_ = eisignal.px(tdidx_,3);
            elseif condsignal.signalkellied(9) == -23
                mode = 'conditional-dntrendconfirmed-3';
                bclastidx = find(eisignal.bc==13,1,'last');
                td13high_ = eisignal.px(bclastidx,3);
                td13low_ = eisignal.px(bclastidx,4);
            else
                mode = 'conditional-dntrendconfirmed';
            end
            signalinfo = struct('name','fractal',...
                'type','breachdn-S',...
                'hh', condsignal.signalkellied(2),...
                'll', condsignal.signalkellied(3),...
                'mode',mode,...
                'nfractal',nfractal,...
                'frequency',freq,...
                'hh1', condsignal.signalkellied(5),...
                'll1', condsignal.signalkellied(6),...
                'kelly',condsignal.kelly);
            %
            riskmanager = struct('hh0_',signalinfo.hh,'hh1_',signalinfo.hh,...
                'll0_',signalinfo.ll,'ll1_',signalinfo.ll,...
                'type_','breachdn-S',...
                'wadopen_',eisignal.wad(end),...
                'cpopen_',eisignal.px(end,5),...
                'wadhigh_',eisignal.wad(end),...
                'cphigh_',eisignal.px(end,5),...
                'wadlow_',eisignal.wad(end),...
                'cplow_',eisignal.px(end,5),...
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
                'atropen_',eisignal.atr(end));
            %
            if strcmpi(ordertype,'market')
                tradeopenpx = pxspecial;
            else
                tradeopenpx = condsignal.signalkellied(3)-tickratio*fut.tick_size;
            end
            riskmanager.pxstoploss2_ = tradeopenpx + atrsl*riskmanager.atropen_;
            riskmanager.pxtarget_ = tradeopenpx - atrtp*riskmanager.atropen_;
            riskmanager.pxstoploss_ = eisignal.teeth(end);
            
            %TODO:MAYBE WE NEED TO CHECK THE VOLBLOWUP2 CASE...
            trade = cTradeOpen('id',length(eisignal.atr),'code',code,...
                'opendatetime', eisignal.px(end,1),...
                'openprice',tradeopenpx,...
                'opendirection',-3,...
                'openvolume',1);
            if eisignal.ll(end) - eisignal.teeth(end) < fut.tick_size
                if ~isempty(strfind(condsignal.op{2},'strong'))
                    tradername = 'strong';
                else
                    tradername = 'medium';
                end
            else
                tradername = 'weak';
            end
            trade.tradername_ = tradername;
            trade.countername_ = 'tc';
            
            trade.setsignalinfo('name','fractal','extrainfo',signalinfo);
            trade.setriskmanager('name','spiderman','extrainfo',riskmanager);
            trade.riskmanager_.setusefractalupdateflag(0);
            trade.riskmanager_.setusefibonacciflag(1);
            trade.riskmanager_.atropen_ = riskmanager.atropen_;
            %
            if ~isnan(trade.riskmanager_.tdlow_)
                if trade.riskmanager_.tdhigh_ + (trade.riskmanager_.tdhigh_-trade.riskmanager_.tdlow_) < trade.riskmanager_.pxstoploss_
                    trade.riskmanager_.pxstoploss_ = trade.riskmanager_.tdhigh_ + (trade.riskmanager_.tdhigh_-trade.riskmanager_.tdlow_);
                    trade.riskmanager_.closestr_ = 'tdsq:bsbreak';
                end
            elseif ~isnan(trade.riskmanager_.td13low_)
                if trade.riskmanager_.td13high_ + (trade.riskmanager_.td13high_-trade.riskmanager_.td13low_) > trade.riskmanager_.pxstoploss_
                    trade.riskmanager_.pxstoploss_ = trade.riskmanager_.td13high_ + (trade.riskmanager_.td13high_-trade.riskmanager_.td13low_);
                    trade.riskmanager_.closestr_ = 'tdsq:bc13break';
                end
            else
            end
            %
            trade.status_ = 'unset';
            trade.riskmanager_.status_ = 'unset';
        elseif condsignal.signalkellied(4) ~= -2
            error('not implemented yet!!!')
        end
    end
    
    if ~isempty(trade)
        obj.specialbook_.push(trade);
    end

end