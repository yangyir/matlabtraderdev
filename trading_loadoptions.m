if ~(exist('conn','var') && isa(conn,'cBloomberg'))
    conn = cBloomberg;
end

fut_dir_ = [getenv('DATAPATH'),'info_futures\'];
opt_dir_ = [getenv('DATAPATH'),'info_option\'];
%%
strikes_soymeal = [2600;2650;2700;2750;2800;2850];
fut_m1801 = cFutures('m1801');
fut_m1801.loadinfo([fut_dir_,'m1801_info.txt']);
opt_c_m1801 = cell(size(strikes_soymeal));
opt_p_m1801 = cell(size(strikes_soymeal));
for i = 1:size(strikes_soymeal,1)
    c_code_i = ['m1801-C-',num2str(strikes_soymeal(i))];
    opt_c_m1801{i} = cOption(c_code_i);
    fn = [opt_dir_,c_code_i,'_info.txt'];
    fid = fopen(fn);
    if fid > 0
        opt_c_m1801{i}.loadinfo(fn);
        fclose(fid);
    else
        opt_c_m1801{i}.init(conn);
        opt_c_m1801{i}.saveinfo(fn);
    end
    %
    p_code_i = ['m1801-P-',num2str(strikes_soymeal(i))];
    opt_p_m1801{i} = cOption(p_code_i);
    fn = [opt_dir_,p_code_i,'_info.txt'];
    fid = fopen(fn);
    if fid > 0
        opt_p_m1801{i}.loadinfo(fn);
        fclose(fid);
    else
        opt_p_m1801{i}.init(conn);
        opt_p_m1801{i}.saveinfo(fn);
    end
    
end

%%
strikes_sugar = [5900;6000;6100;6200;6300;6400];
fut_SR801 = cFutures('SR801');
fut_SR801.loadinfo([fut_dir_,'SR801_info.txt']);
opt_c_SR801 = cell(size(strikes_sugar));
opt_p_SR801 = cell(size(strikes_sugar));
for i = 1:size(strikes_sugar,1)
    c_code_i = ['SR801C',num2str(strikes_sugar(i))];
    opt_c_SR801{i} = cOption(c_code_i);
    fn = [opt_dir_,c_code_i,'_info.txt'];
    fid = fopen(fn);
    if fid > 0
        opt_c_SR801{i}.loadinfo(fn);
        fclose(fid);
    else
        opt_c_SR801{i}.init(conn);
        opt_c_SR801{i}.saveinfo(fn);
    end
    %
    p_code_i = ['SR801P',num2str(strikes_sugar(i))];
    opt_p_SR801{i} = cOption(p_code_i);
    fn = [opt_dir_,p_code_i,'_info.txt'];
    fid = fopen(fn);
    if fid > 0 
        opt_p_SR801{i}.loadinfo(fn);
        fclose(fid);
    else
        opt_p_SR801{i}.init(conn);
        opt_p_SR801{i}.saveinfo(fn);
    end
end

%%
fprintf('listed option loaded......\n');
fprintf('\tcall soymeal\n');
disp(opt_c_m1801);
fprintf('\tput soymeal\n');
disp(opt_c_m1801);
fprintf('\tcall sugar\n');
disp(opt_p_SR801);
fprintf('\tput sugar\n');
disp(opt_p_SR801);

