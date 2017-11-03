%demo_cStratFutMultiWR
demo_strat_wr = cStratFutMultiWR;
if exist('c_kim','var')
    demo_strat_wr.registercounter(c_kim);
else
    fprintf('counter is missing......\n');
end

%%
%read parameters from file
fprintf('set parameters for strat wr......\n');
fn_ = 'C:\Users\yangyiran\Documents\GitHub\strat_wr_params_rb.txt';
demo_strat_wr.readparametersfromtxtfile(fn_);

%%
%try to load positions of instruments from the counter and return empty
%portfolio in case none instruments are found
demo_strat_wr.loadportfoliofromcounter;
demo_strat_wr.portfolio_.print;

%%
fprintf('initiate data for strat wr......\n');
demo_strat_wr.initdata;

%%
demo_strat_wr.startat([datestr(today,'yyyy-mm-dd'),' 09:00:00']);

%%
demo_strat_wr.start;

%%
demo_strat_wr.stop;

%%
demo_strat_wr.printinfo
