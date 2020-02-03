[ iv_c_feb,iv_p_feb,marked_fwd_fed ] = etf50_sh_iv( conn,opt_c_feb,opt_p_feb,exp_feb,k );
[ iv_c_mar,iv_p_mar,marked_fwd_mar ] = etf50_sh_iv( conn,opt_c_mar,opt_p_mar,exp_mar,k );
%%
% EOD info
n_c_feb = length(opt_c_feb);
bd_c_feb = cell(n_c_feb,1);
tbl_c_feb = [k',zeros(length(k),3)];
for i = 1:n_c_feb
    try
        bd_c_feb{i} = pnlriskbreakdownbbg(opt_c_feb{i},datenum('2020-02-03'));
        tbl_c_feb(i,2) = bd_c_feb{i}.iv1;
        tbl_c_feb(i,3) = bd_c_feb{i}.iv2;
        tbl_c_feb(i,4) = bd_c_feb{i}.deltacarry/bd_c_feb{i}.spot2/10000;
    catch
        bd_c_feb{i} = [];
        tbl_c_feb(i,2:4) = NaN;
    end
end