function [X, Samples] = name2librarytype(varargin)
%{
    Parameters
    ----------
    allexcelfiles: The folder where the excel file is 
    xlsname: This is the name of the excel file
    sheetname: This is the name of the excel sheet within the excel file.
    sdb_numbers: This is a list of all SDBs that have been defined by ID#.
    gen_numbers: This is a list of all genetec libraries that have been 
    defined by ID#.
    
    Description
    -----------
    This function converts an excel table of sample names to the type of
    library and separates the samples based on this distinction. In the
    return variable X we flag the libraries found in this excel file (1=Yes
    they are there, 0=No they aren't) and in the Samples return variable 
    the names of the samples themselves.
    
    Samples 
    1.SDB_sam 
    2.Synthetic_sam 
    3.PrimerID_sam 
    4.Genentech_sam 
    5.M13KE_sam 
%}


% check for INPUT variable
if exist('varargin','var')
    L = length(varargin);
    if rem(L,2) ~= 0, error('Parameters/Values must come in pairs.'); end

    % read INPUT variables
    for ni = 1:2:L
        switch lower(varargin{ni})
            case 'allexcelfiles',   allexcelfiles= varargin{ni+1};
            case 'xlsname',         xlsname=varargin{ni+1};
            case 'sheetname',       sheetname=varargin{ni+1};
            case 'sdb_numbers',     sdb_numbers=varargin{ni+1};
            case 'gen_numbers',     gen_numbers=varargin{ni+1};
            case 'rn',              RN = varargin{ni+1};
            case 'fn',              FN = varargin{ni+1};
        end
    end
end

%%%% these are file names for saving

[~,Name,~]=xlsread(fullfile(allexcelfiles,xlsname.name),sheetname);

Name = Name(2:(FN+1),2:(RN+1));

SDB_sam = cell(FN,RN);
Synthetic_sam = cell(FN,RN);
PrimerID_sam = cell(FN,RN);
Genentech_sam = cell(FN,RN);
M13KE_sam = cell(RN,RN);


%%% class into different library types based on sample's name

% For each sample in each row
for i =1:size(Name,1)
    
    % For each sample in each column
    for j=1:size(Name,2)
        
        Sname = Name{i,j}; 
        
        % If there is a sample in that spot, identify it
        if ~isempty(Sname)
            
            pat = '[0-9]+[0-9]+';
            libraryID = regexp(Sname,pat,'match','once');
            primerpat = '[a-z]PI';
            synpat = '[a-z]SI|[a-z][X][ABCDEF]';
            
            if sum(strcmp(cellstr(sdb_numbers),libraryID)) 
                
                SDB_sam{i,j} = Sname;
                
            elseif sum(strcmp(cellstr(gen_numbers),libraryID))
                
                Genentech_sam{i,j} = Sname;
            
            elseif regexp(Sname,primerpat,'match','once')
                
                PrimerID_sam{i,j} = Sname;
            
            elseif regexp(Sname,synpat,'match','once')
                
                Synthetic_sam{i,j} = Sname;
            else
                
                M13KE_sam{i,j} = Sname;
            end
        end
    end
end


Samples = [{SDB_sam}; {Synthetic_sam}; {PrimerID_sam}; {Genentech_sam}; {M13KE_sam}];

X = zeros(size(Samples,1),1);

% For each library type, check if we identified any of that type  
for i =1:size(Samples,1)
    
    % If yes, set the index of that library to the # of sample identified,
    % otherwise, set it to 0.
    X(i,1) = sum(sum(~cellfun(@isempty,Samples{i})));
                
end

end



