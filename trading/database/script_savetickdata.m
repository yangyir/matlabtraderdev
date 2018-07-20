%note:
%this script initiates the futures information from bloomberg connection
%and then save the info into the prespecified folder and text files
% override = false;
if ~(exist('conn','var') && isa(conn,'cBloomberg'))
    conn = cBloomberg;
end

fromdate = datestr(businessdate(getlastbusinessdate,-1),'yyyy-mm-dd');
todate = datestr(getlastbusinessdate,'yyyy-mm-dd');

%%
%base metals
%only extrat those active contracts
bm_codes = {'cu';'aa';'zna';'pbl';'xii'};
bm_codes_ctp = {'cu';'al';'zn';'pb';'ni'};
expiries = zeros(size(bm_codes));
for i = 1:size(bm_codes,1)
    check = conn.ds_.getdata([bm_codes{i},'a comdty'],'last_tradeable_dt');
    expiries(i) = check.last_tradeable_dt;
    yearstr = num2str(year(expiries(i))-2000);
    mm = month(expiries(i));
    if mm > 9
        monthstr = num2str(mm);
    else
        monthstr = ['0',num2str(mm)];
    end
    bm_codes_ctp{i} = [bm_codes_ctp{i},yearstr,monthstr];
end

for i = 1:size(bm_codes_ctp,1)
    savetickfrombloomberg(conn,bm_codes_ctp{i},'fromdate',fromdate,'todate',todate);
end
fprintf('done for saving tick data for base metal futures......\n');

%%
% govtbond futures
govtbond_codes = {'tfc';'tft'};
govtbond_codes_ctp = {'TF';'T'};
expiries = zeros(size(govtbond_codes));
for i = 1:size(govtbond_codes,1)
    check = conn.ds_.getdata([govtbond_codes{i},'a comdty'],'last_tradeable_dt');
    expiries(i) = check.last_tradeable_dt;
    yearstr = num2str(year(expiries(i))-2000);
    mm = month(expiries(i));
    if mm > 9
        monthstr = num2str(mm);
    else
        monthstr = ['0',num2str(mm)];
    end
    govtbond_codes_ctp{i} = [govtbond_codes_ctp{i},yearstr,monthstr];
end

for i = 1:size(govtbond_codes_ctp,1)
    savetickfrombloomberg(conn,govtbond_codes_ctp{i},'fromdate',fromdate,'todate',todate);
end
fprintf('done for saving tick data for govt bond futures......\n');

%%
%precious metals
% pm_codes_ctp = {'au1712';'au1806';'ag1712';'ag1806'};
% 
% for i = 1:size(pm_codes_ctp,1)
%     saveintradaybarfrombloomberg(conn,pm_codes_ctp{i},override);
% end
% fprintf('done for saving intraday bar data for precious metal futures\n');

%%
%rebal & iron ore
rb_codes = {'rbt';'ioe'};
rb_codes_ctp = {'rb';'i'};
expiries = zeros(size(rb_codes));
for i = 1:size(rb_codes,1)
    check = conn.ds_.getdata([rb_codes{i},'a comdty'],'last_tradeable_dt');
    expiries(i) = check.last_tradeable_dt;
    yearstr = num2str(year(expiries(i))-2000);
    mm = month(expiries(i));
    if mm > 9
        monthstr = num2str(mm);
    else
        monthstr = ['0',num2str(mm)];
    end
    rb_codes_ctp{i} = [rb_codes_ctp{i},yearstr,monthstr];
end

for i = 1:size(govtbond_codes_ctp,1)
    savetickfrombloomberg(conn,rb_codes_ctp{i},'fromdate',fromdate,'todate',todate);
end
fprintf('done for saving tick data for deformde bar and iron ore futures......\n');

%%
%clear variables
clear i
clear override conn bm_codes_ctp govtbond_codes_ctp pm_codes_ctp

