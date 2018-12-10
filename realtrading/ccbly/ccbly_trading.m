%% counter login
cd(ccbly_path_manual);
ccbly_counter = ccbly.ops.getcounter;
if ~ccbly_counter.is_Counter_Login, ccbly_counter.login; end
%% mde login
ccbly.mdefut.login('connection','CTP','countername',ccbly_countername);
%%
ccbly.mdefut.start;
ccbly.ops.start;
%%
ccbly.strategy.start;
%% check risk config
code = 'rb1905';
[~,idx] = ccbly.strategy.hasinstrument(code);
disp(ccbly.strategy.riskcontrols_.node_(idx))
%% modify risk config if it is required
propnames2change = {'stoptypepertrade';'stopamountpertrade';'limittypepertrade';'limitamountpertrade'};
propvalues2change = {'ABS';-300;'ABS';200};
for i = 1:size(propnames2change)
    ccbly.strategy.riskcontrols_.node_(idx).([propnames2change{i},'_']) = propvalues2change{i};
end
disp(ccbly.strategy.riskcontrols_.node_(idx))

%%
code = 'rb1905';
ccbly.strategy.longopen(code,1,'overrideprice',3312);
%%
ccbly.strategy.withdrawentrusts(code);
%%
ccbly.mdefut.stop;
