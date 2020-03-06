% [ iv_c_feb,iv_p_feb,marked_fwd_fed ] = etf300_sh_iv( conn,opt_c_feb,opt_p_feb,exp_feb,k );
[ iv_c_mar,iv_p_mar,marked_fwd_mar ] = etf300_sh_iv( conn,opt300_c_mar,opt300_p_mar,exp_mar,k );
[ iv_c_jun,iv_p_jun,marked_fwd_jun ] = etf300_sh_iv( conn,opt300_c_jun,opt300_p_jun,exp_jun,k );
%%
% EOD info:
% CALL
n_c_mar = length(opt300_c_mar);
bd_c_mar = cell(n_c_mar,1);
tbl_c_mar = [k_300',zeros(length(k_300),3)];
cobdate = '2020-03-06';
for i = 1:n_c_mar
    try
        bd_c_mar{i} = pnlriskbreakdownbbg(opt300_c_mar{i},datenum(cobdate));
        tbl_c_mar(i,2) = bd_c_mar{i}.iv1;
        tbl_c_mar(i,3) = bd_c_mar{i}.iv2;
        tbl_c_mar(i,4) = bd_c_mar{i}.deltacarry/bd_c_mar{i}.spot2/10000;
    catch
        bd_c_mar{i} = [];
        tbl_c_mar(i,2:4) = NaN;
    end
end
% PUT
n_p_mar = length(opt300_p_mar);
bd_p_mar = cell(n_p_mar,1);
tbl_p_mar = [k_300',zeros(length(k_300),3)];
for i = 1:n_p_mar
    try
        bd_p_mar{i} = pnlriskbreakdownbbg(opt300_p_mar{i},datenum(cobdate));
        tbl_p_mar(i,2) = bd_p_mar{i}.iv1;
        tbl_p_mar(i,3) = bd_p_mar{i}.iv2;
        tbl_p_mar(i,4) = bd_p_mar{i}.deltacarry/bd_p_mar{i}.spot2/10000;
    catch
        bd_p_mar{i} = [];
        tbl_p_mar(i,2:4) = NaN;
    end
end
%%
n_c_jun = length(opt300_c_jun);
bd_c_jun = cell(n_c_jun,1);
tbl_c_jun = [k_300',zeros(length(k_300),3)];
for i = 1:n_c_jun
    try
        bd_c_jun{i} = pnlriskbreakdownbbg(opt300_c_jun{i},datenum(cobdate));
        tbl_c_jun(i,2) = bd_c_jun{i}.iv1;
        tbl_c_jun(i,3) = bd_c_jun{i}.iv2;
        tbl_c_jun(i,4) = bd_c_jun{i}.deltacarry/bd_c_jun{i}.spot2/10000;
    catch
        bd_c_jun{i} = [];
        tbl_c_jun(i,2:4) = NaN;
    end
end
% PUT
n_p_jun = length(opt300_p_jun);
bd_p_jun = cell(n_p_jun,1);
tbl_p_jun = [k_300',zeros(length(k_300),3)];
for i = 1:n_p_jun
    try
        bd_p_jun{i} = pnlriskbreakdownbbg(opt300_p_jun{i},datenum(cobdate));
        tbl_p_jun(i,2) = bd_p_jun{i}.iv1;
        tbl_p_jun(i,3) = bd_p_jun{i}.iv2;
        tbl_p_jun(i,4) = bd_p_jun{i}.deltacarry/bd_p_jun{i}.spot2/10000;
    catch
        bd_p_jun{i} = [];
        tbl_p_jun(i,2:4) = NaN;
    end
end