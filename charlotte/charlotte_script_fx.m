names_fx = {'eurusd';'usdjpy';'gbpusd';'audusd';'usdcad';'usdchf'; 'eurjpy';'audjpy';'xau'};
nfx = size(names_fx,1);
fut_fx = cell(nfx,1);
resstruct_fx = cell(nfx,1);
for i = 1:nfx
    fut_fx{i} = code2instrument(names_fx{i});
    resstruct_fx{i} = charlotte_plot('futcode',names_fx{i},'datefrom','2024-10-01','frequency','daily','doplot',false);
end
%%
for i = 1:nfx
    if nfx > 0 && i == 1
        fprintf('FX daily report......\n');
        fprintf('\t%8s\t%12s\t%10s\t%10s\t%10s\t%10s\n','NAME','DATE','CLOSE','CHG','UPPER','LOWER');
    end
    fprintf('\t%8s\t%12s\t%10s\t%9.1f%%\t%10s\t%10s\n',names_fx{i},...
        datestr(resstruct_fx{i}.px(end,1),'yyyy-mm-dd'),...
        num2str(resstruct_fx{i}.px(end,5)),...
        100*(resstruct_fx{i}.px(end,5)/resstruct_fx{i}.px(end-1,5)-1),...
        num2str(resstruct_fx{i}.hh(end)),...
        num2str(resstruct_fx{i}.ll(end)));
end
%%
dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\fx\'];
fn_ = 'strat_fx_daily.mat';
data_ = load([dir_,fn_]);
kellytables = data_.strat_fx_daily;
uts = cell(nfx,1);
cts = cell(nfx,1);
tbls = cell(nfx,1);
for i = 1:nfx
    [uts{i},cts{i},tbls{i}] = charlotte_backtest_period('code',names_fx{i},...
        'fromdate','2024-10-01',...
        'todate',datestr(resstruct_fx{i}.px(end,1),'yyyy-mm-dd'),...
        'kellytables',kellytables,'showlogs',false,'figureidx',i+1,'frequency','daily');
end
%%
fprintf('\n')
ncount = 0;
for i = 1:nfx
    if cts{i}.latest_ > 0
        ncount = ncount + 1;
        if ncount == 1
            fprintf('\t%6s\t%3s\t%12s\t%10s\t%10s\t%30s\t%9s\n',...
                'Code',...
                'B/S',...
                'OpenDt',...
                'OpenPx',...
                'Latest',...
                'OpenSignal',...
                'OpenKelly');
        end
        t_i = cts{i}.node_(1);
        fprintf('\t%6s\t%3d\t%12s\t%10s\t%10s\t%30s\t%8.1f%%\n',names_fx{i},t_i.opendirection_,...
            datestr(t_i.opendatetime1_,'yyyy-mm-dd'),num2str(t_i.openprice_),num2str(resstruct_fx{i}.px(end,5)),...
            t_i.opensignal_.mode_,100*t_i.opensignal_.kelly_);
    end
end
%%
dt1 = '2024-11-01';
dt2 = '2024-12-10';
 charlotte_backtest_period('code','gbpusd','fromdate',dt1,'todate',dt2,'kellytables',kellytables,'showlogs',true,'figureidx',1,'frequency','daily');