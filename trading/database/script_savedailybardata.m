%note:
%this script initiates the futures information from bloomberg connection
%and then save the info into the prespecified folder and text files
override = true;
if ~(exist('conn','var') && isa(conn,'cBloomberg'))
    conn = cBloomberg;
end

%%
%base metals
bm_codes_ctp = {'cu1805';'cu1806';'cu1807';'cu1808';'cu1809';'cu1810';'cu1811';...
    'al1805';'al1806';'al1807';'al1808';'al1809';'al1810';'al1811';...
    'zn1805';'zn1806';'zn1807';'zn1808';'zn1809';'zn1810';'zn1811';...
    'pb1805';'pb1806';'pb1807';'pb1808';'pb1809';'pb1810';'pb1811';...
    'ni1805';'ni1807';'ni1809';'ni1811';'ni1901'};

for i = 1:size(bm_codes_ctp,1)
    savedailybarfrombloomberg(conn,bm_codes_ctp{i},override);
end
fprintf('done for saving daily bar data for base metal futures......\n');

%%
% govtbond futures
govtbond_codes_ctp = {'TF1806';'TF1809';'TF1812';...
    'T1806';'T1809';'T1812'};

for i = 1:size(govtbond_codes_ctp,1)
    savedailybarfrombloomberg(conn,govtbond_codes_ctp{i},override);
end
fprintf('done for saving daily bar data for govt bond futures......\n');

%%
% precious metals
pm_codes_ctp = {'au1806';'au1812';'ag1806';'ag1812'};

for i = 1:size(pm_codes_ctp,1)
    savedailybarfrombloomberg(conn,pm_codes_ctp{i},override);
end
fprintf('done for saving daily bar data for precious metal futures\n');

%%
% agriculture for options
ag_codes_ctp = {'m1805';'m1809';'m1901';'SR805';'SR809';'SR901'};
for i = 1:size(ag_codes_ctp,1)
    savedailybarfrombloomberg(conn,ag_codes_ctp{i},override);
end
fprintf('done for saving daily bar data for agriculture futures\n');

%%
% agriculture for options
black_codes_ctp = {'rb1805';'rb1810';'rb1901';'i1805';'i1809';'i1901'};
for i = 1:size(black_codes_ctp,1)
    savedailybarfrombloomberg(conn,black_codes_ctp{i},override);
end
fprintf('done for saving daily bar data for black futures\n');

%%
%soymeal
futures_code_ctp_soymeal = {'m1809';'m1901'};
strikes_soymeal = (2500:50:3500)';

c_code_ctp_soymeal = cell(size(futures_code_ctp_soymeal,1),size(strikes_soymeal,1));
p_code_ctp_soymeal = cell(size(futures_code_ctp_soymeal,1),size(strikes_soymeal,1));

for i = 1:size(futures_code_ctp_soymeal,1)
    for j = 1:size(strikes_soymeal,1)
        c_code_ = [futures_code_ctp_soymeal{i},'-C-',num2str(strikes_soymeal(j))];
        savedailybarfrombloomberg(conn,c_code_,override);
        %
        p_code_ = [futures_code_ctp_soymeal{i},'-P-',num2str(strikes_soymeal(j))];
        savedailybarfrombloomberg(conn,p_code_,override);
    end  
end
fprintf('done for soymeal options......\n');

%%
%white sugar
futures_code_ctp_sugar = {'SR809';'SR901'};
strikes_sugar = (5000:100:6500)';
c_code_ctp_sugar = cell(size(futures_code_ctp_sugar,1),size(strikes_sugar,1));
p_code_ctp_sugar = cell(size(futures_code_ctp_sugar,1),size(strikes_sugar,1));

for i = 1:size(futures_code_ctp_sugar,1)
    for j = 1:size(strikes_sugar,1)
        c_code_ = [futures_code_ctp_sugar{i},'C',num2str(strikes_sugar(j))];
        savedailybarfrombloomberg(conn,c_code_,override);
        %
        p_code_ = [futures_code_ctp_sugar{i},'P',num2str(strikes_sugar(j))];
        savedailybarfrombloomberg(conn,p_code_,override);
    end  
end
fprintf('done for white sugar options......\n');


