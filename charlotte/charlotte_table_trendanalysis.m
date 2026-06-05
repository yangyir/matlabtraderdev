function [tbl_trend_l,tbl_trend_s,tbl_trend_l2,tbl_trend_s2] = charlotte_table_trendanalysis(inputtable)
%long trend modes:
modes_l = {'bmtc';'bstc';'breachup-lvlup';'breachup-sshighvalue';'breachup-highsc13'};

n_l = zeros(size(modes_l,1),1);
p_l = n_l;r_l = n_l;k_l = n_l;mmd_l = n_l;wa_l = n_l;la_l = n_l;

%bmtc
idx_l_1 = inputtable.direction == 1 & ...
    strcmpi(inputtable.tradername,'medium') & ...
    (strcmpi(inputtable.opensignal,'mediumbreach-trendconfirmed') | ...
    strcmpi(inputtable.opensignal,'conditional-uptrendconfirmed') | ...
    strcmpi(inputtable.opensignal,'volblowup') | ...
    strcmpi(inputtable.opensignal,'volblowup2'));
output_l_1 = kellyratio2(inputtable.pnlrel(idx_l_1,:));
n_l(1) = output_l_1.n;
p_l(1) = output_l_1.w;
r_l(1) = output_l_1.r;
k_l(1) = output_l_1.k;
mmd_l(1) = output_l_1.maxdrawdown;
wa_l(1) = output_l_1.winavg;
la_l(1) = output_l_1.lossavg;
%
%
%bstc
idx_l_2 = inputtable.direction == 1 & ...
    strcmpi(inputtable.tradername,'strong') & ...
    (strcmpi(inputtable.opensignal,'strongbreach-trendconfirmed') | ...
    strcmpi(inputtable.opensignal,'conditional-uptrendconfirmed') | ...
    strcmpi(inputtable.opensignal,'volblowup') | ...
    strcmpi(inputtable.opensignal,'volblowup2'));
output_l_2 = kellyratio2(inputtable.pnlrel(idx_l_2,:));
n_l(2) = output_l_2.n;
p_l(2) = output_l_2.w;
r_l(2) = output_l_2.r;
k_l(2) = output_l_2.k;
mmd_l(2) = output_l_2.maxdrawdown;
wa_l(2) = output_l_2.winavg;
la_l(2) = output_l_2.lossavg;
%
%
%breachup-lvlup
idx_l_3 = inputtable.direction == 1 & ...
    (strcmpi(inputtable.opensignal,'breachup-lvlup') | strcmpi(inputtable.opensignal,'conditional-uptrendconfirmed-1')) & ...
    strcmpi(inputtable.countername,'tc');
output_l_3 = kellyratio2(inputtable.pnlrel(idx_l_3,:));
n_l(3) = output_l_3.n;
p_l(3) = output_l_3.w;
r_l(3) = output_l_3.r;
k_l(3) = output_l_3.k;
mmd_l(3) = output_l_3.maxdrawdown;
wa_l(3) = output_l_3.winavg;
la_l(3) = output_l_3.lossavg;
%
%
%breachup-sshighvalue
idx_l_4 = inputtable.direction == 1 & ...
    (strcmpi(inputtable.opensignal,'breachup-sshighvalue') | strcmpi(inputtable.opensignal,'conditional-uptrendconfirmed-2')) & ...
    strcmpi(inputtable.countername,'tc');
output_l_4 = kellyratio2(inputtable.pnlrel(idx_l_4,:));
n_l(4) = output_l_4.n;
p_l(4) = output_l_4.w;
r_l(4) = output_l_4.r;
k_l(4) = output_l_4.k;
mmd_l(4) = output_l_4.maxdrawdown;
wa_l(4) = output_l_4.winavg;
la_l(4) = output_l_4.lossavg;
%
%
idx_l_5 = inputtable.direction == 1 & ...
    (strcmpi(inputtable.opensignal,'breachup-highsc13') | strcmpi(inputtable.opensignal,'conditional-uptrendconfirmed-3'));
output_l_5 = kellyratio2(inputtable.pnlrel(idx_l_5,:));
n_l(5) = output_l_5.n;
p_l(5) = output_l_5.w;
r_l(5) = output_l_5.r;
k_l(5) = output_l_5.k;
mmd_l(5) = output_l_5.maxdrawdown;
wa_l(5) = output_l_5.winavg;
la_l(5) = output_l_5.lossavg;
%
%
tbl_trend_l = table(modes_l,n_l,p_l,r_l,k_l,mmd_l,wa_l,la_l);
%
%short trend
modes_s = {'smtc';'sstc';'breachdn-lvldn';'breachdn-bshighvalue';'breachdn-lowbc13'};

n_s = zeros(size(modes_s,1),1);
p_s = n_s;r_s = n_s;k_s = n_s;mmd_s = n_s;wa_s = n_s;la_s = n_s;

%smtc
idx_s_1 = inputtable.direction == -1 & ...
    strcmpi(inputtable.tradername,'medium') & ...
    (strcmpi(inputtable.opensignal,'mediumbreach-trendconfirmed') | ...
    strcmpi(inputtable.opensignal,'conditional-dntrendconfirmed') | ...
    strcmpi(inputtable.opensignal,'volblowup') | ...
    strcmpi(inputtable.opensignal,'volblowup2'));
output_s_1 = kellyratio2(inputtable.pnlrel(idx_s_1,:));
n_s(1) = output_s_1.n;
p_s(1) = output_s_1.w;
r_s(1) = output_s_1.r;
k_s(1) = output_s_1.k;
mmd_s(1) = output_s_1.maxdrawdown;
wa_s(1) = output_s_1.winavg;
la_s(1) = output_s_1.lossavg;
%
%sstc
idx_s_2 = inputtable.direction == -1 & ...
    strcmpi(inputtable.tradername,'strong') & ...
    (strcmpi(inputtable.opensignal,'strongbreach-trendconfirmed') | ...
    strcmpi(inputtable.opensignal,'conditional-dntrendconfirmed') | ...
    strcmpi(inputtable.opensignal,'volblowup') | ...
    strcmpi(inputtable.opensignal,'volblowup2'));
output_s_2 = kellyratio2(inputtable.pnlrel(idx_s_2,:));
n_s(2) = output_s_2.n;
p_s(2) = output_s_2.w;
r_s(2) = output_s_2.r;
k_s(2) = output_s_2.k;
mmd_s(2) = output_s_2.maxdrawdown;
wa_s(2) = output_s_2.winavg;
la_s(2) = output_s_2.lossavg;
%
%
%breachdn-lvldn
idx_s_3 = inputtable.direction == -1 & ...
    (strcmpi(inputtable.opensignal,'breachdn-lvldn') | strcmpi(inputtable.opensignal,'conditional-dntrendconfirmed-1')) & ...
    strcmpi(inputtable.countername,'tc');
output_s_3 = kellyratio2(inputtable.pnlrel(idx_s_3,:));
n_s(3) = output_s_3.n;
p_s(3) = output_s_3.w;
r_s(3) = output_s_3.r;
k_s(3) = output_s_3.k;
mmd_s(3) = output_s_3.maxdrawdown;
wa_s(3) = output_s_3.winavg;
la_s(3) = output_s_3.lossavg;
%
%
%breachdn-bshighvalue
idx_s_4 = inputtable.direction == -1 & ...
    (strcmpi(inputtable.opensignal,'breachdn-bshighvalue') | strcmpi(inputtable.opensignal,'conditional-dntrendconfirmed-2')) & ...
    strcmpi(inputtable.countername,'tc');
output_s_4 = kellyratio2(inputtable.pnlrel(idx_s_4,:));
n_s(4) = output_s_4.n;
p_s(4) = output_s_4.w;
r_s(4) = output_s_4.r;
k_s(4) = output_s_4.k;
mmd_s(4) = output_s_4.maxdrawdown;
wa_s(4) = output_s_4.winavg;
la_s(4) = output_s_4.lossavg;
%
%
%breachdn-lowbc13
idx_s_5 = inputtable.direction == -1 & ...
    (strcmpi(inputtable.opensignal,'breachdn-lowbc13') | strcmpi(inputtable.opensignal,'conditional-dntrendconfirmed-3'));
output_s_5 = kellyratio2(inputtable.pnlrel(idx_s_5,:));
n_s(5) = output_s_5.n;
p_s(5) = output_s_5.w;
r_s(5) = output_s_5.r;
k_s(5) = output_s_5.k;
mmd_s(5) = output_s_5.maxdrawdown;
wa_s(5) = output_s_5.winavg;
la_s(5) = output_s_5.lossavg;



tbl_trend_s = table(modes_s,n_s,p_s,r_s,k_s,mmd_s,wa_s,la_s);

%tbl_trend_l2 is for p/k matrix in the strat tables
modes_l2 = {'mediumbreach-trendconfirmed';'strongbreach-trendconfirmed';'volblowup';'volblowup2'};
n_l2 = zeros(size(modes_l2,1),1);
p_l2 = n_l2;r_l2 = n_l2;k_l2 = n_l2;mmd_l2 = n_l2;wa_l2 = n_l2;la_l2 = n_l2;
idx_l_6 = inputtable.direction == 1 & ...
    strcmpi(inputtable.tradername,'medium') & ...
    (strcmpi(inputtable.opensignal,'mediumbreach-trendconfirmed') | ...
    strcmpi(inputtable.opensignal,'conditional-uptrendconfirmed'));
output_l_6 = kellyratio2(inputtable.pnlrel(idx_l_6,:));
n_l2(1) = output_l_6.n;
p_l2(1) = output_l_6.w;
r_l2(1) = output_l_6.r;
k_l2(1) = output_l_6.k;
mmd_l2(1) = output_l_6.maxdrawdown;
wa_l2(1) = output_l_6.winavg;
la_l2(1) = output_l_6.lossavg;
%
idx_l_7 = inputtable.direction == 1 & ...
    strcmpi(inputtable.tradername,'strong') & ...
    (strcmpi(inputtable.opensignal,'strongbreach-trendconfirmed') | ...
    strcmpi(inputtable.opensignal,'conditional-uptrendconfirmed'));
output_l_7 = kellyratio2(inputtable.pnlrel(idx_l_7,:));
n_l2(2) = output_l_7.n;
p_l2(2) = output_l_7.w;
r_l2(2) = output_l_7.r;
k_l2(2) = output_l_7.k;
mmd_l2(2) = output_l_7.maxdrawdown;
wa_l2(2) = output_l_7.winavg;
la_l2(2) = output_l_7.lossavg;
%
idx_l_8 = inputtable.direction == 1 & ...
    strcmpi(inputtable.opensignal,'volblowup');
output_l_8 = kellyratio2(inputtable.pnlrel(idx_l_8,:));
n_l2(3) = output_l_8.n;
p_l2(3) = output_l_8.w;
r_l2(3) = output_l_8.r;
k_l2(3) = output_l_8.k;
mmd_l2(3) = output_l_8.maxdrawdown;
wa_l2(3) = output_l_8.winavg;
la_l2(3) = output_l_8.lossavg;
%
idx_l_9 = inputtable.direction == 1 & ...
    strcmpi(inputtable.opensignal,'volblowup2');
output_l_9 = kellyratio2(inputtable.pnlrel(idx_l_9,:));
n_l2(4) = output_l_9.n;
p_l2(4) = output_l_9.w;
r_l2(4) = output_l_9.r;
k_l2(4) = output_l_9.k;
mmd_l2(4) = output_l_9.maxdrawdown;
wa_l2(4) = output_l_9.winavg;
la_l2(4) = output_l_9.lossavg;
%
tbl_trend_l2 = table(modes_l2,n_l2,p_l2,r_l2,k_l2,mmd_l2,wa_l2,la_l2);
%

%tbl_trend_s2 is for p/k matrix in the strat tables
modes_s2 = {'mediumbreach-trendconfirmed';'strongbreach-trendconfirmed';'volblowup';'volblowup2'};
n_s2 = zeros(size(modes_s2,1),1);
p_s2 = n_s2;r_s2 = n_s2;k_s2 = n_s2;mmd_s2 = n_s2;wa_s2 = n_s2;la_s2 = n_s2;
idx_s_6 = inputtable.direction == -1 & ...
    strcmpi(inputtable.tradername,'medium') & ...
    (strcmpi(inputtable.opensignal,'mediumbreach-trendconfirmed') | ...
    strcmpi(inputtable.opensignal,'conditional-dntrendconfirmed'));
output_s_6 = kellyratio2(inputtable.pnlrel(idx_s_6,:));
n_s2(1) = output_s_6.n;
p_s2(1) = output_s_6.w;
r_s2(1) = output_s_6.r;
k_s2(1) = output_s_6.k;
mmd_s2(1) = output_s_6.maxdrawdown;
wa_s2(1) = output_s_6.winavg;
la_s2(1) = output_s_6.lossavg;
%
idx_s_7 = inputtable.direction == -1 & ...
    strcmpi(inputtable.tradername,'strong') & ...
    (strcmpi(inputtable.opensignal,'strongbreach-trendconfirmed') | ...
    strcmpi(inputtable.opensignal,'conditional-dntrendconfirmed'));
output_s_7 = kellyratio2(inputtable.pnlrel(idx_s_7,:));
n_s2(2) = output_s_7.n;
p_s2(2) = output_s_7.w;
r_s2(2) = output_s_7.r;
k_s2(2) = output_s_7.k;
mmd_s2(2) = output_s_7.maxdrawdown;
wa_s2(2) = output_s_7.winavg;
la_s2(2) = output_s_7.lossavg;
%
idx_s_8 = inputtable.direction == -1 & ...
    strcmpi(inputtable.opensignal,'volblowup');
output_s_8 = kellyratio2(inputtable.pnlrel(idx_s_8,:));
n_s2(3) = output_s_8.n;
p_s2(3) = output_s_8.w;
r_s2(3) = output_s_8.r;
k_s2(3) = output_s_8.k;
mmd_s2(3) = output_s_8.maxdrawdown;
wa_s2(3) = output_s_8.winavg;
la_s2(3) = output_s_8.lossavg;
%
idx_s_9 = inputtable.direction == -1 & ...
    strcmpi(inputtable.opensignal,'volblowup2');
output_s_9 = kellyratio2(inputtable.pnlrel(idx_s_9,:));
n_s2(4) = output_s_9.n;
p_s2(4) = output_s_9.w;
r_s2(4) = output_s_9.r;
k_s2(4) = output_s_9.k;
mmd_s2(4) = output_s_9.maxdrawdown;
wa_s2(4) = output_s_9.winavg;
la_s2(4) = output_s_9.lossavg;









tbl_trend_s2 = table(modes_s2,n_s2,p_s2,r_s2,k_s2,mmd_s2,wa_s2,la_s2);



end