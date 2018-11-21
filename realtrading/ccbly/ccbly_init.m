%initiate variables for counter ccb_ly_fut
fprintf('running ccb_..\n');
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
ccbly_path_manual = [getenv('HOME'),'realtrading\ccbly\manual\'];
try
    cd(ccbly_path_manual);
catch
    mkdir(ccbly_path_manual);
end
ccbly_path_batman = [getenv('HOME'),'realtrading\ccbly\batman\'];
try
    cd(ccbly_path_batman);
catch
    mkdir(ccbly_path_batman);
end
ccbly_path_wlpr = [getenv('HOME'),'realtrading\ccbly\wlpr\'];
try
    cd(ccbly_path_wlpr);
catch
    mkdir(ccbly_path_wlpr);
end
ccbly_path_wlprbatman = [getenv('HOME'),'realtrading\ccbly\wlprbatman\'];
try
    cd(ccbly_path_wlprbatman);
catch
    mkdir(ccbly_path_wlprbatman);
end
%
%
cd([getenv('HOME'),'realtrading\'])