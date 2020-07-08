[T_ri,T_oidata] = bkfunc_genfutrollinfo('govtbond_10y');
[~,~,T_idx] = bkfunc_buildcontinuousfutures(T_ri,T_oidata);
%%
nfractal = 2;
T_res = tools_technicalplot1(T_idx,nfractal,0,'volatilityperiod',0,'tolerance',0);
T_res(:,1) = x2mdate(T_res(:,1));
%%
i=5;
tools_technicalplot2(T_res((i-1)*126+1:min(i*126,size(T_idx,1)),:),1,'govtbond10y-indx',true,0.005/100);