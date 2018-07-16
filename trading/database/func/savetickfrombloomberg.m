code = 'T1809';
instrument = code2instrument(code);
sec = instrument.code_bbg;
%%
cobdate = '2018-06-26';
if strcmpi(instrument.break_interval{end,end},'01:00:00') || ...
    strcmpi(instrument.break_interval{end,end},'02:30:00')
    datebump = 1;
else
    datebump = 0;
end
ticks = timeseries(c,sec,{[cobdate,' ',instrument.break_interval{1,1}],...
    [datestr(datenum(cobdate)+datebump,'yyyy-mm-dd'),' ',instrument.break_interval{end,end}]},[],'trade');
%
tickdata = cell2mat(ticks(:,2:end));
fprintf('%d\n',size(tickdata,1));
fprintf('%s\n',datestr(tickdata(1,1)));
fprintf('%s\n',datestr(tickdata(end,1)));
%%
dir_ = getenv('DATAPATH');
dir_data_ = [dir_,'ticks\',code];
try
    cd(dir_data_);
catch
    mkdir(dir_data_);
end
fn_ = [dir_data_,'\',code,'_',datestr(cobdate,'yyyymmdd'),'_tick.txt'];
coldefs = {'datetime','trade','volume'};
permission = 'w';
usedatestr = true;
cDataFileIO.saveDataToTxtFile(fn_,tickdata,coldefs,permission,usedatestr);