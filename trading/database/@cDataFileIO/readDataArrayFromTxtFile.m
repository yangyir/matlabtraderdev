function dataArray = readDataArrayFromTxtFile(fn_,delimiter,formatSpec)
    fileID = fopen(fn_,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
    fclose(fileID);
end
%end of static function 'readDataArrayFromTxtFile'