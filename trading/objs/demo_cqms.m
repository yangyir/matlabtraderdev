fprintf('running demo_cqms...\n');

f1 = cFutures;
f2 = cFutures;

f1.loadinfo('TF1712_info.txt');
f2.loadinfo('T1712_info.txt');

qms = cQMS;
qms.registerinstrument(f1);
qms.registerinstrument(f2);
qms.setdatasource('bloomberg');

qms.start;

%%
qms.stop;