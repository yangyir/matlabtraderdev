%% 
login_counter_fut;
%%
init_mde;
%%
instrument_list = {'ni1809';'rb1810'};
%%
strat_citic = init_stratmanual('counter',c_fut,'mdefut', mdefut,'instrumentlist', instrument_list,'positionfrom', 'counter','futlist','all');
%%
mdefut.start;
mdefut.timer_.tag = 'mdefut';
%% print pnl 
strat_citic.helper_.printrunningpnl('mdefut',mdefut);
%% print market
mdefut.printmarket;
%% to order
counter_name = 'c_fut';
ctp_code =' ni1809';
direction = 'long';
offset = 'open';
closetoday = 1;
volume = 1;
px = 108000;
%% print market data according to the input code_printed
code_printed = 'ni1809';
[bid_printed,ask_printed,timet_printed] = getmarketdata('mdefut',code_printed);
fprintf('最新市场报价:\n');
fprintf('%9s%9s%9s%9s\n','合约','买价','卖价','时间');
dataformat = '%11s%11s%11s%12s\n';
fprintf(dataformat,code_printed,num2str(bid_printed),num2str(ask_printed),timet_printed);
%% to doublecheck px value 
doublecheck_px = 1;
if doublecheck_px ==1
    [bid,ask,timet] = getmarketdata('mdefut',ctp_code);
    f = code2instrument(ctp_code);
    tick_value = f.tick_value;
    pending_ticksize_maxlimit = 4;

    if strcmpi(direction,'long')
        if px >= bid + tick_value * pending_ticksize_maxlimit;
            error('unreasonable pending order to long, pls doublecheck px')
        end
    elseif strcmpi(direction,'short')
        if px <= ask - tick_value * pending_ticksize_maxlimit;
            error('unreasonable pending order to short, pls doublecheck px')
        end
    else
        error('invalid direction')
    end
end
%%
strat_used = strat_citic;
%
if strcmpi(direction,'long') && strcmpi(offset,'open')
    if px == -1
        strat_used.longopensingleinstrument(ctp_code,volume,0);
    else
        strat_used.longopensingleinstrument(ctp_code,volume,0,'overrideprice',px);
    end
elseif strcmpi(direction,'long') && strcmpi(offset,'close')
    if px == -1
        strat_used.longclosesingleinstrument(ctp_code,volume,closetoday,0);
    else
        strat_used.longclosesingleinstrument(ctp_code,volume,closetoday,0,'overrideprice',px);
    end
elseif strcmpi(direction,'short') && strcmpi(offset,'open')
    if px == -1
        strat_used.shortopensingleinstrument(ctp_code,volume,0);
    else
        strat_used.shortopensingleinstrument(ctp_code,volume,0,'overrideprice',px);
    end
elseif strcmpi(direction,'short') && strcmpi(offset,'close')
    if px == -1
        strat_used.shortclosesingleinstrument(ctp_code,volume,closetoday,0);
    else
        strat_used.shortclosesingleinstrument(ctp_code,volume,closetoday,0,'overrideprice',px);
    end
else
    error('invalid direction or offset')
end
%%
strat_citic.helper_.printpendingentrusts;
%%
strat_citic.helper_.printallentrusts;
%%
if isempty(timerfindall)
    mdefut.start;mdefut.timer_.tag = 'mdefut';
    strat_citic.helper_.start;strat_citic.helper_.timer_.tag = 'ops';
end
%%
mdefut.stop
strat_citic.helper_.stop;
delete(timerfindall);
%%
logoff_counters;
clear all;
    

    