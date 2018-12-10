function [] = riskmanagement_futmultiwr(strategy,dtnum)

    %registerinstrument of superclass
    riskmanagement@cStrat(strategy,dtnum);

%     ismarketopen = zeros(strategy.count,1);
%     instruments = strategy.getinstruments;
%     for i = 1:strategy.count
%         %firstly to check whether this is in trading hours
%         ismarketopen(i) = istrading(dtnum,instruments{i}.trading_hours,...
%             'tradingbreak',instruments{i}.trading_break);
%     end
%     
%     if sum(ismarketopen) == 0, return; end
% 
%     ntrades = strategy.helper_.trades_.latest_;
%     %set risk manager
%     for i = 1:ntrades
%         trade_i = strategy.helper_.trades_.node_(i);
%         if strcmpi(trade_i.status_,'closed'), continue; end
%         if ~isempty(trade_i.riskmanager_), continue;end
%         %
%         pxstoploss = -9.99;
%         pxtarget = -9.99;
%             
%         extrainfo = struct('pxstoploss',pxstoploss,...
%                 'pxtarget',pxtarget);
%         
%         trade_i.setriskmanager('name','standard','extrainfo',extrainfo);        
%     end
%     
%     %set status of trade
%     for i = 1:ntrades
%         trade_i = strategy.helper_.trades_.node_(i);
%         unwindtrade = trade_i.riskmanager_.riskmanagement('MDEFut',strategy.mde_fut_,...
%             'UpdatePnLForClosedTrade',false);
%         if ~isempty(unwindtrade)
%             instrument = unwindtrade.instrument_;
%             direction = unwindtrade.opendirection_;
%             code = instrument.code_ctp;
%             volume = unwindtrade.openvolume_;
%             bidclosespread = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','bidclosespread');
%             askclosespread = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','askclosespread');
%             lasttick = strategy.mde_fut_.getlasttick(instrument);
%             tradeid = unwindtrade.id_;
%                         
%             %we need to unwind the trade
%             if strcmpi(strategy.mode_,'replay')
%                 closetodayFlag = 0;
%             else
%                 closetodayFlag = isclosetoday(unwindtrade.opendatetime1_,lasttick(1));
%             end
%             if direction == 1
%                 overridepx = lasttick(2) + bidclosespread*instrument.tick_size;
%                 ret = strategy.shortclose(code,...
%                     volume,...
%                     closetodayFlag,...
%                     'time',lasttick(1),...
%                     'overrideprice',overridepx,...
%                     'tradeid',tradeid);
%             elseif direction == -1
%                 overridepx = lasttick(3) - askclosespread*instrument.tick_size;
%                 ret = strategy.longclose(code,...
%                     volume,...
%                     closetodayFlag,...
%                     'time',lasttick(1),...
%                     'overrideprice',overridepx,...
%                     'tradeid',tradeid);
%             end
%             %we shall only replace entrust here and we are not sure whether
%             %entrust is executed or not
%             if ~ret
%                 fprintf('%s:riskmanagement_futmultiwr:unwind trade failed!!!\n',class(strategy));
%             end  
%             
%         end
%                 
%     end
    

end
%end of riskmangement