function [ret,entrust,msg] = placeorder(obj,codestr,bsflag,ocflag,px,lots,ops,varargin)
%cTrader
    if ~ischar(codestr), error('cTrader:placeorder:invalid code input'); end
    if ~ischar(bsflag), error('cTrader:placeorder:invalid buy/sell flag input'); end
    if ~ischar(ocflag), error('cTrader:placeorder:invalid open/close flag input'); end
    if ~isnumeric(px), error('cTrader:placeorder:invalid price input');end
    if ~isnumeric(lots) || lots <= 0, error('cTrader:placeorder:invalid lots input');end
    if ~isa(ops,'cOps'), error('cTrader:placeorder:invalid ops input');end
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('time',[],@isnumeric);
    p.addParameter('signalinfo',{},@(x) validateattributes(x,{'struct','cell'},{},'','signalinfo'));
    p.parse(varargin{:});
    ordertime = p.Results.time;
    signalinfo = p.Results.signalinfo;
    
    f1 = obj.hasbook(ops.book_);
    if ~f1, obj.addbook(ops.book_); end
    
    entrust = Entrust;
    
    if strcmpi(bsflag,'b')
        direction = 1;
    elseif strcmpi(bsflag,'s')
        direction = -1;
    else
        error('cTrader:placeorder:invalid buy/sell flag input'); 
    end
    
    if strcmpi(ocflag,'o')
        offset = 1;
    elseif strcmpi(ocflag,'c') || strcmpi(ocflag,'ct')
        offset = -1;
    else
        error('cTrader:placeorder:invalid open/close flag input'); 
    end
    
    isopt = isoptchar(codestr);
    if isopt
        s = cOption(codestr);
    else
        s = cFutures(codestr);
    end
    s.loadinfo([codestr,'_info.txt']);
    cs = s.contract_size;
    if ~isempty(strfind(s.code_bbg,'TFC')) || ~isempty(strfind(s.code_bbg,'TFT'))
        cs = cs/100;
    end
    
    entrust.fillEntrust(1,codestr,direction,px,lots,offset,codestr);
    
    modestr = ops.mode_;
    
    if ~isopt, entrust.assetType = 'Future';end
    entrust.multiplier = cs;
    if strcmpi(ocflag,'ct'), entrust.closetodayFlag = 1;end
    
    entrust.time = ordertime;
    entrust.date = floor(ordertime);
    if ~isempty(signalinfo)
        entrust.signalinfo_ = signalinfo;
    end
    
    warning('off');
    if strcmpi(modestr,'realtime')
        counter = ops.getcounter;
        ret = counter.placeEntrust(entrust);
    elseif strcmpi(modestr,'replay') || strcmpi(modestr,'demo')
        %in the replay mode we assume the entrust is always placed
        ret = 1;
        n = ops.entrusts_.latest;
        entrust.entrustNo = n+1;
    end
    if ret
        %entrust has been successfully placed
        entrust.date = floor(ordertime);
        entrust.time = ordertime;
        
        %tradeid_ convention bookname_ctpcode_datestr_num
        if offset == 1
            n = ops.entrusts_.latest;
            tradeid = [ops.book_.bookname_,'_',codestr,'_',datestr(ordertime,'yyyymmddHHMMSS'),'_',num2str(n)];
            entrust.tradeid_ = tradeid;
        end
                
        msg = sprintf('%s entrust:%2d,code:%8s,direct:%2d,offset:%2d,price:%6s,volume:%3d placed',...
            datestr(entrust.time,'yyyymmdd HH:MM:SS'),...
            entrust.entrustNo,entrust.instrumentCode,entrust.direction,entrust.offsetFlag,num2str(entrust.price),entrust.volume);
        fprintf('%s\n',msg);
        ops.entrusts_.push(entrust);
        ops.entrustspending_.push(entrust);
        if strcmpi(modestr,'realtime')
            counter.queryEntrust(entrust);
        end
    else
        %NOTE:ONLY HAPPENS IN REALTIME MODE
        %note:sometimes the entrust is placed but placeEntrust doesn't
        %return the right information, as a result, we need to double check
        %whether the entrust is filled or canceled
        counter.queryEntrust(entrust);
        if entrust.is_entrust_filled
            %volume > 0 && volume == dealVolume
            ret = true;
            entrust.date = floor(ordertime);
            entrust.time = ordertime;
            
            %tradeid_ convention bookname_ctpcode_datestr_num
            if offset == 1
                n = ops.entrusts_.latest;
                tradeid = [ops.book_.bookname_,'_',codestr,'_',datestr(ordertime,'yyyymmddHHMMSS'),'_',num2str(n)];
                entrust.tradeid_ = tradeid;
            end
            msg = sprintf('%s entrust:%2d,code:%8s,direct:%2d,offset:%2d,price:%6s,volume:%3d placed',...
                datestr(entrust.time,'yyyymmdd HH:MM:SS'),...
                entrust.entrustNo,entrust.instrumentCode,entrust.direction,entrust.offsetFlag,num2str(entrust.price),entrust.volume);
            fprintf('%s\n',msg);
            ops.entrusts_.push(entrust);
            ops.entrustspending_.push(entrust);
        elseif entrust.is_entrust_canceled
            ret = false;
            msg = sprintf('%s entrust:%2d,code:%8s,direct:%2d,offset:%2d,price:%6s,volume:%3d failed to place',...
                datestr(ordertime,'yyyymmdd HH:MM:SS'),...
                entrust.entrustNo,entrust.instrumentCode,entrust.direction,entrust.offsetFlag,num2str(entrust.price),entrust.volume);
            fprintf('%s\n',msg);
            ops.entrusts_.push(entrust);
            ops.entrustspending_.push(entrust);
        else
            ret = false;
            msg = sprintf('%s entrust:%2d,code:%8s,direct:%2d,offset:%2d,price:%6s,volume:%3d unknown error!!!',...
                datestr(ordertime,'yyyymmdd HH:MM:SS'),...
                entrust.entrustNo,entrust.instrumentCode,entrust.direction,entrust.offsetFlag,num2str(entrust.price),entrust.volume);
            fprintf('%s\n',msg);
            ops.entrusts_.push(entrust);
            ops.entrustspending_.push(entrust);
        end
    end
    
end