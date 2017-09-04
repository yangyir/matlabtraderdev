function orderTicket = qt_placeorder(varargin)
p = inputParser;
p.CaseSensitive = false;p.KeepUnmatched = true;
p.addParameter('AccountSerialID',[],@isnumeric);
p.addParameter('Exchange',[],...
    @(x)validateattributes(x,{'char','numeric'},{},'','Exchange'));
p.addParameter('Symbol',{},@ischar);
p.addParameter('Direction',{},@ischar);
p.addParameter('Volume',[],@isnumeric);
p.addParameter('Price',[],@isnumeric);
p.addParameter('MagicNo',[],@isnumeric);
p.parse(varargin{:});
accountID = p.Results.AccountSerialID;
exchange = p.Results.Exchange;
symbol = p.Results.Symbol;
direction = p.Results.Direction;
if strcmpi(direction,'long')
    directionType = double(DirectionType.LONG);
elseif strcmpi(direction,'short')
    directionType = double(DirectionType.SHORT);
else
    error('qt_placeorder:invalid input of direction')
end
volume = p.Results.Volume;
price = p.Results.Price;
magicNo = p.Results.MagicNo;

[orderTicket] = PlaceOrder(exchange,symbol,directionType,volume,price,magicNo,accountID);

end