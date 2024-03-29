%% 内地股票指数综合
%non-tradable assets
wcodes_ashare_index = {'000001.SH';...%上证指数
    '399001.SZ';...%深证成指
    '881001.WI';...%万得全A
    '000300.SH';...%沪深300
    '000688.SH';...%科创50
    '399006.SZ';...%创业板指
    '000016.SH';...%上证50
    '931643.CSI';...%科创创业50
    '000905.SH';...%中证500
    '000852.SH';...%中证1000
    };
%tradeable assets
wcodes_ashare_index_etf = {'n/a';...
    'n/a';...
    'n/a';...
    '510300';...
    '588000';...
    '159915';...
    '510050';...
    '159781';...
    '510500';...
    '512100';...
    };
%%
for i = 1:length(wcodes_ashare_index),savedailybarfromwind2(w,wcodes_ashare_index{i});end
fprintf('daily bar of ashare indices saved......\n');

