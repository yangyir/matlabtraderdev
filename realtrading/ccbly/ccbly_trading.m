%% counter login
if strcmpi(ui_stratname,'manual')
    cd(ccbly_path_manual);
elseif strcmpi(ui_stratname,'batman')
    cd(ccbly_path_batman);
elseif strcmpi(ui_stratname,'wlpr')
    cd(ccbly_path_wlpr);
elseif strcmpi(ui_stratname,'wlprbatman')
    cd(ccbly_path_wlprbatman);
else
    error('ERROR:ccb_setup:%s is not a valid stratey name!!!',ui_stratname);
end
ccbly_counter = ccbly.ops.getcounter;
if ~ccbly_counter.is_Counter_Login, ccbly_counter.login; end
%% mde login
ccbly.mdefut.login('connection','CTP','countername',ccbly_countername);
%%
ccbly.mdefut.start;
ccbly.ops.start;
%%
ccbly.strategy.start;
%% print the lastest quotes
ccbly.mdefut.printmarket;
%% check trades
ntrades = ccbly.ops.trades_.latest_;
for i = 1:ntrades
    if i == 1
        fprintf('trades:\n');
    end
    fprintf('\ttrade %2d:%10s;status:%5s\n',i,ccbly.ops.trades_.node_(i).code_,...
        ccbly.ops.trades_.node_(i).status_);
end     

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
%%
trade = ccbly.ops.trades_.node_(4);
ccbly.strategy.unwindtrade(trade)




