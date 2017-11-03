mde = cMDE;
qms_mde = cQMS;
qms_mde.setdatasource('ctp');
mde.qms_ = qms_mde;

%%
% for i = 1:size(strikes_soymeal)
%     mde.registerinstrument(opt_c_m1801{i});mde.registerinstrument(opt_p_m1801{i});
% end
% 
% for i = 1:size(strikes_sugar)
%     mde.registerinstrument(opt_c_SR801{i});mde.registerinstrument(opt_p_SR801{i});
% end
% 
% mde.initdataarray;

gb05 = cFutures('TF1712');gb05.loadinfo('TF1712_info.txt');
gb10 = cFutures('T1712');gb10.loadinfo('T1712_info.txt');
mde.registerinstrument(gb05);
mde.registerinstrument(gb10);

%%
mde.refresh

%%
mde.autorun

%%
stop(mde.timer_)

%%
mdefut = cMDEFut;
mdefut.qms_ = qms_mde;
mdefut.registerinstrument(fut_m1801);
mdefut.registerinstrument(fut_SR801);
mdefut.qms_.refresh;

%%
mdefut.start;

%%
mdefut.stop;

