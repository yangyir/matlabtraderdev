%initiate variables for counter ccb_ly_fut
fprintf('running ''ccbly_init''..\n');
ccbly_countername = 'ccb_ly_fut';
%
ccbly_stratname_manual = 'manual';
ccbly_stratname_batman = 'batman';
ccbly_stratname_wlpr = 'wlpr';
ccbly_stratname_wlprbatman = 'wlprbatman';
%
ccbly_bookname_manual = 'ccblybookmanual';
ccbly_bookname_batman = 'ccblybookbatman';
ccbly_bookname_wlpr = 'ccblybookwlpr';
ccbly_bookname_wlprbatman = 'ccblybookwlprbatman';
%
ccbly_path = [getenv('HOME'),'realtrading\ccbly\'];
ccbly_path_manual = [ccbly_path,'manual\'];
try
    cd(ccbly_path_manual);
catch
    mkdir(ccbly_path_manual);
end
ccbly_path_batman = [ccbly_path,'batman\'];
try
    cd(ccbly_path_batman);
catch
    mkdir(ccbly_path_batman);
end
ccbly_path_wlpr = [ccbly_path,'wlpr\'];
try
    cd(ccbly_path_wlpr);
catch
    mkdir(ccbly_path_wlpr);
end
ccbly_path_wlprbatman = [ccbly_path,'wlprbatman\'];
try
    cd(ccbly_path_wlprbatman);
catch
    mkdir(ccbly_path_wlprbatman);
end
%
%
cd([getenv('HOME'),'realtrading\'])