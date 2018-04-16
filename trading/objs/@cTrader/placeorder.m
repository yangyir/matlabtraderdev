function [ret,entrust] = placeorder(obj,codestr,bsflag,ocflag,px,lots,ops)
%cTrader
    if ~ischar(codestr), error('cTrader:placeorder:invalid code input'); end
    if ~ischar(bsflag), error('cTrader:placeorder:invalid buy/sell flag input'); end
    if ~ischar(ocflag), error('cTrader:placeorder:invalid open/close flag input'); end
    if ~isnumeric(px), error('cTrader:placeorder:invalid price input');end
    if ~isnumeric(lots) || lots <= 0, error('cTrader:placeorder:invalid lots input');end
    if ~isa(ops,'cOps'), error('cTrader:placeorder:invalid ops input');end
    
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
    elseif strcmpi(ocflag,'c')
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
    
    if ~isopt, entrust.assetType = 'Future';end
    entrust.multiplier = cs;
    if strcmpi(ocflag,'ct'), entrust.closetodayFlag = 1;end
    
    warning('off');
    ret = ops.book_.counter_.placeEntrust(entrust);
    if ret
        fprintf('placed entrust: %d, code: %s, direct: %d, offset: %d, price: %4.2f, amount: %d\n',...
            entrust.entrustNo,entrust.instrumentCode,entrust.direction,entrust.offsetFlag,entrust.price,entrust.volume);
        ops.entrusts_.push(entrust);
        ops.entrustspending_.push(entrust);
    end
    
end