%note:
%this script initiates the futures information from bloomberg connection
%and then save the info into the prespecified folder and text files
override = true;
if ~(exist('conn','var') && isa(conn,'cBloomberg'))
    conn = cBloomberg;
end

%%
saveactivefuturesfrombloomberg(conn);
lastbd = getlastbusinessdate;
activefuturesdir = [getenv('DATAPATH'),'activefutures\'];
filename = ['activefutures_',datestr(lastbd,'yyyymmdd'),'.txt'];
activefutures = cDataFileIO.loadDataFromTxtFile([activefuturesdir,filename]);
assetlist = getassetmaptable;
nasset = length(assetlist);
%%
%base metals
bm = {'copper';'aluminum';'zinc';'lead';'nickel'};
for i = 1:size(bm,1)
    for iasset = 1:nasset
        if strcmpi(assetlist{iasset},bm{i})
            activefut_i = activefutures{iasset};
            break
        end
    end
    savedailybarfrombloomberg(conn,activefut_i,override);
    %
    excode = activefut_i(1:2);
    yystr = activefut_i(3:4);
    yynum = str2double(yystr);
    mmstr = activefut_i(5:6);
    mmnum = str2double(mmstr);
    %
    if ~strcmpi(bm{i},'nickel')
        %SIX consective futures for base metals except for nickel
        nfut = 5;
        mmdiff = 1;
    else
        %TWO futures for nickel expired every other month
        nfut = 1;
        mmdiff = 2;
    end
    %
    for ifut = 1:nfut
        mmnum = mmnum + mmdiff;
        if mmnum > 12
            mmnum = mmnum-12;
            yynum = yynum+1;
        end
        if mmnum < 10
            mmstr = ['0',num2str(mmnum)];
        else
            mmstr = num2str(mmnum);
        end
        code = [excode,num2str(yynum),mmstr];
        savedailybarfrombloomberg(conn,code,override);
    end

end
fprintf('done for saving daily bar data for base metal futures......\n');

%%
% govtbond futures
govtbond = {'govtbond_5y';'govtbond_10y'};
for i = 1:size(govtbond,1)
    for iasset = 1:nasset
        if strcmpi(assetlist{iasset},govtbond{i})
            activefut_i = activefutures{iasset};
            break
        end
    end
    savedailybarfrombloomberg(conn,activefut_i,override);
    %
    for ichar = 1:length(activefut_i)
        if isnumchar(activefut_i(ichar))
            break
        end
    end
        
    excode = activefut_i(1:ichar-1);
    yystr = activefut_i(ichar:ichar+1);
    yynum = str2double(yystr);
    mmstr = activefut_i(ichar+2:ichar+3);
    mmnum = str2double(mmstr);
    %
    %quartetly expired futures
    nfut = 1;
    mmdiff = 3;
    %
    for ifut = 1:nfut
        mmnum = mmnum + mmdiff;
        if mmnum > 12
            mmnum = mmnum-12;
            yynum = yynum+1;
        end
        if mmnum < 10
            mmstr = ['0',num2str(mmnum)];
        else
            mmstr = num2str(mmnum);
        end
        code = [excode,num2str(yynum),mmstr];
        savedailybarfrombloomberg(conn,code,override);
    end
end

fprintf('done for saving daily bar data for govt bond futures......\n');

%%
% equity index
eqindex = {'eqindex_300';'eqindex_50';'eqindex_500'};
for i = 1:size(eqindex,1)
    for iasset = 1:nasset
        if strcmpi(assetlist{iasset},eqindex{i})
            activefut_i = activefutures{iasset};
            break
        end
    end
    savedailybarfrombloomberg(conn,activefut_i,override);
    %
    for ichar = 1:length(activefut_i)
        if isnumchar(activefut_i(ichar))
            break
        end
    end
        
    excode = activefut_i(1:ichar-1);
    yystr = activefut_i(ichar:ichar+1);
    yynum = str2double(yystr);
    mmstr = activefut_i(ichar+2:ichar+3);
    mmnum = str2double(mmstr);
    %
    % next futures contract only ignore the quarter contract for the
    % time bing
    nfut = 1;
    mmdiff = 1;
    %
    for ifut = 1:nfut
        mmnum = mmnum + mmdiff;
        if mmnum > 12
            mmnum = mmnum-12;
            yynum = yynum+1;
        end
        if mmnum < 10
            mmstr = ['0',num2str(mmnum)];
        else
            mmstr = num2str(mmnum);
        end
        code = [excode,num2str(yynum),mmstr];
        savedailybarfrombloomberg(conn,code,override);
    end
end

fprintf('done for saving daily bar data for equity index futures......\n');
%%
% precious metals
pm = {'gold';'silver'};
for i = 1:size(pm,1)
    for iasset = 1:nasset
        if strcmpi(assetlist{iasset},pm{i})
            activefut_i = activefutures{iasset};
            break
        end
    end
    savedailybarfrombloomberg(conn,activefut_i,override);
    %
    for ichar = 1:length(activefut_i)
        if isnumchar(activefut_i(ichar))
            break
        end
    end
        
    excode = activefut_i(1:ichar-1);
    yystr = activefut_i(ichar:ichar+1);
    yynum = str2double(yystr);
    mmstr = activefut_i(ichar+2:ichar+3);
    mmnum = str2double(mmstr);
    %
    % next futures contract semi-annual
    nfut = 1;
    mmdiff = 6;
    %
    for ifut = 1:nfut
        mmnum = mmnum + mmdiff;
        if mmnum > 12
            mmnum = mmnum-12;
            yynum = yynum+1;
        end
        if mmnum < 10
            mmstr = ['0',num2str(mmnum)];
        else
            mmstr = num2str(mmnum);
        end
        code = [excode,num2str(yynum),mmstr];
        savedailybarfrombloomberg(conn,code,override);
    end
end
fprintf('done for saving daily bar data for precious metal futures\n');

%%
% agriculture for options
ag_codes_ctp = {'m1809';'m1901';'m1905';'SR809';'SR901';'m1905'};
for i = 1:size(ag_codes_ctp,1)
    savedailybarfrombloomberg(conn,ag_codes_ctp{i},override);
end
fprintf('done for saving daily bar data for agriculture futures\n');

%%


%%



% agriculture for options
black_codes_ctp = {'rb1810';'rb1901';'i1809';'i1901'};
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


