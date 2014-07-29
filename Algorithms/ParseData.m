% Create the graph of the parameter space
% data = e.g. fvals_betas_1
% param = e.g. 'beta'
% boardNum = e.g. '3' (must be a string)
% optNum = e.g. '10' (must be a string)
% saveData = 1 if you want to save data, 0 otherwise

function [] = ParseData(data, param, boardNum, optNum, saveData)
    % Graph data
    surf(data(:,:,1), data(:,:,2), data(:,:,3));
    strBoard = strcat('Board', boardNum, '.Opt', optNum);
    pos = strfind(strBoard, '_'); % Parse out _ from _soft
    if ~isempty(pos)
        strTitle = strcat(strBoard(1:(pos-1)), '\', strBoard(pos:end)); % This is necessary so that title is readable
    else
        strTitle = strBoard;
    end
    xlabel(strcat(param, 'R')); ylabel(strcat(param, 'P')); zlabel('fval'); title(strcat(strTitle, ' fvals'));
    colorbar;
    set(gcf, 'Position', get(0,'Screensize'));
    
    if saveData == 1
        % Save graph
        [currentPath, ~, ~] = fileparts(mfilename('fullpath'));
        strPath = strcat(currentPath, '/Tests/Graphs/', strBoard, '.bmp');
        if ~exist(strPath, 'file')
            saveas(gcf, strPath);
        end

        % Save the data
        strPath = strcat(currentPath, '/Tests/Values/', strBoard, '.mat');
        if ~exist(strPath, 'file')
            save(strPath, 'data');
        end
    end

    % If I want to collapse a .05 step into a .1 step
    %collapse = 0;
    %if collapse == 1
    %    fvals_c = zeros(11, 11, 3);
    %    for i = 1 : 3
    %        fvals_c(:,:,i) = fvals(1:2:end,1:2:end,i);
    %    end

    %    surf(fvals_c(:,:,1), fvals_c(:,:,2), fvals_c(:,:,3));
    %    xlabel('betaR'); ylabel('betaP'); zlabel('fval'); title('Board2.Opt11 fvals collapsed');
    %end
end