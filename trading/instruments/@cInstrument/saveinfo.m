function saveinfo(obj,fn_)
    fid = fopen(fn_,'w');
    fields = properties(obj);
    for i = 1:size(fields,1)
        propname = fields{i};
        propvalue = obj.(fields{i});
        if isnumeric(propvalue)
            fprintf(fid,'%s\t%s\n',propname,num2str(propvalue));
        else
            fprintf(fid,'%s\t%s\n',propname,propvalue);
        end
    end
    fclose(fid);
end
%end of saveinfo

