%note:
%this script initiates the listed option information from bloomberg connection
%and then save the info into the prespecified folder and text files
if ~(exist('conn','var')  && isa(conn,'cBloomberg'))
    conn = cBloomberg;
end
%%
fut_dir_ = [getenv('DATAPATH'),'info_futures\'];
try
    cd(fut_dir_);
catch
    mkdir(fut_dir_);
end

opt_dir_ = [getenv('DATAPATH'),'info_option\'];
try
    cd(opt_dir_);
catch
    mkdir(opt_dir_);
end


%%
%soymeal
futures_code_ctp_soymeal = {'m1801';'m1805'};
strikes_soymeal = [2600;2650;2700;2750;2800];
c_code_ctp_soymeal = cell(size(futures_code_ctp_soymeal,1),size(strikes_soymeal,1));
p_code_ctp_soymeal = cell(size(futures_code_ctp_soymeal,1),size(strikes_soymeal,1));

for i = 1:size(futures_code_ctp_soymeal,1)
    fut = cFutures(futures_code_ctp_soymeal{i});
    fut.init(conn);
    fut.saveinfo([fut_dir_,futures_code_ctp_soymeal{i},'_info.txt']);
    for j = 1:size(strikes_soymeal,1)
        c_code_ = [futures_code_ctp_soymeal{i},'-C-',num2str(strikes_soymeal(j))];
        c_opt = cOption(c_code_);
        c_opt.init(conn);
        c_opt.saveinfo([opt_dir_,c_code_,'_info.txt']);
        %
        p_code_ = [futures_code_ctp_soymeal{i},'-P-',num2str(strikes_soymeal(j))];
        p_opt = cOption(p_code_);
        p_opt.init(conn);
        p_opt.saveinfo([opt_dir_,p_code_,'_info.txt']);
    end  
end
fprintf('done for soymeal options......\n');

%%
%white sugar
futures_code_ctp_sugar = {'SR801';'SR805'};
strikes_sugar = [6000;6100;6200;6300;6400];
c_code_ctp_sugar = cell(size(futures_code_ctp_sugar,1),size(strikes_sugar,1));
p_code_ctp_sugar = cell(size(futures_code_ctp_sugar,1),size(strikes_sugar,1));

for i = 1:size(futures_code_ctp_sugar,1)
    fut = cFutures(futures_code_ctp_sugar{i});
    fut.init(conn);
    fut.saveinfo([fut_dir_,futures_code_ctp_sugar{i},'_info.txt']);
    for j = 1:size(strikes_sugar,1)
        c_code_ = [futures_code_ctp_sugar{i},'C',num2str(strikes_sugar(j))];
        c_opt = cOption(c_code_);
        c_opt.init(conn);
        c_opt.saveinfo([opt_dir_,c_code_,'_info.txt']);
        %
        p_code_ = [futures_code_ctp_sugar{i},'P',num2str(strikes_sugar(j))];
        p_opt = cOption(p_code_);
        p_opt.init(conn);
        p_opt.saveinfo([opt_dir_,p_code_,'_info.txt']);
    end  
end
fprintf('done for white sugar options......\n');


