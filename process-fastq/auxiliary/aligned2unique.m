function [Num_M0, Num_mapped, Num_unique] =  aligned2unique(varargin)
% this function reads the aligned reads in chunks
% of 500,000 lines (or other) and converts them to a list of unique reads
% The function needs to know how to handle the mismatched reads (ignore
% globally, ignore locally, fix using a set of rules)
% The function needs to know the structure of the library, which is
% supplied in the LIB structure
% The function also decides how to handle mistakes in the extra-library
% regions (no mistakes allowed, point mutatants are allowed, other)


chunk = 10000; % if not defined, it will be 10000

    if exist('varargin','var')
        L = length(varargin);
        if rem(L,2) ~= 0 
            error('Parameters/Values must come in pairs.'); 
        end

        % read input variables
        for ni = 1:2:L
            switch lower(varargin{ni})
                case 'unidir',          uniDir = varargin{ni+1};
                case 'parsedir',        parseDir = varargin{ni+1};
                case 'indir',           indir=varargin{ni+1};
                case 'barcodes',        B=varargin{ni+1}; 
                case 'library',         LIB=varargin{ni+1}; 
                case 'adaptermatch',    kind=varargin{ni+1}; 
                case 'files',           files=varargin{ni+1}; 
                case 'chunk',           chunk=varargin{ni+1}; 
                case 'newline',         newline=varargin{ni+1}; 
                case 'samplenames',     samplenames=varargin{ni+1};
                case 'm0',              Num_M0 = varargin{ni+1};
                case 'mapped',          Num_mapped= varargin{ni+1};
                case 'unique',          Num_unique = varargin{ni+1};
                
            end
        end
    end

    
    if strcmp(files,'all')
        NucName = dir(fullfile(indir,'R*'));
    else
        NucName = dir(fullfile(indir,[files '*']));
    end

    if ~isdir(uniDir),   mkdir(uniDir);   end
    if ~isdir(parseDir), mkdir(parseDir); end
    
    
    
    Name = samplenames;
    
    for F=1:size(Name,1)
            
         for R=1:size(Name,2)

             if isempty(Name{F,R}), continue;
                
                % find location of the F-R-combination in the file
             else 
                 outname1 = ['R' num2str(R) 'F' num2str(F)];
                 outname2 = Name{F,R};
                   
                 for i=1:numel(NucName)
        
                        %extract the number of forward and reverse barcodes from the name
                      expr = [files(1:8) '-R(?<RB>\d+)F(?<FB>\d+)'];
                      
                     %% modified by jessica
                      expr1 = 'R(?<RB>\d+)F(?<FB>\d+)';
                      if (~isempty(strfind(NucName(i).name, outname1)) && strcmp(outname1, regexp(NucName(i).name,expr1,'match')))
                      
                          A=regexp(NucName(i).name, expr, 'names');
                          FB = B.FB{str2num(A.FB)};
                          RB = B.RB{str2num(A.RB)};

                          [Num_M0,Num_mapped,Num_unique] = alignONEseq(indir, ...
                                      parseDir, uniDir, NucName(i).name,...
                                      LIB, FB, RB, kind, chunk, newline,...
                                      outname2, Num_M0, ...
                                      Num_mapped, Num_unique,...
                                      str2num(A.FB),str2num(A.RB));
                          break;
                      end
                     
                 end
             end
         end
    end
    
end