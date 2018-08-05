function [] = trading_func_copylogs()

path = 'c:/yangyiran/';
try
    cd(path);
catch
    mkdir(path);
end

folder = 'log/';
try
    cd([path,folder]);
catch
    mkdir([path,folder]);
end


lastbd = getlastbusinessdate;

try
    copyfile([path,'activefutlist.txt'],[path,folder,'activefutlist_',datestr(lastbd,'yyyymmdd'),'.txt']);
catch
end



end