%%
stratopt = cStratOptSingleStraddle;
for i = 1:size(strikes_soymeal)
    stratopt.registerinstrument(opt_c_m1801{i});stratopt.registerinstrument(opt_p_m1801{i});
    %
    qms_opt_m.registerinstrument(opt_c_m1801{i});qms_opt_m.registerinstrument(opt_p_m1801{i});
end

%%
qms_opt_m.refresh;quotes = qms_opt_m.getquote;for i = 1:size(quotes,1), quotes{i}.print; end

%%
fprintf('\n')
stratopt.update(qms_opt_m);

%%
qms_opt_m.refresh;
stratopt.querypositions(c_ly,qms_opt_m);

%%
opt_savepositions(stratopt.instruments_,stratopt.underliers_,c_ly,qms_local)

%%
lastbd = getlastbusinessdate;
%print the pnl and risk as of the position carried from the previous
%business date of the last business date 
[pnltbl1,risktbl1] = stratopt.pnlrisk1(lastbd);
printpnltbl(pnltbl1);printrisktbl(risktbl1);
%update the cost as of the the last business date
stratopt.updatecost(lastbd,risktbl1);

%%
qms_opt_m.refresh;quotes = qms_opt_m.getquote;
[pnltbl2,risktbl2] = stratopt.pnlrisk2(quotes);

%%
qms_opt_m.refresh
idx = 1;
sec = opt_c_m1801{idx};
q = qms_opt_m.getquote(sec);
fprintf('\n%s %d %4.1f%%  %8.0f\n',q.opt_type,q.opt_strike,q.impvol*100, q.delta*q.last_trade_underlier*sec.contract_size);

%%
s1 = sec.code_ctp;
direction = -1;
offset = 1;

n = 5;

e1 = Entrust;
if direction == 1
    e1.fillEntrust(1,s1,direction,q.ask1,n,offset,s1);
else
    e1.fillEntrust(1,s1,direction,q.bid1,n,offset,s1);
end

c_ly.placeEntrust(e1);

%%
%close positions
n = 3;
direction = 1;
offset = -1;

qms_opt_m.refresh;
for i = 1:size(risktbl2.Properties.RowNames,1)
    sec = risktbl2.Properties.RowNames{i};
    if strcmpi(sec,'m1801'), continue;end
    if strcmpi(sec,'total'), continue;end
    ni = risktbl2.volume(i);
    %todo:
    %some sanity check here
    q = qms_opt_m.getquote(sec);
    code = q.code_ctp;
    e = Entrust;
    if direction == 1
        e.fillEntrust(1,sec,direction,q.ask1,min(n,abs(ni)),offset,sec);
    else
        e.fillEntrust(1,sec,direction,q.bid1,min(n,abs(ni)),offset,sec);
    end
    c_ly.placeEntrust(e);
end








