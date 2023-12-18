datapath = [getenv('datapath'),'dailybar\'];
listing = dir(datapath);
nfiles = size(listing,1);

listcodes = cell(nfiles,1);
listassets = cell(nfiles,1);
ncode = 0;
for i = 3:nfiles
    this_name = listing(i).name;
    this_code = this_name(1:end-10);
    this_instr = code2instrument(this_code);
    if isempty(this_instr.asset_name), continue;end
    if strcmpi(this_instr,'eqindex_300') || strcmpi(this_instr,'eqindex_50')  || ...
            strcmpi(this_instr,'eqindex_50') || strcmpi(this_instr,'eqindex_500') || ...
            strcmpi(this_instr,'thermal coal')
        continue;
    end
    ncode = ncode + 1;
    listcodes{ncode,1} = this_code;
    listassets{ncode,1} = this_instr.asset_name;
end
listcodes = listcodes(1:ncode,:);
listassets = listassets(1:ncode,:);
tbl = table(listcodes,listassets);
listassetsunique = unique(listassets);
%%
% for i = 1:length(listassetsunique)
%     try
        idx_i = strcmpi(listassets,'soybean oil');
        codes_i = listcodes(idx_i);
        output_comdty_daily = fractal_kelly_summary('codes',codes_i,'frequency','daily','usefractalupdate',0,'usefibonacci',1,'direction','both');
%     catch
%         fprintf('error in %s\n',listassetsunique{i});
%     end
% end
%%
idx_s = strcmpi(listassets,'fuel oil');
codes_s = listcodes(idx_s);
for j = 1:length(codes_s)
    try
    data_j = fractal_gettradesummary(codes_s{j},...
                'frequency','daily',...
                'usefractalupdate',0,...
                'usefibonacci',1,...
                'direction','both');
    catch
        fprintf('error in %s\n',codes_s{j});
    end
end
