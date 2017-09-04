clc;
fprintf('demo_cwatcheropt/m\n');

wco = cWatcherOpt;

wco.addsingle('m1801-C-2700');

wco.addpair('SR801C6400,SR801C6500');

weights = [1,-2,1];
wco.addstruct('m1801-C-2700,m1801-C-2750,m1801-C-2800',weights);

wco.conn = 'bloomberg';

wco.removepair('SR801C6400,SR801C6500');


wco