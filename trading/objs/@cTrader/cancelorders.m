function [ret,entrusts] = cancelorders(obj,codestr,ops,varargin)
%cTrader
    variablenotused(obj);
    if ~ischar(codestr), error('cTrader:cancelorders:invalid code input');end
    if ~isa(ops,'cOps'), error('cTrader:cancelorders:invalid ops input');end
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('time',[],@isnumeric);
    p.addParameter('direction',[],@isnumeric);
    p.addParameter('offset',[],@isnumeric);
    p.addParameter('price',[],@isnumeric);
    p.addParameter('volume',[],@isnumeric);
    p.addParameter('tradeid','',@ischar);
    p.parse(varargin{:});
    t = p.Results.time;
    direction = p.Results.direction;
    offset = p.Results.offset;
    price = p.Results.price;
    volume = p.Results.volume;
    tradeid = p.Results.tradeid;
    
    use_direction = false;
    use_offset = false;
    use_price = false;
    use_volume = false;
    use_tradeid = false;
    
    if ~isempty(direction), use_direction = true;end
    if ~isempty(offset), use_offset = true;end
    if ~isempty(price),use_price = true;end
    if ~isempty(volume),use_volume = true;end
    if ~isempty(tradeid),use_tradeid = true;end
    
    if use_tradeid && use_offset
        if offset ~= -1
            error('cTrader:cancelorders:tradeid shall be used with close entrust only')
        end
    end
    
    pe = ops.entrustspending_;
    ret = 0;
    entrusts = EntrustArray;
    
    if use_tradeid
        for i = 1:pe.latest
            e = ops.entrustspending_.node(i);
            if strcmpi(e.tradeid_,tradeid)
                if strcmpi(ops.mode_,'realtime')
                    c = ops.getcounter;
                    ret = c.withdrawEntrust(e);
                    if ret
                        c.queryEntrust(e);
                        entrusts.push(e);
                        fprintf('%s cancel entrust:%d....\n',...
                            datestr(e.cancelTime,'yyyymmdd HH:MM:SS'),...
                            e.entrustNo);
                    else
                        c.queryEntrust(e);
                        if e.is_entrust_filled
                            %the entrust is actually filled special return with
                            %-1
                            ret = -1;
                            fprintf('entrust: %d not canceled but executed......\n',e.entrustNo);
                            ntrades = ops.trades_.latest_;
                            for itrade = 1:ntrades
                                trade_i = ops.trades_.node_(itrade);
                                if strcmpi(trade_i.id_,tradeid)
                                    instrument = trade_i.instrument_;
                                    trade_i.status_ = 'closed';
                                    trade_i.closedatetime1_ = t;
                                    trade_i.closeprice_ = e.price;
                                    trade_i.runningpnl_ = 0;
                                    trade_i.closepnl_ = trade_i.opendirection_*trade_i.openvolume_*(e.price-trade_i.openprice_)/ instrument.tick_size * instrument.tick_value;
                                    break
                                end
                            end
                        else
                            fprintf('WARNING:FURTHER CHECK ON ENTRUST:%d!!!\n',e.entrustNo);
                        end
                    end
                elseif strcmpi(ops.mode_,'replay')
                    e.cancelTime = t;
                    e.cancelVolume = e.volume;
                    entrusts.push(e);
                    fprintf('%s cancel entrust:%d....\n',...
                        datestr(e.cancelTime,'yyyymmdd HH:MM:SS'),...
                        e.entrustNo);
                end
                break
            end
        end
    
    else
        for i = 1:pe.latest
            e = ops.entrustspending_.node(i);
            if strcmpi(e.instrumentCode,codestr)
                flag = true;
                if use_direction
                    flag = flag & e.direction == direction;
                end
                if use_offset
                    flag = flag & e.offsetFlag == offset;
                end
                if use_price
                    flag = flag & e.price == price;
                end
                if use_volume
                    flag = flag & e.volume == volume;
                end

                if ~flag, continue; end

                if strcmpi(ops.mode_,'realtime')
                    c = ops.getcounter;
                    ret = c.withdrawEntrust(e);
                    if ret
                        %the entrust is sucessfully canceled and query the
                        %entrust again to update cancel information
                        c.queryEntrust(e);
                        entrusts.push(e);
                        fprintf('%s cancel entrust:%d....\n',...
                            datestr(e.cancelTime,'yyyymmdd HH:MM:SS'),...
                            e.entrustNo);
                    else
                        %the entrust is not canceled, reasons:
                        %1.the exchange time is passed
                        %2.the entrust is filled
                        c.queryEntrust(e);
                        if e.is_entrust_filled
                            %the entrust is actually filled special return with
                            %-1
                            ret = -1;
                            fprintf('entrust: %d not canceled but executed......\n',e.entrustNo);
                        else
                            fprintf('WARNING:FURTHER CHECK ON ENTRUST:%d!!!\n',e.entrustNo);
                        end
                    end
                elseif strcmpi(ops.mode_,'replay')
                    e.cancelTime = t;
                    e.cancelVolume = e.volume;
                    entrusts.push(e);
                    fprintf('%s cancel entrust:%d....\n',...
                        datestr(e.cancelTime,'yyyymmdd HH:MM:SS'),...
                        e.entrustNo);
                end
            end
        end
        if entrusts.latest > 0, ret = 1;end
    end
    
    nc = entrusts.latest;
    for i = 1:nc
        npending = ops.entrustspending_.latest;
        for j = npending:-1:1
            if ops.entrustspending_.node(j).entrustNo == entrusts.node(i).entrustNo
                rmidx = j;
                ops.entrustspending_.removeByIndex(rmidx);
                break
            end
        end
        nfinished = ops.entrustsfinished_.latest;
        flag = false;
        for j = 1:nfinished
            if ops.entrustsfinished_.node(j).entrustNo == entrusts.node(i).entrustNo
                flag = true;
                break
            end
        end
        if ~flag
            ops.entrustsfinished_.push(e);
        end
    end
    
end