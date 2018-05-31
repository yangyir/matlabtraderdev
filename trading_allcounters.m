%%
login_counter_fut;
login_counter_opt1;
login_counter_opt2;
init_mde;
%%
instrument_list = {'cu1807';'al1807';'zn1807';'pb1807';'ni1807';...
    'rb1810';'i1809';...
    'TF1809';'T1809'};
%%
strat_citic = init_stratmanual('counter',c_fut,'mdefut',mdefut,'instrumentlist',instrument_list,'positionfrom','counter','futlist','all');
strat_ccb = init_stratmanual('counter',c_opt1,'mdefut',mdefut,'instrumentlist',instrument_list,'positionfrom','counter','futlist','all');
strat_huaxin = init_stratmanual('counter',c_opt2,'mdefut',mdefut,'instrumentlist',instrument_list,'positionfrom','counter','futlist','all');
%%
mdefut.start;
%%
% strat_citic.start;
% strat_ccb.start;
% strat_huaxin.start;
%% print pnl
clc;
strat_citic.helper_.printrunningpnl('mdefut',mdefut)
strat_ccb.helper_.printrunningpnl('mdefut',mdefut)
strat_huaxin.helper_.printrunningpnl('mdefut',mdefut)
%% ÏÂµ¥
counter_name = 'c_fut';
ctp_code = 'T1809';
direction = 'short';
offset = 'open';
closetoday = 1;
volume = 1;
px = 95.05;

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
mdefut.stop
strat_citic.helper_.stop;
strat_citic.stop;
strat_ccb.helper_.stop;
strat_ccb.stop;
strat_huaxin.helper_.stop;
strat_huaxin.stop;
delete(timerfindall);
logoff_counters;
clear all;
%%

strat_citic.withdrawentrusts('TF1809')