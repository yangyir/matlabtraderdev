%% ctp login 
ccbly.mdefut.login('Connection','ctp','countername',ccbly_countername);
ccbly.mdefut.start;

%%
code = 'au1906';
wlprinfo = ccbly.strategy.wlpr(code);
disp(wlprinfo);
%
ccbly.strategy.stratplot(code)

%%
fprintf('my name is irene and i love rabbit\n')
%%
clc



