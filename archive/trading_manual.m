%%
login_counter_opt2;
%%
strat_manual = cStratManual;
strat_manual.registercounter(c_opt2);
%%
code = 'm1805';
%%
isopt = isoptchar(code);
if isopt
    instrument = cOption(code);
else
    instrument = cFutures(code);
end
instrument.loadinfo([code,'_info.txt']);
strat_manual.registerinstrument(instrument);

%%
strat_manual.mde_opt_.display_ = 0;
strat_manual.start;
warning('off');

%% withdraw pending entrusts
strat_manual.withdrawentrusts(instrument);

%% open a new long position
lots = 1;spread = 5;
try
    strat_manual.withdrawentrusts(instrument);strat_manual.longopensingleinstrument(code,lots,spread);
catch e
    fprintf([e.message,'\n']);
end

%% open a new short position
lots = 1;spread = 5;
try
    strat_manual.withdrawentrusts(instrument);strat_manual.shortopensingleinstrument(code,lots,spread);
catch e
    fprintf([e.message,'\n']);
end

%% close an existing long position
lots = 1;spread = 5;closetoday = 0;
try
    strat_manual.withdrawentrusts(instrument);strat_manual.shortclosesingleinstrument(code,lots,closetoday,spread);
catch e
    fprintf([e.message,'\n']);
end
%% close an existing short position
lots = 1;spread = 5;closetoday = 0;
try
    strat_manual.withdrawentrusts(instrument);strat_manual.longclosesingleinstrument(code,lots,closetoday,spread);
catch e
    fprintf([e.message,'\n']);
end