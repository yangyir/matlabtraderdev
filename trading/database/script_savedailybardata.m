%note:
%this script initiates the futures information from bloomberg connection
%and then save the info into the prespecified folder and text files
override = true;
if ~(exist('conn','var') && isa(conn,'cBloomberg'))
    conn = cBloomberg;
end

%%
%base metals
bm_codes_ctp = {'cu1712';'cu1801';'cu1802';'cu1803';'cu1804';'cu1805';'cu1806';...
    'al1712';'al1801';'al1802';'al1803';'al1804';'al1805';'al1806';...
    'zn1712';'zn1801';'zn1802';'zn1803';'zn1804';'zn1805';'zn1806';...
    'pb1712';'pb1801';'pb1802';'pb1803';'pb1804';'pb1805';'pb1806';...
    'ni1801';'ni1805';'ni1809'};

for i = 1:size(bm_codes_ctp,1)
    savedailybarfrombloomberg(conn,bm_codes_ctp{i},override);
end
fprintf('done for saving daily bar data for base metal futures......\n');

%%
% govtbond futures
govtbond_codes_ctp = {'TF1712';'TF1803';'TF1806';...
    'T1712';'T1803';'T1806'};

for i = 1:size(govtbond_codes_ctp,1)
    savedailybarfrombloomberg(conn,govtbond_codes_ctp{i},override);
end
fprintf('done for saving daily bar data for govt bond futures......\n');

%%
% precious metals
pm_codes_ctp = {'au1712';'au1806';'ag1712';'ag1806'};

for i = 1:size(pm_codes_ctp,1)
    savedailybarfrombloomberg(conn,pm_codes_ctp{i},override);
end
fprintf('done for saving daily bar data for precious metal futures\n');

%%
% agriculture for options
ag_codes_ctp = {'m1801';'m1805';'SR801';'SR805'};
for i = 1:size(ag_codes_ctp,1)
    savedailybarfrombloomberg(conn,ag_codes_ctp{i},override);
end
fprintf('done for saving daily bar data for agriculture futures\n');

%%
% agriculture for options
black_codes_ctp = {'rb1801';'rb1805';'rb1810';'i1801';'i1805';'i1809'};
for i = 1:size(black_codes_ctp,1)
    savedailybarfrombloomberg(conn,black_codes_ctp{i},override);
end
fprintf('done for saving daily bar data for black futures\n');

%%
%soymeal
futures_code_ctp_soymeal = {'m1801';'m1805'};
strikes_soymeal = [2600;2650;2700;2750;2800;2850;2900;2950;3000];
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
futures_code_ctp_sugar = {'SR801';'SR805'};
strikes_sugar = [6000;6100;6200;6300;6400;6500];
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


