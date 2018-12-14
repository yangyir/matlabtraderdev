%% counter login
cd(citickim_path_manual);
citickim_counter = citickim.ops.getcounter;
if ~citickim_counter.is_Counter_Login, citickim_counter.login; end
%% mde login
citickim.mdefut.login('connection','CTP','countername',citickim_countername);
%%
citickim.mdefut.start;
citickim.ops.start;
%%
citickim.strategy.start;
%% check risk config
code = 'rb1905';
[~,idx] = citickim.strategy.hasinstrument(code);
disp(citickim.strategy.riskcontrols_.node_(idx))
%% modify risk config if it is required
propnames2change = {'stoptypepertrade';'stopamountpertrade';'limittypepertrade';'limitamountpertrade'};
propvalues2change = {'ABS';-300;'ABS';200};
for i = 1:size(propnames2change)
    citickim.strategy.riskcontrols_.node_(idx).([propnames2change{i},'_']) = propvalues2change{i};
end
disp(citickim.strategy.riskcontrols_.node_(idx))

%%
code = 'rb1905';
citickim.strategy.longopen(code,1,'overrideprice',3312);
%%
citickim.strategy.withdrawentrusts(code);
%%
citickim.mdefut.stop;
