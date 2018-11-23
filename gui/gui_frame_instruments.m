function [handles] = gui_frame_instruments(handles,ui_frame)
    variablenotused(ui_frame);

    panelbox = handles.instruments.panelbox;
    eqindexList = {'CSI300';'SSE50';'CSI500'};
    govtbondList = {'GovtBond5y';'GovtBond10y'};
    preciousmetalList = {'Gold';'Silver'};
    basemetalList = {'Copper';'Aluminum';'Zinc';'Lead';'Nickel'};
    blackList = {'Coke';'CokingCoal'};
    engeryList = {'PTA';'LLDPE';'PP';'Methanol';'ThermalCoal'};
    agricultureList = {'Soybean';'Soymeal';'SoybeanOil';'PalmOil';'Apple';...
        'Sugar';'Cotton';'RapeseedOil';'RapeseedMeal'};
    %
    %we will have equityList,govtbondList,preciousmetalList and
    %basemetalList on the left hand side and the rest on the right hand side
    
    listLeft = [eqindexList;govtbondList;preciousmetalList;basemetalList];
    listLeft = [listLeft;{'Crude';'Rebar';'IronOre'}];
    ninstruments = size(listLeft,1);
    %all the check boxes in total will take 90% of the pannel'height and it is 60% wide as of the pannel's width 
    checkboxWidth = 0.4;
    checkboxX = 0.05;
    checkboxH = 0.9*(1/(ninstruments+1));
    checkbox2checkboxV = (1-checkboxH*ninstruments)/(ninstruments+1);
    checkboxFontSize = 8;
    for i = 1:ninstruments
        checkboxname = [listLeft{i},'_checkbox'];
        checkboxPosY = 1-(checkbox2checkboxV*i+checkboxH*i);
        handles.instruments.(checkboxname) = uicontrol('Parent', panelbox, 'style', 'checkbox', ...
        'Foregroundcolor', 'k', 'String', listLeft{i}, ...
        'Units', 'Normalized', ...
        'Position', [checkboxX checkboxPosY checkboxWidth checkboxH], ...
        'FontSize', checkboxFontSize, ...
        'FontWeight', 'bold');
    end
    handles.instruments.listLeft = listLeft;
    %
    %
    listRight = [blackList;engeryList;agricultureList];
    ninstruments = size(listRight,1);
    %all the check boxes in total will take 90% of the pannel'height and it is 60% wide as of the pannel's width 
    checkboxX = 2*checkboxX+checkboxWidth;
    checkboxH = 0.9*(1/(ninstruments+1));
    checkbox2checkboxV = (1-checkboxH*ninstruments)/(ninstruments+1);
    for i = 1:ninstruments
        checkboxname = [listRight{i},'_checkbox'];
        checkboxPosY = 1-(checkbox2checkboxV*i+checkboxH*i);
        handles.instruments.(checkboxname) = uicontrol('Parent', panelbox, 'style', 'checkbox', ...
        'Foregroundcolor', 'k', 'String', listRight{i}, ...
        'Units', 'Normalized', ...
        'Position', [checkboxX checkboxPosY checkboxWidth checkboxH], ...
        'FontSize', checkboxFontSize, ...
        'FontWeight', 'bold');
    end
    handles.instruments.listLeft = listLeft;
end