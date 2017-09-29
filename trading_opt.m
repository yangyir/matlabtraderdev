stratopt = cStratOptSingleStraddle;
%%
for i = 1:size(strikes_soymeal)
    stratopt.registerinstrument(opt_c_m1801{i});
    stratopt.registerinstrument(opt_p_m1801{i});
    %
    qms_opt_ctp.registerinstrument(opt_c_m1801{i});
    qms_opt_ctp.registerinstrument(opt_p_m1801{i});
end

% for i = 1:size(strikes_sugar)
%     stratopt.registerinstrument(opt_c_SR801{i});
%     stratopt.registerinstrument(opt_p_SR801{i});
%     %
%     qms_ctp.registerinstrument(opt_c_SR801{i});
%     qms_ctp.registerinstrument(opt_p_SR801{i});
% end

%%
qms_opt_ctp.refresh;quotes = qms_opt_ctp.getquote;for i = 1:size(quotes,1), quotes{i}.print; end

%%
fprintf('\n')
stratopt.update(qms_opt_ctp);
%%
stratopt.querypositions(c_ly,qms_opt_ctp);

%%
opt_savepositions(stratopt.instruments_,stratopt.underliers_,c_ly,qms_bbg)

%%
% fn = 'opt_pos_20170918';
% portfoliocarry = opt_loadpositions(fn);

%%
lastbd = getlastbusinessdate;
%print the pnl and risk as of the position carried from the previous
%business date of the last business date 
[pnltbl1,risktbl1] = stratopt.pnlrisk1(lastbd)


%%
stratopt.updatecost(lastbd,risktbl1);
%%
qms_opt_ctp.refresh;
quotes = qms_opt_ctp.getquote;
[pnltbl2,risktbl2] = stratopt.pnlrisk2(quotes);

%%
qms_opt_ctp.refresh
idx = 6;
q = qms_opt_ctp.getquote(opt_c_m1801{idx});
fprintf('%s %d %4.1f%%\n',q.opt_type,q.opt_strike,q.impvol*100);

%%
s1 = opt_c_m1801{idx}.code_ctp;
direction = -1;
offset = 1;

n = 1;

e1 = Entrust;
if direction == 1
    e1.fillEntrust(1,s1,direction,q.ask1,n,offset,s1);
else
    e1.fillEntrust(1,s1,direction,q.bid1,n,offset,s1);
end

c_ly.placeEntrust(e1);








