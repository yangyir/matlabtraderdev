codelistunique = unique(tblout2.code);
ncode = length(codelistunique);
datefrom = cell(ncode,1);
dateto = cell(ncode,1);
for i = 1:ncode
    idx = strcmpi(tblout2.code,codelistunique{i});
    tbl_i = tblout2(idx,:);
    datefrom{i} = datestr(dateadd(tbl_i.opendatetime(1,1:end),'-1b'),'yyyy-mm-dd');
    dateto{i} = datestr(dateadd(tbl_i.closedatetime(end,1:end),'1b'),'yyyy-mm-dd');
end
tblrecord = table(codelistunique,datefrom,dateto);
%
unwindedtrades_ = cTradeOpenArray;
% carriedtrades = cTradeOpenArray;
tbl2check_ = {};
uts = cell(ncode,1);
parfor i = 1:ncode
    [ut_i,ct_i] = charlotte_backtest_period('code',codelistunique{i},...
        'fromdate',datefrom{i},...
        'todate',dateto{i},...
        'kellytables',kellytables,'showlogs',false,'figureidx',4);
    uts{i} = ut_i;
end

for i = 1:ncode
    ut_i = uts{i};
    for j = 1:ut_i.latest_
        unwindedtrades_.push(ut_i.node_(j));
    end
end

if unwindedtrades_.latest_ > 0
    n = unwindedtrades_.latest_;
    codes = cell(n,1);
    bsflag = zeros(n,1);
    opendt = cell(n,1);
    openpx = zeros(n,1);
    closedt = cell(n,1);
    closepx = zeros(n,1);
    opensignal = cell(n,1);
    closestr = cell(n,1);
    closepnl = zeros(n,1);
    for i = 1:n
        t_i = unwindedtrades_.node_(i);
        codes{i} = t_i.code_;
        bsflag(i) = t_i.opendirection_;
        opendt{i} = t_i.opendatetime2_;
        openpx(i) = t_i.openprice_;
        closedt{i} = t_i.closedatetime2_;
        closepx(i) = t_i.closeprice_;
        opensignal{i} = t_i.opensignal_.mode_;
        closestr{i} = t_i.closestr_;
        closepnl(i) = t_i.closepnl_;
    end
    tbl2check_ = table(codes,bsflag,opendt,openpx,closedt,closepx,opensignal,closestr,closepnl);
end