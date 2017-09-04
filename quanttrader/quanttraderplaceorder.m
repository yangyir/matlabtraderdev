function orderticket = quanttraderplaceorder(varargin)
p=inputParser;
p.CaseSensitive=false;p.KeepUnmatched = true;
%inputs:
%exchange
%symbol
%direction
%volume
%price
%magicNo
%AccountSerialID
p.addParameter('Exchange',[],@isnumeric);
p.addParameter('Symbol',{},@ischar);
p.addParameter('Direction',[],@ischar);
p.addParameter('Volume',1,@isnumeric);
p.addParameter('Price',[],@isnumeric);
p.addParameter('MagicNo',[],@isnumeric);
p.addParameter('AccountSerialID',1,@isnumeric);
p.parse(varargin{:});
exchange = p.Results.Exchange;
%note:we ignore the shenzhen and hongkong stock exchange for the time
%being
if ~(exchange == 2 || exchange == 4 || exchange == 5 ||...
      exchange == 6 || exchange == 7)
  error('quanttraderplaceorder:invalid exchange input')
end

symbol = p.Results.Symbol;
if isempty(symbol)
    error('quanttraderplaceorder:invalid symbol input')
end

direction = p.Results.Direction;
if ~(strcmpi(direction,'buy') || strcmpi(direction,'sell'))
    error('quanttraderplaceorder:invalid direction input')
end

volume = p.Results.Volume;
if volume <= 0
    error('quanttraderplaceorder:invalid volume input')
end

price = p.Results.Price;
%note:if price == 0, order is placed with market quote
if price < 0
    error('quanttraderplaceorder:invalid price input')
end

magicNo = p.Results.MagicNo;
accountid = p.Results.AccountSerialID;

if strcmpi(direction,'buy')
    orderticket = PlaceOrder(exchange,symbol,double(DirectionType.LONG),volume,...
        price,magicNo,accountid);
else
    orderticket = PlaceOrder(exchange,symbol,double(DirectionType.SHORT),volume,...
        price,magicNo,accountid);
end


end