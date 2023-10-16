%%
w = cWind;
fprintf('wind instance initiated...\n');
dir_ = getenv('DATAPATH');
dir_data_ = [dir_,'dailybar\'];
coldefs = {'date','open','high','low','close'};
%%
codes_govtbond = {'TB10Y.WI';...%国债10年活跃
'TB30Y.WI';...%国债30年活跃
'CDB10Y.WI';%国开10年活跃
};
fn_govtbond = {'gzhy_daily.txt';'gzhy_30y_daily.txt';'gkhy_daily.txt'};
for i = 1:length(codes_govtbond)
    [wdata,~,~,wtime] = w.ds_.wsd(codes_govtbond{i},...
        'open,high,low,close','2000-01-01',today-1,'TradingCalendar=NIB');
    wmat = [wtime,wdata];
    widx = ~isnan(sum(wmat,2));%remove nan entries
    wmat = wmat(widx,:);
    cDataFileIO.saveDataToTxtFile([dir_data_,fn_govtbond{i}],wmat,coldefs,'w',false);
end
codes_govtbondfut = {'T2312';...%10年国债期货
    'TL2312';...%30年国债期货
    };
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
tools_technicalplot2(mat_gzhy_10y(end-nshift:end,:),3,'活跃10年国债收益率',true);
tools_technicalplot2(mat_gzhy_30y(end-nshift:end,:),4,'活跃30年国债收益率',true);
tools_technicalplot2(mat_gkhy_10y(end-nshift:end,:),5,'活跃10年国开收益率',true);
%%


%%

[~,op_10y] = fractal_signal_unconditional(opstruct_govtbond_10y,0.005,2);
if op_10y.use
    if op_10y.direction == 1
        fprintf('%6s:bullish:%s\n',code_10y,op_10y.comment);
    elseif op_10y.direction == -1
        fprintf('%6s:bearish:%s\n',code_10y,op_10y.comment);
    end
end

%
% 5年国债期货
hd_govtbond_05y = cDataFileIO.loadDataFromTxtFile([code_05y,'_daily.txt']);
idx = ~isnan(hd_govtbond_05y(:,2)) & ~isnan(hd_govtbond_05y(:,3)) & ~isnan(hd_govtbond_05y(:,4)) & ~isnan(hd_govtbond_05y(:,5));
hd_govtbond_05y = hd_govtbond_05y(idx,:);
[op_govtbond_05y,opstruct_govtbond_05y] = tools_technicalplot1(hd_govtbond_05y(:,1:5),2,0,'volatilityperiod',0,'tolerance',0);
op_govtbond_05y(:,1) = x2mdate(op_govtbond_05y(:,1));
shift = 62;
tools_technicalplot2(op_govtbond_05y(end-shift:end,:),3,'govtbond-05y-daily',true);
[signal_10y,op] = fractal_signal_unconditional(opstruct_govtbond_10y,0.005,2);
[~,op_05y] = fractal_signal_unconditional(opstruct_govtbond_05y,0.005,2);
if op_05y.use
    if op_05y.direction == 1
        fprintf('%6s:bullish:%s\n',code_05y,op_05y.comment);
    elseif op_05y.direction == -1
        fprintf('%6s:bearish:%s\n',code_05y,op_05y.comment);
    end
end

