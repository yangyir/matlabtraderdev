mdeopt = cMDEOpt;
underliercode = 'cu1904';
nstrikes = 5;
[c,p] = mdeopt.loadoptions(underliercode,nstrikes);
%%
mdeopt.login('connection','ctp','countername','ccb_ly_fut');
mdeopt.start;
counter = CounterCTP.ccb_ly_fut;
counter.login;
%%
cw = [0;0;1;0;-1];
pw = [0;1;0;0;0]; 
portfolio = [c;p];
weights = [cw;pw];
greeks = mdeopt.getportfoliogreeks(portfolio,weights)
%%
entrusts = EntrustArray;
for i = 1:size(cw,1);
    if cw(i) ~= 0
        e = Entrust;
        qc = mdeopt.qms_.getquote(c{i});
        if cw(i) > 0
            cprice = qc.ask1;
        else
            cprice = qc.bid1;
        end
        e.fillEntrust(1,c{i}.code_ctp,cw(i),cprice,abs(cw(i)),1,c{i}.code_ctp);
        e.multiplier = c{i}.contract_size;
        entrusts.push(e);
    end
end
%
for i = 1:size(pw,1);
    if pw(i) ~= 0
        e = Entrust;
        qp = mdeopt.qms_.getquote(p{i});
        if cw(i) > 0
            pprice = qp.ask1;
        else
            pprice = qp.bid1;
        end
        e.fillEntrust(1,p{i}.code_ctp,pw(i),pprice,abs(pw(i)),1,p{i}.code_ctp);
        e.multiplier = p{i}.contract_size;
        entrusts.push(e);
    end
end
%%
nentrust = entrusts.latest;
for ientrust = 1:nentrust
    counter.placeEntrust(entrusts.node(ientrust));
end