function filenames = charlotte_select_fx_files()
    dir_ = [getenv('APPDATA'),'\MetaQuotes\Terminal\Common\Files\Data\'];
    pairs = charlotte_select_fx_pairs;
    npairs = size(pairs,1);
    filenames = cell(npairs,1);
    for i = 1:npairs
        filenames{i} = [dir_,pairs{i},'.lmx_M5_running.csv'];
    end
end