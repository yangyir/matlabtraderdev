dir_book_agriculture = [getenv('datapath'),'realtimetrading\ccbly\fractalagriculture\'];
dir_book_metal = [getenv('datapath'),'realtimetrading\ccbly\fractalmetal\'];
dir_book_energy = [getenv('datapath'),'realtimetrading\ccbly\fractalenergy\'];

cob_date = datestr(getlastbusinessdate-4,'yyyymmdd');
fn_agriculture = ['fractalagriculture_trades_',cob_date,'.txt'];
fn_metal = ['fractalmetal_trades_',cob_date,'.txt'];
fn_energy = ['fractalenergy_trades_',cob_date,'txt'];

%
fprintf('\ntrading report on %s...\n',cob_date);
trades_agriculture = cTradeOpenArray;
try
    trades_agriculture.fromtxt2([dir_book_agriculture,fn_agriculture]);
catch
    fprintf('book agriculture:none\n');
end
for i = 1:trades_agriculture.latest_
    try
        trade_i = trades_agriculture.node_(i);
        code = trade_i.code_;
        opendt = trade_i.opendatetime2_;
        if trade_i.opendirection_ == 1
            flag = 'B';
        else
            flag = 'S';
        end
        status = trade_i.status_;
        if strcmpi(status,'closed')
            pnl = trade_i.closepnl_;
            closedt = trade_i.closedatetime2_;
        else
            pnl = trade_i.runningpnl_;
            closedt = '';
        end
        if i == 1, fprintf('book agriculture:\n');end
        fprintf('\t%8s%21s%3s%8s%6d\n',code,opendt,flag,status,pnl);
    catch
    end
end
%
trades_metal = cTradeOpenArray;
try
    trades_metal.fromtxt2([dir_book_metal,fn_metal]);
catch
    fprintf('book metal: none\n');
end
for i = 1:trades_metal.latest_
    try
        trade_i = trades_metal.node_(i);
        code = trade_i.code_;
        opendt = trade_i.opendatetime2_;
        if trade_i.opendirection_ == 1
            flag = 'B';
        else
            flag = 'S';
        end
        status = trade_i.status_;
        if strcmpi(status,'closed')
            pnl = trade_i.closepnl_;
            closedt = trade_i.closedatetime2_;
        else
            pnl = trade_i.runningpnl_;
            closedt = '';
        end
        if i == 1, fprintf('book metal:\n');end
        fprintf('\t%8s%21s%3s%8s%6d\n',code,opendt,flag,status,pnl);
    catch
    end
end
%
trades_energy = cTradeOpenArray;
try
    trades_energy.fromtxt2([dir_book_energy,fn_metal]);
catch
    fprintf('book energy: none\n');
end
for i = 1:trades_energy.latest_
    try
        trade_i = trades_energy.node_(i);
        code = trade_i.code_;
        opendt = trade_i.opendatetime2_;
        if trade_i.opendirection_ == 1
            flag = 'B';
        else
            flag = 'S';
        end
        status = trade_i.status_;
        if strcmpi(status,'closed')
            pnl = trade_i.closepnl_;
            closedt = trade_i.closedatetime2_;
        else
            pnl = trade_i.runningpnl_;
            closedt = '';
        end
        if i == 1, fprintf('book energy:\n');end
        fprintf('\t%8s%21s%3s%8s%6d\n',code,opendt,flag,status,pnl);
    catch
    end
end
