names_crudeoil = {'brent';'wti'};
ncrude = size(names_crudeoil,1);
fut_crude = cell(ncrude,1);
resstruct_crude = cell(ncrude,1);
for i = 1:ncrude
    fut_crude{i} = code2instrument(names_crudeoil{i});
    resstruct_crude{i} = charlotte_plot('futcode',names_crudeoil{i},'datefrom','2024-10-01','frequency','daily','doplot',false);
end
%
for i = 1:ncrude
    if ncrude > 0 && i == 1
        fprintf('FX daily report......\n');
        fprintf('\t%8s\t%12s\t%10s\t%10s\t%10s\t%10s\n','NAME','DATE','CLOSE','CHG','UPPER','LOWER');
    end
    fprintf('\t%8s\t%12s\t%10s\t%9.1f%%\t%10s\t%10s\n',names_crudeoil{i},...
        datestr(resstruct_crude{i}.px(end,1),'yyyy-mm-dd'),...
        num2str(resstruct_crude{i}.px(end,5)),...
        100*(resstruct_crude{i}.px(end,5)/resstruct_crude{i}.px(end-1,5)-1),...
        num2str(resstruct_crude{i}.hh(end)),...
        num2str(resstruct_crude{i}.ll(end)));
end
%%
dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\globalcomdty\'];
fn_ = 'strat_globalcrudeoil_daily.mat';
data_ = load([dir_,fn_]);
kellytables = data_.strat_globalcrudeoil_daily;
uts = cell(ncrude,1);
cts = cell(ncrude,1);
tbls = cell(ncrude,1);
for i = 1:ncrude
    [uts{i},cts{i},tbls{i}] = charlotte_backtest_period('code',names_crudeoil{i},...
        'fromdate','2025-01-01',...
        'todate',datestr(resstruct_crude{i}.px(end,1),'yyyy-mm-dd'),...
        'kellytables',kellytables,'showlogs',true,'figureidx',i+1,'frequency','daily');
%     dt2 = datestr(resstruct_crude{i}.px(end,1),'yyyy-mm-dd');
% %     dt1 = datestr(resstruct_fx{i}.px(end-1,1),'yyyy-mm-dd');
%     charlotte_backtest_period('code',names_crudeoil{i},...
%         'fromdate',dt2,...
%         'todate',dt2,...
%         'kellytables',kellytables,'showlogs',true,'figureidx',i+1,'frequency','daily','doplot',false);
end