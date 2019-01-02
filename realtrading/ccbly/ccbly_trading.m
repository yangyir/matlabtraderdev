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
ccbly.mdefut.qms_.setdatasource('ctp');
ccbly.mdefut.qms_.watcher_.ds = cCTP.(ccbly_countername);
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
ccbly.strategy.unwindpositions('sc1903');
%%
ccbly.strategy.withdrawentrusts('cu1902');
%%
ccbly.mdefut.stop;
%%
trade = ccbly.ops.trades_.node_(4);
ccbly.strategy.unwindtrade(trade)
%%
ccbly.strategy.placeentrust('sc1903','buysell','b','price',397.0,'volume',1,...
    'stop',395.6,'limit',400,'RiskManagerName','standard');
%%
ccbly.strategy.placeentrust('cu1902','buysell','b','price',48190,'volume',1,...
    'stop',48060,'limit',48400,'RiskManagerName','batman');
%% reset
ccbly.ops.trades_.node_(4).riskmanager_.pxstoploss_ = 48260;
% ccbly.ops.trades_.node_(4).riskmanager_.pxtarget_ = 48400;
ccbly.ops.trades_.node_(4).riskmanager_



