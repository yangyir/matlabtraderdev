function positions = convert2positions(obj)
%positions is cell
positions = {};
n = obj.latest_;

if n == 0, return;end
codes = cell(n,1);
count = 0;
for i = 1:n
    trade_i = obj.node_(i);
    if strcmpi(trade_i.status_,'closed') || strcmpi(trade_i.status_,'unset')
        continue;
    end
    count = count + 1;
    codes{count} = trade_i.code_;
end

codes = codes(1:count);
codes = unique(codes);
ninstrument = size(codes,1);
positions = cell(ninstrument,1);


for i = 1:n
    trade_i = obj.node_(i);
    if strcmpi(trade_i.status_,'closed') || strcmpi(trade_i.status_,'unset')
        continue;
    end
    code_ctp = trade_i.code_;
    for j = 1:ninstrument
        if strcmpi(code_ctp,codes{j})
            openprice = trade_i.openprice_;
            opendirection = trade_i.opendirection_;
            openvolume = trade_i.openvolume_;
            opentime = trade_i.opendatetime1_;
            if isempty(positions{j})
                pos = cPos;
                pos.override('code',code_ctp,'price',openprice,'volume',opendirection*openvolume,'time',opentime);
                positions{j} = pos;
            else
                positions{j}.add('code',code_ctp,'price',openprice,'volume',opendirection*openvolume,'time',opentime);
            end
            break
        end
    end
    
end


end