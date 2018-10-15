function [] = demo()
    fprintf('run demo of cStratConfigArray\n');
    obj = cStratConfigArray;
    fprintf('load from %s\n','C:\yangyiran\config\generalconfig.txt');
    
    obj.loadfromfile('filename','C:\yangyiran\config\generalconfig.txt');
    
    fprintf('display config:\n\n');
    n = obj.latest_;
    for i = 1:n   
        disp(obj.node_(i));
        fprintf('\n');
    end

end