qms = cQMS;
qms.setdatasource('ctp');
mdefut = cMDEFut;mdefut.qms_ = qms;
mdeopt = cMDEOpt;mdeopt.qms_ = qms;
%%
% Base Metals
codes_bm = {'cu1806';'al1806';'zn1806';'pb1806';'ni1807'};
futs_bm = cell(size(codes_bm));
for i = 1:size(codes_bm,1)
    futs_bm{i} = cFutures(codes_bm{i});futs_bm{i}.loadinfo([codes_bm{i},'_info.txt']);
    qms.registerinstrument(futs_bm{i});
    mdefut.registerinstrument(futs_bm{i});
end
%%
% SoyMeal Futures
code_sm = 'm1809';
futs_sm = cFutures(code_sm);futs_sm.loadinfo([code_sm,'_info.txt']);
qms.registerinstrument(futs_sm);
mdefut.registerinstrument(futs_sm);
strikes_sm = [3100;3150;3200;3250;3300];
c_sm = cell(size(strikes_sm));
p_sm = cell(size(strikes_sm));
for i = 1:size(strikes_sm,1)
    c = [code_sm,'-C-',num2str(strikes_sm(i))];
    copt = cOption(c);copt.loadinfo([c,'_info.txt']);
    qms.registerinstrument(copt);
    mdeopt.registerinstrument(copt);
    p = [code_sm,'-P-',num2str(strikes_sm(i))];
    popt = cOption(p);popt.loadinfo([p,'_info.txt']);
    qms.registerinstrument(popt);
    mdeopt.registerinstrument(popt);
end
%%
% Sugar Futures
code_sugar = 'SR809';
futs_sugar = cFutures(code_sugar);futs_sugar.loadinfo([code_sugar,'_info.txt']);
qms.registerinstrument(futs_sugar);
mdefut.registerinstrument(futs_sugar);
strikes_sugar = [5300;5400;5500;5600;5700];
c_sugar = cell(size(strikes_sugar));
p_sugar = cell(size(strikes_sugar));
for i = 1:size(strikes_sm,1)
    c = [code_sugar,'C',num2str(strikes_sugar(i))];
    copt = cOption(c);copt.loadinfo([c,'_info.txt']);
    qms.registerinstrument(copt);
    mdeopt.registerinstrument(copt);
    p = [code_sugar,'P',num2str(strikes_sugar(i))];
    popt = cOption(p);popt.loadinfo([p,'_info.txt']);
    qms.registerinstrument(popt);
    mdeopt.registerinstrument(popt);
end
