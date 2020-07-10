% This script summarise all the unique files in the same folder
function []=SummariseUniqueFiles(unidir, uniqueSummaryDir, sheetname);
    fileList = dir(fullfile(unidir,[sheetname '*.txt']));
    fileList = struct2table(fileList);
    fileList = fileList.name;
    % extract unique files
    pattern = '\d{8}-R\d+F\d+-\d+[A-Z]{2}[a-z]{2}[A-Z]{2}\d+-\d+[A-Z]{2}\d+.txt';
    fileList =regexp(fileList, pattern, 'match');
    
    fprintf('summarising unique files...\n');
   
    if exist('summaryTbl')
        clear summaryTbl
    end

    for i = 1:length(fileList)
       if (~isempty(fileList{i}))
           tbl = checkUniqueFile(fullfile(unidir,char(fileList{i})));
           if (~exist('summaryTbl'))
               summaryTbl = tbl;
           else
               summaryTbl = [summaryTbl;tbl];
           end
       end
    end
    
    savename = strcat('summary-',sheetname, '.txt');
    saveFile = fullfile(uniqueSummaryDir, savename);
    writetable(summaryTbl, saveFile,'WriteRowNames',true);
end
