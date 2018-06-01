%%
login_counter_fut;
login_counter_opt1;
login_counter_opt2;
%%
init_mde;
%%
instrument_list = {'cu1807';'al1807';'zn1807';'pb1807';'ni1807';'cu1808';...
    'rb1810';'i1809';...
    'TF1809';'T1809'};
%%
strat_citic = init_stratmanual('counter',c_fut,'mdefut',mdefut,'instrumentlist',instrument_list,'positionfrom','counter','futlist','all');
strat_ccb = init_stratmanual('counter',c_opt1,'mdefut',mdefut,'instrumentlist',instrument_list,'positionfrom','counter','futlist','all');
strat_huaxin = init_stratmanual('counter',c_opt2,'mdefut',mdefut,'instrumentlist',instrument_list,'positionfrom','counter','futlist','all');
%%
mdefut.start;mdefut.timer_.tag = 'mdefut';
%% print pnl
clc;
strat_citic.helper_.printrunningpnl('mdefut',mdefut)
strat_ccb.helper_.printrunningpnl('mdefut',mdefut)
strat_huaxin.helper_.printrunningpnl('mdefut',mdefut)
%% print market
clc;mdefut.printmarket;
%% ÏÂµ¥
counter_name = 'c_opt1';
ctp_code = 'ni1807';
direction = 'long';
offset = 'open';
closetoday = 1;
volume = 1;
px = 116000;

if px < 0 && px ~= -1, error('invalid price input'); end

if strcmpi(counter_name,'c_fut')
    strat_used = strat_citic;
elseif strcmpi(counter_name,'c_opt1')
    strat_used = strat_ccb;
elseif strcmpi(counter_name,'c_opt2')
    strat_used = strat_huaxin;
else
    error('invalid counter_name')
end
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
clc;
strat_citic.helper_.printpendingentrusts;
strat_ccb.helper_.printpendingentrusts;
strat_huaxin.helper_.printpendingentrusts;
%%
clc;
strat_citic.helper_.printallentrusts;
strat_ccb.helper_.printallentrusts;
strat_huaxin.helper_.printallentrusts;
%%
if isempty(timerfindall)
    mdefut.start;mdefut.timer_.tag = 'mdefut';
    strat_citic.helper_.start;strat_citic.helper_.timer_.tag = 'ops';
    strat_ccb.helper_.start;strat_ccb.helper_.timer_.tag = 'ops';
    strat_huaxin.helper_.start;strat_huaxin.helper_.timer_.tag = 'ops';
end
%%
mdefut.stop
strat_citic.helper_.stop;
strat_ccb.helper_.stop;
strat_huaxin.helper_.stop;
delete(timerfindall);
%%
logoff_counters;
clear all;
%%
strat_ccb.withdrawentrusts('ni1807')
strat_huaxin.withdrawentrusts('ni1807')

