function [posVolume,positionid] = quanttraderpositionavailvolume(varargin)
p=inputParser;
p.CaseSensitive=false;p.KeepUnmatched = true;
%input:
%symbol
%exchange
%AccountSerialID
%direction
p.addParameter('Exchange',[],@isnumeric);
p.addParameter('Symbol',{},@ischar);
p.addParameter('Direction',[],@ischar);
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

accountid = p.Results.AccountSerialID;

if strcmpi(direction,'buy')
    positionid = SelectPsnBySymbol(symbol,exchange,accountid,...
        double(DirectionType.LONG));
else
    positionid = SelectPsnBySymbol(symbol,exchange,accountid,...
        double(DirectionType.SHORT));
end

if positionid < 0
    %failed to select position by symbol
    posVolume = 0;
else
    posVolume = PositionAvailVolume();
end

end