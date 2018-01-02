<<<<<<< HEAD
function [ret,e] = longclosesingleinstrument(cstratobj,ctp_code,lots,closetodayFlag)
=======
function [ret,e] = longclosesingleinstrument(strategy,ctp_code,lots,closetodayFlag,spread)
>>>>>>> ea95d41cb38944a02bf105af0ad42bb7b09f07af
    if lots == 0, return; end

    if nargin < 4
        closetodayFlag = 0;
    end
    
    if isempty(cstratobj.counter_)
        fprintf('cStrat:counter not registered in strategy\n');
        return
    end

    if ~ischar(ctp_code)
        error('cStrat:shortclosesingleinstrument:invalid ctp_code input')
    end
    
    isopt = isoptchar(ctp_code);
    if isopt
        instrument = cOption(ctp_code);
    else
        instrument = cFutures(ctp_code);
    end
    instrument.loadinfo([ctp_code,'_info.txt']);
    multi = instrument.contract_size;
    if ~isempty(strfind(instrument.code_bbg,'TFC')) || ~isempty(strfind(instrument.code_bbg,'TFT'))
        multi = multi/100;
    end
    
    [f1, idx] = cstratobj.instruments_.hasinstrument(instrument);
    [f2,idxp] = cstratobj.portfolio_.hasposition(instrument);
    
    if ~f1
        fprintf('cStrat:shortclosesingleinstrument:%s not registered in strategy\n',ctp_code)
        return; 
    end
    
    if ~f2
        fprintf('cStrat:shortclosesingleinstrument:%s not traded in strategy\n',ctp_code)
        return; 
    end
    
    volume = abs(cstratobj.portfolio_.pos_list{idxp}.position_total_);
    if volume >= 0
        fprintf('cStrat:longclosesingleinstrument:%s:existing short position not found\n',ctp_code);
    end
    
    
    if abs(volume) < abs(lots)
        fprintf('cStrat:longclosesingleinstrument:%s:input size exceeds existing size\n',ctp_code);
        lots = abs(volume);
    end
    
    e = Entrust;
    direction = 1;
    offset = -1;
    if isopt
        q = cstratobj.mde_opt_.qms_.getquote(ctp_code);
    else
        q = cstratobj.mde_fut_.qms_.getquote(ctp_code);
    end
    
<<<<<<< HEAD
    orderprice = q.ask1 - cstratobj.askspread_(idx)*instrument.tick_size;
=======
    if nargin < 5
        orderprice = q.ask1 - strategy.askspread_(idx)*instrument.tick_size;
    else
        orderprice = q.ask1 - spread*instrument.tick_size;
    end
        
>>>>>>> ea95d41cb38944a02bf105af0ad42bb7b09f07af
    e.fillEntrust(1,ctp_code,direction,orderprice,lots,offset,ctp_code);
    if ~isopt, e.assetType = 'Future'; end
    e.multiplier = multi;
    if closetodayFlag, e.closetodayFlag = 1;end
    
    ret = cstratobj.counter_.placeEntrust(e);
    if ret
<<<<<<< HEAD
        cstratobj.entrusts_.push(e);
        cstratobj.entrustspending_.push(e);
        cstratobj.updateportfoliowithentrust(e);
=======
        fprintf('entrust: %d, code: %s, direct: %d, offset: %d, price: %4.2f, amount: %d\n',...
            e.entrustNo,e.instrumentCode,e.direction,e.offsetFlag,e.price,e.volume);
        strategy.entrusts_.push(e);
        strategy.entrustspending_.push(e);
        strategy.updateportfoliowithentrust(e);
>>>>>>> ea95d41cb38944a02bf105af0ad42bb7b09f07af
    end
    
end
%end of longopensigleinstrument