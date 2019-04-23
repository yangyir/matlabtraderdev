function [ret,e,msg] = longopen(strategy,ctp_code,lots,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = false;
    p.addParameter('spread',[],@isnumeric);
    p.addParameter('overrideprice',[],@isnumeric);
    p.addParameter('time',[],@isnumeric);
    p.addParameter('signalinfo',{},@isstruct);
    p.parse(varargin{:});
    spread = p.Results.spread;
    overridepx = p.Results.overrideprice;
    ordertime = p.Results.time;
    signalinfo = p.Results.signalinfo;
    
    if isempty(strategy.timer_) || strcmpi(strategy.timer_.running,'off')
        ret = 0;
        e = [];
        msg = sprintf('%s:longopen:strategy is not running...',class(strategy));
        fprintf('%s\n',msg);
        return
    end
    
    if ~ischar(ctp_code)
        ret = 0;
        e = [];
        msg = sprintf('%s:longopen:invalid order code...',class(strategy));
        fprintf('%s\n',msg);
        return
    end
    
    if lots <= 0
        ret = 0;
        e = [];
        msg = sprintf('%s:longopen:invalid order volume...',class(strategy));
        fprintf('%s\n',msg);
        return
    end
            
    isopt = isoptchar(ctp_code);
    instrument = code2instrument(ctp_code);
    
    if isempty(ordertime)
        if strcmpi(strategy.mode_,'realtime')
            ordertime = now;
        else
            ordertime = strategy.getreplaytime;
        end
    end
    
    if ~instrument.isable2trade(ordertime)
        ret = 0;
        e = [];
        msg = sprintf('%s:longopen:non-trableable time for %s...',class(strategy),ctp_code);
        fprintf('%s\n',msg);
        return
    end
    
    if strcmpi(strategy.mode_,'realtime')
        if isopt
            q = strategy.mde_opt_.qms_.getquote(ctp_code);
        else
            q = strategy.mde_fut_.qms_.getquote(ctp_code);
        end
        if isempty(q)
            ret = 0;
            e = [];
            msg = sprintf('%s:longopen:%s quote not found...',class(strategy),ctp_code);
            fprintf('%s\n',msg);
            return
        end
        askpx = q.ask1;
        if askpx > 1e6
            ret = 0;
            e = [];
            msg = sprintf('%s:longopen:%s reaches upper limit...',class(strategy),ctp_code);
            fprintf('%s\n',msg);
            return
        end
    elseif strcmpi(strategy.mode_,'replay')
        if isopt
            error('cStrat:longopen:not implemented yet for option in replay mode')
        else
            try
                tick = strategy.mde_fut_.getlasttick(ctp_code);
                askpx = tick(3);
            catch err
                ret = 0;
                e = [];
                msg = sprintf('%s',err.message);
                fprintf('%s\n',msg);
                return
            end       
        end
    end
    
    if ~isempty(overridepx)
        if overridepx == -1
            entrusttype = 'market';
            price = askpx;
        else
            if overridepx < askpx
                entrusttype = 'limit';
            elseif overridepx == askpx
                entrusttype = 'market';
            else
                entrusttype = 'stop';
            end
            price = overridepx;
        end
    else
        if ~isempty(spread)
            spread2use = spread;
        else
            spread2use = strategy.riskcontrols_.getconfigvalue('code',ctp_code,'propname','askopenspread');
        end
        if spread2use == 0
            entrusttype = 'market';
        elseif spread2use > 0
            entrusttype = 'limit';
        else
            entrusttype = 'stop';
        end
        price = askpx - spread2use*instrument.tick_size;
    end
    
    if ~isempty(signalinfo) && strcmpi(signalinfo.name,'paircointegration')
        %walk off the riskcontrol for now
        flag = 1;
    else
        [flag,errmsg] = strategy.riskcontrol2placeentrust(ctp_code,'price',price,'volume',lots,'direction',1);
    end
    if flag
        if isempty(signalinfo) && strcmpi(class(strategy),'cStratManual')
            freq = strategy.riskcontrols_.getconfigvalue('code',ctp_code,'propname','samplefreq');
            signalinfo = struct('name','manual','frequency',freq);
        end
        
        [ret,e,msg] = strategy.trader_.placeorder(ctp_code,'b','o',price,lots,strategy.helper_,'time',ordertime,'signalinfo',signalinfo);
        if ret
            e.date = floor(ordertime);
            e.date2 = datestr(e.date,'yyyy-mm-dd');
            e.time = ordertime;
            e.time2 = datestr(e.time,'yyyy-mm-dd HH:MM:SS');
            e.entrustType = entrusttype; 
%             strategy.updatestratwithentrust(e);
        end
    else
        ret = 0;
        e = [];
        msg = errmsg;
    end
    
end
%end of longopen