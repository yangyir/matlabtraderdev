clc;
fprintf('demo_cwatchergovtbond.m\n');
wgb = cWatcherGovtBondFut;

wgb.addsingle('tf1712');

%test addsingles
singles = 'tf1709,t1709,t1712,ni1801';
wgb.addsingles(singles);

%test addpair
pair = 'tf1712,t1712';
wgb.addpair(pair);

%test addpairs
pairs = 'tf1709,t1709;tf1712,t1712';
wgb.addpairs(pairs);

wgb.conn = 'bloomberg';
wgb.refresh;

fprintf('singles:\n');
for i = 1:wgb.countsingles
    wgb.qs{i}.print;
end

fprintf('pairs:\n');

for i = 1:wgb.countpairs
    wgb.qp{i}.print;
end

wgb.close;

fprintf('\ntest done,all passed!\n')



