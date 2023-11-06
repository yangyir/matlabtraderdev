%%
w = cWind;
fprintf('wind instance initiated...\n');
dir_ = getenv('DATAPATH');
dir_data_ = [dir_,'dailybar\'];
coldefs = {'date','open','high','low','close'};
%
codes_govtbond = {'TB10Y.WI';...%��ծ10���Ծ
'TB30Y.WI';...%��ծ30���Ծ
'CDB10Y.WI';%����10���Ծ
};
fn_govtbond = {'gzhy_daily.txt';'gzhy_30y_daily.txt';'gkhy_daily.txt'};
codes_govtbondfut = {'T2312';...%10���ծ�ڻ�
    'TL2312';...%30���ծ�ڻ�
    };
%%
for i = 1:length(codes_govtbond)
    [wdata,~,~,wtime] = w.ds_.wsd(codes_govtbond{i},...
        'open,high,low,close','2000-01-01',today-1,'TradingCalendar=NIB');
    wmat = [wtime,wdata];
    widx = ~isnan(sum(wmat,2));%remove nan entries
    wmat = wmat(widx,:);
    cDataFileIO.saveDataToTxtFile([dir_data_,fn_govtbond{i}],wmat,coldefs,'w',false);
end

%%
clc;close all;
set(0,'defaultfigurewindowstyle','docked');
hd_gzhy_10y = cDataFileIO.loadDataFromTxtFile([dir_data_,fn_govtbond{1}]);
hd_gzhy_30y = cDataFileIO.loadDataFromTxtFile([dir_data_,fn_govtbond{2}]);
hd_gkhy_10y = cDataFileIO.loadDataFromTxtFile([dir_data_,fn_govtbond{3}]);
[mat_gzhy_10y,struct_gzhy_10y] = tools_technicalplot1(hd_gzhy_10y,2,0,'volatilityperiod',0,'tolerance',0);
[mat_gzhy_30y,struct_gzhy_30y] = tools_technicalplot1(hd_gzhy_30y,2,0,'volatilityperiod',0,'tolerance',0);
[mat_gkhy_10y,struct_gkhy_10y] = tools_technicalplot1(hd_gkhy_10y,2,0,'volatilityperiod',0,'tolerance',0);
nshift = 62;
tools_technicalplot2(mat_gzhy_10y(end-nshift:end,:),3,'��Ծ10���ծ������',true);
tools_technicalplot2(mat_gzhy_30y(end-nshift:end,:),4,'��Ծ30���ծ������',true);
tools_technicalplot2(mat_gkhy_10y(end-nshift:end,:),5,'��Ծ10�����������',true);
%%
[tblb_headers,tblb_data,tbls_headers,tbls_data,data,tradesb,tradess,validtradesb,validtradess,kellyb,kellys] = fractal_gettradesummary('gzhy','usefractalupdate',0);
%%
output_gzhy = fractal_kelly_summary('codes',{'gzhy'},'frequency','daily','usefractalupdate',0,'usefibonacci',1,'direction','both');
[tc_gzhy,tb_gzhy,tbl_gzhy,k_l_gzhy,k_s_gzhy,tblbyasset_l_gzhy,tblbyasset_s_gzhy] = kellydistrubitionsummary(output_gzhy);
%%
output_gzhy30y = fractal_kelly_summary('codes',{'gzhy_30y'},'frequency','daily','usefractalupdate',0,'usefibonacci',1,'direction','both');
[tc_gzhy30y,tb_gzhy30y,tbl_gzhy30y,k_l_gzhy30y,k_s_gzhy30y,tblbyasset_l_gzhy30y,tblbyasset_s_gzhy30y] = kellydistrubitionsummary(output_gzhy30y);
%%
[signal_10y_yield,op_yield] = fractal_signal_unconditional(data,0.0025,2);
[signal_cond_10y_yield,op_cond_yield] = fractal_signal_conditional(data,0.0025,2);
%% 10���ծ�ڻ�
code_10y = 'T2312';
hd_govtbond_10y = cDataFileIO.loadDataFromTxtFile([code_10y,'_daily.txt']);
idx = ~isnan(hd_govtbond_10y(:,2)) & ~isnan(hd_govtbond_10y(:,3)) & ~isnan(hd_govtbond_10y(:,4)) & ~isnan(hd_govtbond_10y(:,5));
hd_govtbond_10y = hd_govtbond_10y(idx,:);
[op_govtbond_10y,opstruct_govtbond_10y] = tools_technicalplot1(hd_govtbond_10y(:,1:5),2,0,'volatilityperiod',0,'tolerance',0);
op_govtbond_10y(:,1) = x2mdate(op_govtbond_10y(:,1));
shift = 62;
tools_technicalplot2(op_govtbond_10y(end-shift:end,:),6,'govtbond-10y-daily',true);
[signal_10y,op] = fractal_signal_unconditional(opstruct_govtbond_10y,0.005,2);
[~,op_10y] = fractal_signal_unconditional(opstruct_govtbond_10y,0.005,2);
if op_10y.use
    if op_10y.direction == 1
        fprintf('%6s:%12s:bullish:%s\n',code_10y,datestr(hd_govtbond_10y(end,1),'yyyy-mm-dd'),op_10y.comment);
    elseif op_10y.direction == -1
        fprintf('%6s:%12s:bearish:%s\n',code_10y,datestr(hd_govtbond_10y(end,1),'yyyy-mm-dd'),op_10y.comment);
    end
end
