function [bool,ordersToCancel] = qt_cancelorder(varargin)
p = inputParser;
p.CaseSensitive = false;p.KeepUnmatched = true;
p.addParameter('AccountSerialID',[],@isnumeric);
p.addParameter('Exchange',[],...
    @(x)validateattributes(x,{'char','numeric'},{},'','Exchange'));
p.addParameter('Symbol',{},@ischar);
p.addParameter('OrderType','all',@ischar);
p.parse(varargin{:});
accountID = p.Results.AccountSerialID;
exchange = p.Results.Exchange;
if ischar(exchange)
    if strcmpi(exchange,'CFFEX')
        exchange = double(ExchangeType.CFFEX);
    elseif strcmpi(exchange,'CZCE')
        exchange = double(ExchangeType.CZCE);
    elseif strcmpi(exchange,'DCE')
        exchange = double(ExchangeType.DCE);
    elseif strcmpi(exchange,'SHFE')
        exchange = double(ExchangeType.SHFE);
    else
        error('qt_cancelorder:exchange not supported')
    end
end

symbol = p.Results.Symbol;
orderType = p.Results.OrderType;
if strcmpi(orderType,'all')
    poolType = double(PoolType.ALL);
elseif strcmpi(orderType,'open')
    poolType = double(PoolType.OPEN);
elseif strcmpi(orderType,'openlong')
    poolType = double(PoolType.OPENLONG);
elseif strcmpi(orderType,'openshort')
    poolType = double(PoolType.OPENSHORT);
elseif strcmpi(orderType,'close')
    poolType = double(PoolType.CLOSE);
elseif strcmpi(orderType,'closelong')
    poolType = double(PoolType.CLOSELONG);
elseif strcmpi(orderType,'closeshort')
    poolType = double(PoolType.CLOSESHORT);
else
    error('qt_cancelorder:invalid input of order type')
end

[orderNum] = OrderTotalBySymbol(poolType,accountID,exchange,symbol);
bool = false;
if orderNum > 0
    ordersToCancel = cell(orderNum,1);
    for i = 1:orderNum
        [bool] = SelectOrderByIdx(i);
        if bool
            [orderTicket_i] = OrderTicket();
            [orderVolume_i] = OrderVolume();
            [orderType_i] = OrderType();
            [orderState_i] = OrderState(accountID,orderTicket_i);
            [bool] = CancelOrder(orderTicket_i);
            if bool
                ordersToCancel{i}.Ticket = orderTicket_i;
                ordersToCancel{i}.Volume = orderVolume_i;
                ordersToCancel{i}.Type = orderType_i;
                ordersToCancel{i}.State = orderState_i;
            end
        end
    end
else
    ordersToCancel = {};
end


end