function [unwindedtrades,tblresults] = irene_backtesttradesfromcode(varargin)
%
%utility function to back-test all possible trades generated w/o kelly
%information
%
p = inputParser;
p.KeepUnmatched = true;p.CaseSensitive = false;
p.addParameter('code','',@ischar);
p.addParameter('frequency','30m',@ischar);
p.addParameter('datefrom','',@ischar);
p.addParameter('dateto','',@ischar);
p.parse(varargin{:});
code = p.Results.code;
freq = p.Results.frequency;
datefrom = p.Results.datefrom;
dateto = p.Results.dateto;

unwindedtrades = cTradeOpenArray;

try
    if isempty(datefrom) && isempty(dateto)
        trades = irene_gentradesfromcode('code',code,'frequency',freq);
    elseif ~isempty(datefrom) && isempty(dateto)
        trades = irene_gentradesfromcode('code',code,'frequency',freq,'datefrom',datefrom);
    elseif isempty(datefrom) && ~isempty(dateto)
        trades = irene_gentradesfromcode('code',code,'frequency',freq,'dateto',dateto);
    elseif ~isempty(datefrom) && ~isempty(dateto)
        trades = irene_gentradesfromcode('code',code,'frequency',freq,'datefrom',datefrom,'dateto',dateto);
    end
catch
    fprintf('irene_backtesttradesfromcode:error in gentradesfrom %6s...\n',code);
    unwindedtrades = [];
    tblresults = [];
    return
end

ntrades = trades.latest_;

if ntrades == 0
    unwindedtrades = [];
    tblresults = [];
    return
end


for i = 1:ntrades
    try
        ut_i = charlotte_backtest_trade('trade',trades.node_(i));
        unwindedtrades.push(ut_i);
    catch
        fprintf('irene_backtesttradesfromcode:error in backtest %4s on %3dth trade...\n',code,i);
        continue
    end
end

ntrades = unwindedtrades.latest_;
code = cell(ntrades,1);
assetname = cell(ntrades,1);
bookname = cell(ntrades,1);
opensignal = cell(ntrades,1);
direction = zeros(ntrades,1);
opendatetime = cell(ntrades,1);
openprice = zeros(ntrades,1);
opennotional = zeros(ntrades,1);
pnlcash = zeros(ntrades,1);
pnlrel = zeros(ntrades,1);
closeprice = zeros(ntrades,1);
closedatetime = cell(ntrades,1);
closestr = cell(ntrades,1);
for i = 1:ntrades
    ut_i = unwindedtrades.node_(i);
    code{i} = ut_i.code_;
    assetname{i} = ut_i.instrument_.asset_name;
    bookname{i} = ut_i.bookname_;
    opensignal{i} = ut_i.opensignal_.mode_;
    direction(i) = ut_i.opendirection_;
    opendatetime{i} = ut_i.opendatetime2_;
    openprice(i) = ut_i.openprice_;
    if ~isempty(strfind(assetname{i},'govtbond'))
        opennotional(i) = openprice(i) * 10000;
    else
        opennotional(i) = openprice(i) * ut_i.instrument_.contract_size;
    end
    pnlcash(i) = ut_i.closepnl_;
    pnlrel(i) = pnlcash(i)/opennotional(i);
    closeprice(i) = ut_i.closeprice_;
    closedatetime{i} = ut_i.closedatetime2_;
    closestr{i} = ut_i.closestr_;    
end

tblresults = table(code,assetname,bookname,direction,opensignal,opendatetime,openprice,opennotional,closedatetime,closeprice,closestr,pnlcash,pnlrel);


end