function quanttradercloseposition(varargin)
p=inputParser;
p.CaseSensitive=false;p.KeepUnmatched = true;
%inputs:
%exchange
%symbol
%direction
%volume
%price
%AccountSerialID
p.addParameter('Exchange',[],@isnumeric);
p.addParameter('Symbol',{},@ischar);
p.addParameter('Direction',[],@ischar);
p.addParameter('Volume',1,@isnumeric);
p.addParameter('Price',[],@isnumeric);
p.addParameter('AccountSerialID',1,@isnumeric);
p.parse(varargin{:});
exchange = p.Results.Exchange;
%note:we ignore the shenzhen and hongkong stock exchange for the time
%being
if ~(exchange == 2 || exchange == 4 || exchange == 5 ||...
      exchange == 6 || exchange == 7)
  error('quanttradercloseposition:invalid exchange input')
end

symbol = p.Results.Symbol;
if isempty(symbol)
    error('quanttradercloseposition:invalid symbol input')
end

direction = p.Results.Direction;
if ~(strcmpi(direction,'buy') || strcmpi(direction,'sell'))
    error('quanttradercloseposition:invalid direction input')
end

volume = p.Results.Volume;
if volume <= 0
    error('quanttradercloseposition:invalid volume input')
end

price = p.Results.Price;
%note:if price == 0, order is placed with market quote
if price < 0
    error('quanttradercloseposition:invalid price input')
end

accountid = p.Results.AccountSerialID;

[availvol,positionid] = quanttraderpositionavailvolume('exchange',exchange,'symbol',symbol,...
    'direction',direction,'accountserialid',accountid);

if availvol < volume
    error('quanttradercloseposition:input volume exceeds available volume')
end

ClosePosition(positionid,volume,price);

end