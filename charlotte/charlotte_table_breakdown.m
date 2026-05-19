function [tbl_l,tbl_s] = charlotte_table_breakdown(inputtable)

signals_l = unique(inputtable.opensignal(inputtable.direction == 1));
signals_s = unique(inputtable.opensignal(inputtable.direction == -1));

nsignal_l = size(signals_l,1);
nsignal_s = size(signals_s,1);

n_l = zeros(nsignal_l+1,1);
p_l = n_l;r_l = n_l;k_l = n_l;mmd_l = n_l;wa_l = n_l;la_l = n_l;

n_s = zeros(nsignal_s,1);
p_s = n_s;r_s = n_s;k_s = n_s;mmd_s = n_s;wa_s = n_s;la_s = n_s;

for i = 1:nsignal_l+1
    if i <= nsignal_l
        signal_i_l = signals_l{i};
        idx_i_l = strcmpi(inputtable.opensignal,signal_i_l) & inputtable.direction == 1;
    else
        idx_i_l = inputtable.direction == 1;
    end

    output_i_l = kellyratio2(inputtable.pnlrel(idx_i_l,:));

    n_l(i) = output_i_l.n;
    p_l(i) = output_i_l.w;
    r_l(i) = output_i_l.r;
    k_l(i) = output_i_l.k;
    if k_l(i) == -inf
        k_l(i) = -9.99;
    end
    mmd_l(i) = output_i_l.maxdrawdown;
    wa_l(i) = output_i_l.winavg;
    la_l(i) = output_i_l.lossavg;

end
%
%
for i = 1:nsignal_s+1
    if i <= nsignal_s
        signal_i_s = signals_s{i};
        idx_i_s = strcmpi(inputtable.opensignal,signal_i_s) & inputtable.direction == -1;
    else
        idx_i_s = inputtable.direction == -1;
    end

    output_i_s = kellyratio2(inputtable.pnlrel(idx_i_s,:));

    n_s(i) = output_i_s.n;
    p_s(i) = output_i_s.w;
    r_s(i) = output_i_s.r;
    k_s(i) = output_i_s.k;
    if k_s(i) == -inf
        k_s(i) = -9.99;
    end
    mmd_s(i) = output_i_s.maxdrawdown;
    wa_s(i) = output_i_s.winavg;
    la_s(i) = output_i_s.lossavg;

end


signals_l = [signals_l;'long-all'];
signals_s = [signals_s;'short-all'];
tbl_l = table(signals_l,n_l,p_l,r_l,k_l,mmd_l,wa_l,la_l);

tbl_s = table(signals_s,n_s,p_s,r_s,k_s,mmd_s,wa_s,la_s);





end
