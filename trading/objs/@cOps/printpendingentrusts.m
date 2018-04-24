function [] = printpendingentrusts(obj)
n = obj.entrustspending_.latest;
fprintf('unsettled entrusts:\n')
if n == 0
    fprintf('\tnone!\n');
    return
end

fprintf('\t%18s%18s%12s%12s%12s%12s%12s\n','entrustnumber','instrument','buy/sell','open/close','volume','dealvolume','price');
for i = 1:n
    fprintf('\t');
    fprintf('%18d',obj.entrustspending_.node(i).entrustNo);
    fprintf('%18s',obj.entrustspending_.node(i).instrumentCode);
    if obj.entrustspending_.node(i).direction == 1
        fprintf('%12s','buy');
    else
        fprintf('%12s','sell');
    end
    if obj.entrustspending_.node(i).offsetFlag == 1
        fprintf('%12s','open');
    else
        fprintf('%12s','close');
    end
    
    fprintf('%12d',obj.entrustspending_.node(i).volume);
    fprintf('%12d',obj.entrustspending_.node(i).dealVolume);
    fprintf('%12.0f',obj.entrustspending_.node(i).price);
    
    fprintf('\n');
end

end