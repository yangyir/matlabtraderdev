%initiate variables for counter ccb_ly_fut
fprintf('running ''citickim_init''..\n');
citickim_countername = 'citic_kim_fut';
%
citickim_stratname_manual = 'manual';
citickim_stratname_batman = 'batman';
citickim_stratname_wlpr = 'wlpr';
citickim_stratname_wlprbatman = 'wlprbatman';
%
citickim_bookname_manual = 'citickimbookmanual';
citickim_bookname_batman = 'citickimbookbatman';
citickim_bookname_wlpr = 'citickimbookwlpr';
citickim_bookname_wlprbatman = 'citickimbookwlprbatman';
%
citickim_path = [getenv('HOME'),'realtrading\citickim\'];
citickim_path_manual = [citickim_path,'manual\'];
try
    cd(citickim_path_manual);
catch
    mkdir(citickim_path_manual);
end
citickim_path_batman = [citickim_path,'batman\'];
try
    cd(citickim_path_batman);
catch
    mkdir(citickim_path_batman);
end
citickim_path_wlpr = [citickim_path,'wlpr\'];
try
    cd(citickim_path_wlpr);
catch
    mkdir(citickim_path_wlpr);
end
citickim_path_wlprbatman = [citickim_path,'wlprbatman\'];
try
    cd(citickim_path_wlprbatman);
catch
    mkdir(citickim_path_wlprbatman);
end
%
%
cd([getenv('HOME'),'realtrading\'])