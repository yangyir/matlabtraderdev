classdef cTradingPlatform
    %note:the tradingplatform will refresh with its orders and trades after
    %the trading session for each trading day after 3pm
    properties (Access = private)
        pOrders
        pTrades
        pPool
    end
    
    methods
        function obj = cTradingPlatform(varargin)
            obj = init(obj,varargin{:});
        end
    end
        
    methods (Access = public)
        function printpositions(obj,varargin)
            positions = obj.getposition(varargin{:});
            if ~isempty(positions)
                n = size(positions,1);
                if n == 1
                    if iscell(positions)
                        positions{1}.print;
                    else
                        positions.print;
                    end
                else
                    for i = 1:size(positions,1)
                        positions{i}.print;
                    end
                end
            end
%             obj.pPool.print;
        end %end of function "printposition"
        %
        
        function obj = clearorders(obj)
            obj.pOrders = {};
        end %end of function "clearorders"
        %
        
        function obj = cleartrades(obj)
            obj.pTrades = {};
        end %end of function "cleartrades"
        %
        
        function pnl = calcpnl(obj,underlierinfo)
            p = inputParser;
            p.addRequired('UnderlierInfo',@(x)validateattributes(x,{'struct','cell'},{},'','UnderlierInfo'));
            p.parse(underlierinfo);
            info = p.Results.UnderlierInfo;
            if isstruct(info)
                instrument = info.Instrument;
                pos = obj.getposition('Instrument',instrument);
                if isempty(pos)
                    pnl = 0;
                    return
                end
                cost = pos.pPrice;
                direction = pos.pDirection;
                volume = pos.pVolume;
                
                if strcmpi(direction,'buy')
                    pnl = (info.Price-cost)*volume*instrument.ContractSize;
                elseif strcmpi(direction,'sell')
                    pnl = (cost-info.Price)*volume*instrument.ContractSize;
                else
                    pnl = 0;
                end
            elseif iscell(info)
                error('not implemented yet');
                %todo
                pnl = 0.0;
                
            end
            
        end %end of calcpnl
        %
        
        function [obj,pnl] = settle(obj,settleinfo,closepnl)
            p = inputParser;
            p.addRequired('SettleInfo',@(x)validateattributes(x,{'struct','cell'},{},'','SettleInfo'));
            p.addRequired('ClosePnL',@(x)validateattributes(x,{'numeric'},{},'','ClosePnL'));
            p.parse(settleinfo,closepnl);
            info = p.Results.SettleInfo;
            pnl = p.Results.ClosePnL;
            if isstruct(info)
                instrument = info.Instrument;
                pos = obj.getposition('Instrument',instrument);
                if isempty(pos)
                    return
                end
                cost = pos.pPrice;
                direction = pos.pDirection;
                volume = pos.pVolume;
                
                if strcmpi(direction,'buy')
                    pnl = pnl + (info.Price-cost)*volume*instrument.ContractSize;
                else
                    pnl = pnl + (cost-info.Price)*volume*instrument.ContractSize;
                end
                
                %now we need to update the carry cost of position to the
                %settle price
                pos.pPrice = info.Price;
                %todo:
                
                
                
            elseif iscell(info)
                error('not implemented yet')
                %todo
                pnl = 0.0;
            end 
        end
        
        function orders = getorders(obj,varargin)
            if isempty(varargin)
                orders = obj.pOrders;
                return
            end
            
            p = inputParser;
            p.CaseSensitive = false;p.KeepUnmatched = true;
            p.addParameter('Instrument',{},@(x)validateattributes(x,{'cContract'},{},'','Instrument'));
            p.addParameter('Direction',{},@(x)validateattributes(x,{'char'},{},'','Direction'));
            p.addParameter('OffsetFlag',{},@(x)validateattributes(x,{'char'},{},'','OffsetFlag')); 
            p.parse(varargin{:});
            
            instrument = p.Results.Instrument;
            direction = p.Results.Direction;
            offsetflag = p.Results.OffsetFlag;
            if ~isempty(instrument)
                useInstrument = 1;
            else
                useInstrument = 0;
            end
            
            if ~isempty(direction)
                useDirection = 1;
            else
                useDirection = 0;
            end
            
            if ~isempty(offsetflag)
                useOffsetflag = 1;
            else
                useOffsetflag = 0;
            end
            
            n = size(obj.pOrders,1);
            orders = cell(n,1);
            
            idx = 0;
            for i = 1:n
                order_i = obj.pOrders{i};
                flag1 = false;
                if useInstrument
                    if strcmpi(order_i.pInstrument.BloombergCode,instrument.BloombergCode)
                        flag1 = true;
                    end
                else
                    flag1 = true;
                end
                
                if flag1
                    flag2 = false;
                    if useDirection
                        if strcmpi(order_i.pDirection,direction)
                            flag2 = true;
                        end
                    else
                        flag2 = true;
                    end
                end
                if flag1 && flag2
                    flag3 = false;
                    if useOffsetflag
                        if strcmpi(order_i.pOffsetFlag,offsetflag)
                            flag3 = true;
                        end
                    else
                        flag3 = true;
                    end
                end
                
                if flag1 && flag2 && flag3
                    idx=idx+1;
                    orders{idx,1}=order_i;
                end
            end
            orders = orders(1:idx,1); 
        end %end of function "getorders"
        %
        
        function trades = gettrades(obj,varargin)
            if isempty(varargin)
                trades = obj.pTrades;
                return
            end
            
            p = inputParser;
            p.CaseSensitive = false;p.KeepUnmatched = true;
            p.addParameter('Instrument',{},@(x)validateattributes(x,{'cContract'},{},'','Instrument'));
            p.addParameter('Direction',{},@(x)validateattributes(x,{'char'},{},'','Direction'));
            p.addParameter('OffsetFlag',{},@(x)validateattributes(x,{'char'},{},'','OffsetFlag')); 
            p.parse(varargin{:});
            
            instrument = p.Results.Instrument;
            direction = p.Results.Direction;
            offsetflag = p.Results.OffsetFlag;
            if ~isempty(instrument)
                useInstrument = 1;
            else
                useInstrument = 0;
            end
            
            if ~isempty(direction)
                useDirection = 1;
            else
                useDirection = 0;
            end
            
            if ~isempty(offsetflag)
                useOffsetflag = 1;
            else
                useOffsetflag = 0;
            end
            
            n = size(obj.pTrades,1);
            trades = cell(n,1);
            
            idx = 0;
            for i = 1:n
                trade_i = obj.pTrades{i};
                flag1 = false;
                if useInstrument
                    if strcmpi(trade_i.pInstrument.BloombergCode,instrument.BloombergCode)
                        flag1 = true;
                    end
                else
                    flag1 = true;
                end
                
                if flag1
                    flag2 = false;
                    if useDirection
                        if strcmpi(trade_i.pDirection,direction)
                            flag2 = true;
                        end
                    else
                        flag2 = true;
                    end
                end
                if flag1 && flag2
                    flag3 = false;
                    if useOffsetflag
                        if strcmpi(trade_i.pOffsetFlag,offsetflag)
                            flag3 = true;
                        end
                    else
                        flag3 = true;
                    end
                end
                
                if flag1 && flag2 && flag3
                    idx=idx+1;
                    trades{idx,1}=trade_i;
                end
            end
            trades = trades(1:idx,1);  
        end %end of function "gettrades"
        %
        
        function cost = calctransactioncost(obj,varargin)
            cost = 0;
            trades = gettrades(obj,varargin{:});
            for i = 1:size(trades,1)
                underlier = trades{i}.pInstrument;
                coststruct = underlier.getTransactionCost;
                if strcmpi(coststruct.Type,'REL')
                    cost = cost+coststruct.Value*underlier.ContractSize*...
                        trades{i}.pPrice*trades{i}.pVolume;
                elseif strcmpi(coststruct.Type,'ABS')
                    cost = cost+coststruct.Value*trades{i}.pVolume;
                end
                
                
            end
        end %end of function "calctransactioncost"
        %
        
        function position = getposition(obj,varargin)
            position = obj.pPool.getposition(varargin{:});
        end %end of function "getpositions"
        %
        
        function margin = calcmargin(obj,underlierinfo)
            p = inputParser;
            p.addRequired('UnderlierInfo',@(x)validateattributes(x,{'struct','cell'},{},'','UnderlierInfo'));
            p.parse(underlierinfo);
            info = p.Results.UnderlierInfo;
            if isstruct(info)
                instrument = info.Instrument;
                marginrate = instrument.getMarginRate;
                pos = obj.getposition('Instrument',instrument);
                if isempty(pos)
                    margin = 0;
                    return
                end
                px = info.Price;
                volume = pos.pVolume;
                margin = px*volume*instrument.ContractSize*marginrate;
            else
                error('not implemented yet!')
            end
        end
        
        function obj = cancleorder(obj,varargin)
        end %end of function "cancleorder"
        %
        
        function [obj,trade,order,pnl] = sendorder(obj,varargin)
            p = inputParser;
            p.CaseSensitive = false;p.KeepUnmatched = true;
            p.addParameter('Order',{},@(x)validateattributes(x,{'cOrder'},{},'','Order'));
            p.addParameter('TradeID',{},@(x)validateattributes(x,{'char','numeric','cell'},{},'','TradeID'));
            p.parse(varargin{:});
            order = p.Results.Order;
            if isempty(order)
                return
            end
            tradeid = p.Results.TradeID;
            
            %1.update the order list
            ordersOld = obj.pOrders;
            if ~isempty(ordersOld)
                ordersNew = cell(size(ordersOld,1)+1,1);
                ordersNew(1:end-1,1) = ordersOld;
                ordersNew{end,1} = order;
            else
                ordersNew = cell(1,1);
                ordersNew{1,1} = order;
            end
            obj.pOrders = ordersNew;
            
            instrument = order.pInstrument;
            posOld = obj.pPool.getposition('Instrument',instrument);
                        
            %2.on return order to book a trade assuming the order is fully
            %filled-in
            [obj,trade,order] = order2trade(obj,'Order',order,'TradeID',tradeid);
            
            %3.update existing positions
            obj.pPool = obj.pPool.updateposition(trade);
            
            %4.check whether positions associated with the input trades are
            %fully unwinded and calculate the unwind pnl in case position
            %become neutral
            pos = obj.pPool.getposition('Instrument',instrument);
            if isempty(pos) || pos.pVolume == 0
                pnl = posOld.pVolume*(order.pPrice-posOld.pPrice)*instrument.ContractSize;
            else
                pnl = 0;
            end
                 
        end % end of function "sendorder"
        %
        
    end
    
    methods (Access = private)
        function obj = init(obj,varargin)
           if isempty(varargin)
               obj.pOrders = {};
               obj.pTrades = {};
               obj.pPool = cPool;
           end
        end %end of function "init"
        %
        
        function [obj,trade,order] = order2trade(obj,varargin)
            p = inputParser;
            p.CaseSensitive = false;p.KeepUnmatched = true;
            p.addParameter('Order',{},@(x)validateattributes(x,{'cOrder'},{},'','Order'));
            p.addParameter('TradeID',{},@(x)validateattributes(x,{'char','numeric','cell'},{},'','TradeID'));
            p.parse(varargin{:});
            order = p.Results.Order;
            tradeID = p.Results.TradeID;
            if isempty(tradeID)
                tradeID = size(obj.pTrades,1)+1;
            end
            
            %assume the order is always fulfill in the market
            %todo:insert conditions to determine whether the order is all
            %traded,i.e. the ordered amount is executed in the ordered
            %price
            
            %update the order first
            volume = order.pVolumeOriginal;
            order.pVolumeTraded = volume;
            
            for i = 1:size(obj.pOrders,1)
                if strcmpi(order.pOrderID, obj.pOrders{i}.pOrderID)
                    obj.pOrders{i,1} = order;
                    break
                end
            end
            
            trade = cTrade('Order',order,'VolumeTraded',volume,...
                'TradeID',tradeID,'TraderID',order.pTraderID,'Time',order.pTime);
            tradesOld = obj.pTrades;
            tradesNew = cell(size(obj.pTrades,1)+1,1);
            tradesNew(1:end-1,1) = tradesOld;
            tradesNew{end,1} = trade;
            obj.pTrades = tradesNew;
            
        end %end of function "order2trade"
        
    end
end