%% ����WIND�ͻ���
if ~exist('w','var'), w = cWind;end
fprintf('wind instance launched....\n');
%% ���ػ���300ָ��ETF����
savedailybarfromwind2(w,'510300.SH');
fprintf('shsz 300 index ETF daily data saved...\n');
%%
hd_300etf = cDataFileIO.loadDataFromTxtFile('510300_daily.txt');
nfractal = 2;
[op_300etf,op_300etf2] = tools_technicalplot1(hd_300etf,nfractal,0,'change',0.0005,'volatilityperiod',0);
[wad_300etf,trh_300etf,trl_300etf] = williamsad(hd_300etf,0);
shift = 63;%ȡ��ȥ���������������
tools_technicalplot2(op_300etf(end-shift:end,:),1,'510300 CH Equity',true);
fprintf('510300 SH Equity:\n');
fprintf('%15s\t%s\n','date:',datestr(hd_300etf(end,1),'yyyy-mm-dd'));
fprintf('%15s\t%s\n','closeprice:',num2str(hd_300etf(end,5)));
fprintf('%15s\t%4.1f%%\n','pricechg%:',100*(hd_300etf(end,5)/hd_300etf(end-1,5)-1));
fprintf('%15s\t%4.1f%%\n','volumechg%:',100*(hd_300etf(end,6)/hd_300etf(end-1,6)-1));
fprintf('%15s\t%s\n','f-upper:',num2str(op_300etf(end,8)));
fprintf('%15s\t%s\n','f-lower:',num2str(op_300etf(end,9)));
fprintf('%15s\t%s\n','tdst-upper:',num2str(op_300etf(end,15)));
fprintf('%15s\t%s\n','tdst-lower:',num2str(op_300etf(end,16)));