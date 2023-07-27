function [ret] = fractal_latestposition(varargin)
%fractal utility function to return last position given the input code and
%extrainfo
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('code','',@ischar);
    p.addParameter('extrainfo','',@isstruct);
    p.addParameter('frequency','daily',@ischar);
    p.addParameter('usefractalupdate',1,@isnumeric);
    p.addParameter('usefibonacci',1,@isnumeric);
    p.parse(varargin{:});
    code = p.Results.code;
    ei = p.Results.extrainfo;
    freq = p.Results.frequency;
    if strcmpi(freq,'daily')
        nfractal = 2;
    else
        nfractal = 4;
    end
    usefracalupdateflag = p.Results.usefractalupdate;
    usefibonacciflag = p.Results.usefibonacci;

    stock = code2instrument(code);
    [idxb1,idxs1] = fractal_genindicators1(ei.px,ei.hh,ei.ll,ei.jaw,ei.teeth,ei.lips,'instrument',stock);
    try
        lastb = idxb1(end,1);
    catch
        lastb = NaN;
    end
    try
        lasts = idxs1(end,1);
    catch
        lasts = NaN;
    end
    lastentry = size(ei.px,1);
    
    ret = {};
    
    %1.the lastest entry is a bullish breach (not sure whether it is valid)
    if lastb == lastentry
        try
            previousb = idxb1(end-1,1);
        catch
            previousb = NaN;
        end
        if previousb > lasts &&  idxb1(end-1,2) ~= 1
            previousbinfo = fractal_tradeinfo_anyb('code',code,'openid',previousb,...
                'extrainfo',ei,'frequency',freq,...
                'usefractalupdate',usefracalupdateflag,...
                'usefibonacci',usefibonacciflag);
            if ~isempty(previousbinfo.trade)
                if strcmpi(previousbinfo.trade.status_,'set')
                    %the previous long trade is still alive
                    ret = previousbinfo.trade;
                end
            end
            lastsinfo.trade = {};
        else
             %need to check whether the latest short trade is closed on 
             %the same date
             lastsinfo = fractal_tradeinfo_lasts('code',code,'extrainfo',ei,'frequency',freq,...
                 'usefractalupdate',usefracalupdateflag,...
                 'usefibonacci',usefibonacciflag);
             if ~isempty(lastsinfo.trade)
                if lastsinfo.trade.closedatetime1_ == ei.px(end,1)
                    %close on the last entry date
                    ret = lastsinfo.trade;
                end
            end
        end
        %
        [~,op] = fractal_signal_unconditional(ei,stock.tick_size,nfractal);
        if op.use
            if ~isempty(ret) && ret.opendirection_ == -1
                %very rare case here,short close and long open at the same
                %time
                %not implemented for now
                fprintf('not done yet for short close and long open at the same time')
                return
            elseif ~isempty(ret) && ret.opendirection_ == 1
                fprintf('%7s:bullish live with newly added open:%s(%s)\n',code,op.comment,stock.asset_name);
            else
                trade = fractal_gentrade(ei,code,lastb,op.comment,1,freq);
                ei.latestdt = ei.px(end,1);
                ei.latestopen = ei.px(end,5);
                trade.riskmanager_.riskmanagementwithcandle([],...
                    'usecandlelastonly',true,...
                    'debug',false,...
                    'updatepnlforclosedtrade',true,...
                    'extrainfo',ei);
                ret = trade;
                fprintf('%7s:bullish open:%s(%s)\n',code,op.comment,stock.asset_name);
            end
        else
            if ~isempty(lastsinfo.trade)
                ret = lastsinfo.trade;
                if strcmpi(lastsinfo.trade.status_,'set')
                    this_direction = -1;
                elseif strcmpi(lastsinfo.trade.status_,'closed') && lastsinfo.trade.closedatetime1_ == ei.px(end,1)
                    this_direction = -0.5;
                else
                    this_direction = 0;
                end
            else
                this_direction = 0;
            end
            if op.direction == 1
                if this_direction == 0
                    fprintf('%7s:bullish invalid:%s(%s)\n',code,op.comment,stock.asset_name);
                elseif this_direction == -0.5
                    fprintf('%7s:bearish closed:%s with bullish invalid:%s(%s)\n',code,lastsinfo.trade.riskmanager_.closestr_,op.comment,stock.asset_name);
                elseif this_direction == -1
                    fprintf('%7s:bearish live with bullish invalid:%s(%s)\n',code,op.comment,stock.asset_name);
                end
            else
                if this_direction == 0
                    fprintf('%7s:bullish invalid:%s(%s)\n',code,'barrier below alligator teeth....',stock.asset_name);
                elseif this_direction == -0.5
                    fprintf('%7s:bearish closed:%s with bullish invalid:%s(%s)\n',code,lastsinfo.trade.riskmanager_.closestr_,'barrier below alligator teeth....',stock.asset_name);
                elseif this_direction == -1
                    fprintf('%7s:bearish live with bullish invalid:%s(%s)\n',code,'barrier below alligator teeth....',stock.asset_name);
                end
            end
            
        end
        return
    end
    
    %2.the latest entry is a bearish breach (not sure whether it is valid)
    if lasts == lastentry
        try
            previouss = idxs1(end-1,1);
        catch
            previouss = NaN;
        end
        if previouss > lastb && idxs1(end-1,2) ~= 1
            previoussinfo = fractal_tradeinfo_anys('code',code,'openid',previouss,...
                'extrainfo',ei,'frequency',freq,...
                'usefractalupdate',usefracalupdateflag,...
                'usefibonacci',usefibonacciflag);
            if ~isempty(previoussinfo.trade)
                if strcmpi(previoussinfo.trade.status_,'set')
                    %the previous short trade is still alive
                    ret = previoussinfo.trade;
                end
            end
            lastbinfo.trade = {};
        else
            %need to check whether the latest long trade is closed 
            %on the same date
            lastbinfo = fractal_tradeinfo_lastb('code',code,'extrainfo',ei,'frequency',freq,...
                'usefractalupdate',usefracalupdateflag,...
                'usefibonacci',usefibonacciflag);
            if ~isempty(lastbinfo.trade)
                if lastbinfo.trade.closedatetime1_ == ei.px(end,1)
                    %close on the last entry date
                    ret = lastbinfo.trade;
                end
            end
        end
        %
        [~,op] = fractal_signal_unconditional(ei,stock.tick_size,nfractal);
        if op.use
            if ~isempty(ret) && ret.opendirection_ == 1
                %very rare case here,long close and short open at the same
                %time
                %not implemented for now
                error('not done yet for long close and short open at the same time')
            elseif ~isempty(ret) && ret.opendirection_ == -1
                fprintf('%s:bearish live with newly added open:%s(%s)\n',code,op.comment,stock.asset_name);
            else
                trade = fractal_gentrade(ei,code,lasts,op.comment,-1,freq);
                ei.latestdt = ei.px(end,1);
                ei.latestopen = ei.px(end,5);
                trade.riskmanager_.riskmanagementwithcandle([],...
                    'usecandlelastonly',true,...
                    'debug',false,...
                    'updatepnlforclosedtrade',true,...
                    'extrainfo',ei);
                ret = trade;
                fprintf('%s:bearish open:%s(%s)\n',code,op.comment,stock.asset_name);
            end
        else
            if ~isempty(lastbinfo.trade)
                ret = lastbinfo.trade;
                if strcmpi(lastbinfo.trade.status_,'set')
                    this_direction = 1;
                elseif strcmpi(lastbinfo.trade.status_,'closed') && lastbinfo.trade.closedatetime1_ == ei.px(end,1)	
                    this_direction = 0.5;
                else
                    this_direction = 0;
                end
            else
                this_direction = 0;
            end
            if op.direction == -1
                if this_direction == 0
                    fprintf('%7s:bearish invalid:%s(%s)\n',code,op.comment,stock.asset_name);
                elseif this_direction == 0.5
                    fprintf('%7s:bullish closed:%s with bearish invalid:%s(%s)\n',code,lastbinfo.trade.riskmanager_.closestr_,op.comment,stock.asset_name);
                elseif this_direction == 1
                    fprintf('%7s:bullish live with bearish invalid:%s(%s)\n',code,op.comment,stock.asset_name);
                end
            else
                if this_direction == 0
                    fprintf('%7s:bearish invalid:%s(%s)\n',code,'barrier above alligator teeth....',stock.asset_name);
                elseif this_direction == 0.5
                    fprintf('%7s:bullish closed:%s with bearish invalid:%s(%s)\n',code,lastbinfo.trade.riskmanager_.closestr_,'barrier above alligator teeth....',stock.asset_name);
                else
                    fprintf('%7s:bullish live bearish invalid:%s(%s)\n',code,'barrier above alligator teeth....',stock.asset_name);
                end
            end
        end
        return
    end
    
    %3.the latest bullish breach occurs before the latest bearish breach
    if lastb > lasts
        b1type = idxb1(end,2);
        if b1type == 1, return;end
        firstlongsincelastshort = idxb1(find(idxb1(:,1)>lasts,1,'first'),1);
        [~,~,~,~,~,~,~,validtradesb,~] = fractal_gettradesummary(code,...
            'frequency',freq,...
            'direction','long',...
            'fromdate',ei.px(firstlongsincelastshort,1),...
            'usefractalupdate',usefracalupdateflag,...
            'usefibonacci',usefibonacciflag);
        for j = 1:validtradesb.latest_
            trade = validtradesb.node_(j);
            if strcmpi(trade.status_,'set')
                if trade.id_ == size(ei.px,1)
                    fprintf('%7s:bullish live-newly open(%s).\n',code,stock.asset_name);
                else
                    fprintf('%7s:bullish live(%s).\n',code,stock.asset_name);
                end
                ret = trade;
                break
            elseif strcmpi(trade.status_,'closed') && trade.closedatetime1_ >= ei.px(end,1)
                fprintf('%7s:bullish closed:%s(%s)\n',trade.code_,trade.riskmanager_.closestr_,stock.asset_name);
                ret = trade;
                break
            end
        end
        if validtradesb.latest_ > 0
            if j == validtradesb.latest_ && strcmpi(trade.status_,'closed') && trade.closedatetime1_ < ei.px(end,1)
                %last long trade already closed
                ret = trade;
            end
        end
        return
    end
    
    %4.the lasest bearish breach occurs before the latest bullish breach
    if lastb < lasts
        s1type = idxs1(end,2);
        if s1type == 1, return;end
        firstshortsincelastlong = idxs1(find(idxs1(:,1)>lastb,1,'first'),1);
        [~,~,~,~,~,~,~,~,validtradess] = fractal_gettradesummary(code,...
            'frequency',freq,...
            'direction','short',...
            'fromdate',ei.px(firstshortsincelastlong,1),...
            'usefractalupdate',usefracalupdateflag,...
            'usefibonacci',usefibonacciflag);
        for j = 1:validtradess.latest_
            trade = validtradess.node_(j);
            if strcmpi(trade.status_,'set')
                if trade.id_ == size(ei.px,1)
                    fprintf('%7s:bearish live-newly open(%s).\n',code,stock.asset_name);
                else
                    fprintf('%7s:bearish live(%s).\n',code,stock.asset_name);
                end
                ret = trade;
                break
            elseif strcmpi(trade.status_,'closed') && trade.closedatetime1_ >= ei.px(end,1)
                fprintf('%7s:bearish closed:%s(%s)\n',trade.code_,trade.riskmanager_.closestr_,stock.asset_name);
                ret = trade;
                break
            end
        end
        if validtradess.latest_ > 0
            if j == validtradess.latest_ && strcmpi(trade.status_,'closed') && trade.closedatetime1_ < ei.px(end,1)
                %last long trade already closed
                ret = trade;
            end
        end
        return
    end
end