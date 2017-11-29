fprintf('running demo_cportfolio......\n');

ni1801 = cFutures;
ni1801.loadinfo('ni1801_info.txt');

al1711 = cFutures;
al1711.loadinfo('al1711_info.txt');

port = cPortfolio;
port.portfolio_id = 'demo_cportfolio';
port.addinstrument(ni1801);
port.addinstrument(al1711);
fprintf('\nportfolio register with %s and %s:\n',ni1801.code_ctp,al1711.code_ctp);
port.print;

%%
px = 94970;
v = 1;
port.addinstrument(ni1801,px,v);
fprintf('\nportfolio after adding %d lots of %s:\n',v,ni1801.code_ctp);
port.print

%%
px = 94860;
v = 2;
port.addinstrument(ni1801,px,v);
fprintf('\nportfolio after adding %d lots of %s again:\n',v,ni1801.code_ctp);
port.print

%%
px = 96000;
v = -4;
port.addinstrument(ni1801,px,v);
fprintf('\nportfolio after adding %d lots of %s again:\n',v,ni1801.code_ctp);
port.print

%%
port.removeinstrument(ni1801);
fprintf('\nportfolio after removing %s:\n',ni1801.code_ctp);
port.print

fprintf('demo_cportfolio done......\n')