classdef cDataFileIO < handle
    %class to handle jobs reading/writing data from local text or excel
    %files into matlab
    
    methods (Static)
        [data,coldefs,textdata] = loadDataFromTxtFile(fn_)
        flag = saveDataToTxtFile(fn_,data,coldefs,permission,usedatestr)
        dataArray = readDataArrayFromTxtFile(fn_,delimiter,formatSpec)
    end
    
end