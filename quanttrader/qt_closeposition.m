function orderTicket = qt_closeposition(varargin)
p = inputParser;
p.CaseSensitive = false;p.KeepUnmatched = true;
p.addParameter('AccountSerialID',[],@isnumeric);
p.addParameter('Exchange',[],...
    @(x)validateattributes(x,{'char','numeric'},{},'','Exchange'));
p.addParameter('Symbol',{},@ischar);
p.addParameter('Direction','all',@ischar);
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
directionType = p.Results.Direction;

% check long position
orderTicket = [];
if strcmpi(directionType,'all') || strcmpi(directionType,'long')
    posidLong = SelectPsnBySymbol(symbol,exchange,accountID,double(DirectionType.LONG));
    if posidLong > 0
        orderTicket = ClosePosition(posidLong,PositionAvailVolume(),0);
    end
end

% check short position
if strcmpi(directionType,'all') || strcmpi(directionType,'short')
    posidShort = SelectPsnBySymbol(symbol,exchange,accountID,double(DirectionType.SHORT));
    if posidShort > 0
        orderTicket = ClosePosition(posidShort,PositionAvailVolume(),0);
    end
end

end