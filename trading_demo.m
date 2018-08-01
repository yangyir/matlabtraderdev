%%
pathhome = getenv('HOME');cd(pathhome);
c_demo = CounterCTP.demo_sunq_fut;
c_demo.login;
%%
init_mde;
%%
instrument_list = {'cu1809';'al1809';'zn1809';'pb1809';'ni1809';...
    'rb1810';'i1809';...
    'TF1809';'T1809'};
%%
strat_demo = init_stratmanual('counter',c_demo,'mdefut',mdefut,'instrumentlist',instrument_list,'positionfrom','counter','futlist','all');
%%
mdefut.start;mdefut.timer_.tag = 'mdefut';
%% print pnl
clc;
strat_demo.helper_.printrunningpnl('mdefut',mdefut)
%% print market
clc;mdefut.printmarket;
%% ÏÂµ¥
ctp_code = 'zn1809';
direction = 'long';
offset = 'open';
closetoday = 1;
volume = 1;
px = 21300;

if px < 0 && px ~= -1, error('invalid price input'); end

if strcmpi(direction,'long') && strcmpi(offset,'open')
    if px == -1
        strat_demo.longopensingleinstrument(ctp_code,volume,0);
    else
        strat_demo.longopensingleinstrument(ctp_code,volume,0,'overrideprice',px);
    end
elseif strcmpi(direction,'long') && strcmpi(offset,'close')
    if px == -1
        strat_demo.longclosesingleinstrument(ctp_code,volume,closetoday,0);
    else
        strat_demo.longclosesingleinstrument(ctp_code,volume,closetoday,0,'overrideprice',px);
    end
elseif strcmpi(direction,'short') && strcmpi(offset,'open')
    if px == -1
        strat_demo.shortopensingleinstrument(ctp_code,volume,0);
    else
        strat_demo.shortopensingleinstrument(ctp_code,volume,0,'overrideprice',px);
    end
elseif strcmpi(direction,'short') && strcmpi(offset,'close')
    if px == -1
        strat_demo.shortclosesingleinstrument(ctp_code,volume,closetoday,0);
    else
        strat_demo.shortclosesingleinstrument(ctp_code,volume,closetoday,0,'overrideprice',px);
    end
else
    error('invalid direction or offset')
end

%%
clc;
strat_demo.helper_.printpendingentrusts;
%%
clc;
strat_demo.helper_.printallentrusts;
%%
if isempty(timerfindall)
    mdefut.start;mdefut.timer_.tag = 'mdefut';
    strat_demo.helper_.start;strat_demo.helper_.timer_.tag = 'ops';
end
%%
mdefut.stop
strat_demo.helper_.stop;
delete(timerfindall);
%%
c_demo.logout;
logoff_counters;
clear all;
%%
strat_demo.withdrawentrusts('zn1809')

