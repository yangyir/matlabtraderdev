function [] = demo()
    fprintf('run demo of cStratConfig\n');
    obj = cStratConfig;
    fprintf('load from %s\n','C:\yangyiran\config\generalconfig.txt');
    
    obj.loadfromfile('code','cu1812','filename','C:\yangyiran\config\generalconfig.txt');
    fprintf('display config:\n\n');
    disp(obj);

end

