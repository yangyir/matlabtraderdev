%% all long with strong / medium breach and it is trending
n = size(tblb_data_combo,1);
idx = zeros(n,1);
codes = cell(n,1);
assetname = cell(n,1);
openid = zeros(n,1);
closeid = zeros(n,1);
opendatetime = zeros(n,1);
opendate = zeros(n,1);
pnlrel = zeros(n,1);
notional = zeros(n,1);
openprice = zeros(n,1);
for i = 1:n
    if isempty(tblb_data_combo{i,14}),continue;end
    if isempty(tblb_data_combo{i,20}),continue;end
    if tblb_data_combo{i,2} == 3 && tblb_data_combo{i,37} == 1
        idx(i) = 1;
        codes{i} = tblb_data_combo{i,14};
        fut = code2instrument(codes{i});
        assetname{i} = fut.asset_name;
        openid(i) = tblb_data_combo{i,15};
        closeid(i) = tblb_data_combo{i,20};
        opendatetime(i) = tblb_data_combo{i,13};
        opendate(i) = getlastbusinessdate(opendatetime(i));
        pnlrel(i) = tblb_data_combo{i,18}/tblb_data_combo{i,17}/fut.contract_size;
        notional(i) = tblb_data_combo{i,17}*fut.contract_size;
        openprice(i) = tblb_data_combo{i,17};
    end
end
%
idx = logical(idx);
codes = codes(idx,:);
assetname = assetname(idx,:);
openid = openid(idx,:);
opendatetime = opendatetime(idx,:);
opendate = opendate(idx,:);
pnlrel = pnlrel(idx,:);
notional = notional(idx,:);
openprice = openprice(idx,:);
closeid = closeid(idx,:);
tbl2report = table(codes,assetname,openid,opendatetime,opendate,openprice,notional,pnlrel,closeid);
%%
assetlist = unique(tbl2report.assetname);
kellyresults = cell(size(assetlist,1),1);
for i = 1:size(assetlist,1)
    idx = strcmpi(tbl2report.assetname,assetlist{i});
    tbl_i = tbl2report(idx,:);
    n = size(tbl_i.pnlrel,1);
    winavgpnl_running = zeros(n,1);
    lossavgpnl_running = zeros(n,1);
    winp_running = zeros(n,1);
    winflag = zeros(n,1);
    wintotalpnl = 0;
    losstotalpnl = 0;
    for j = 1:size(tbl_i.pnlrel,1)
        if tbl_i.pnlrel(j) >= 0
            winflag(j) = 1;
            wintotalpnl = wintotalpnl + tbl_i.pnlrel(j);
        else
            losstotalpnl = losstotalpnl + tbl_i.pnlrel(j);
        end
        winavgpnl_running(j) = wintotalpnl/sum(winflag(1:j));
        lossavgpnl_running(j) = losstotalpnl/(j-sum(winflag(1:j)));
        winp_running(j) = sum(winflag(1:j))/j;
    end
    r_running = abs(winavgpnl_running./lossavgpnl_running);
    kelly_running = winp_running - (1-winp_running)./r_running;
    output_i.winp_running = winp_running;
    output_i.r_running = r_running;
    output_i.kelly_running = kelly_running;
    output_i.winp = winp_running(end);
    output_i.winavgpnl = winavgpnl_running(end);
    output_i.lossavgpnl = lossavgpnl_running(end);
    output_i.r = r_running(end);
    output_i.kelly = kelly_running(end);
    output_i.assetname = assetlist{i};
    output_i.ntrades = n;
    kellyresults{i} = output_i;
end
%%
i = 31;
winp_running = kellyresults{i}.winp_running;
r_running = kellyresults{i}.r_running;
kelly_running = kellyresults{i}.kelly_running;
subplot(311);plot(winp_running,'r');title(kellyresults{i}.assetname);ylabel('win prob');grid on;
subplot(312);plot(r_running,'b');ylabel('win/loss');grid on;
subplot(313);plot(kelly_running,'g');xlabel('number of trades');ylabel('kelly criteria');grid on;
disp(kellyresults{i});

