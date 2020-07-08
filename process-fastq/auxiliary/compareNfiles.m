function compareNfiles(files,indir,savepath,savename,sortby, TAG)   

    for i=1:numel(files)
        
        if isempty(files{i})
            Pep{i} = {};
            Fre{i} = [];
            continue
        end
       
        fh = fopen ( fullfile(indir,files{i}), 'r+');
        fprintf(['loading ' files{i}]);
        AllVar = textscan(fh,'%s %*s %f %*[^\n]');
        
        %find all the NaN reads and eliminate them
        NaNIX = find(isnan(AllVar{2}));
        if NaNIX
            try
                fprintf([ ' found ' num2str( numel(NaNIX) ) ' NaN'...
                      ' on line ' num2str( NaNIX )]);
            catch
                disp('error');
            end
        end
        
        IX = setdiff(1:1:numel(AllVar{1}),NaNIX);

        Pep{i} = AllVar{1}(IX);
        Fre{i} = AllVar{2}(IX);
        clear AllVar;
        fclose(fh);
        disp('; loaded.');
    
    end
    
    disp(['****** great sucess! loaded all ' num2str(numel(files))...
          ' files ****** ']);
    % step 2, find union of all sequences

    UNI=Pep{1};

    for i=2:numel(Pep)
        temp=UNI;
        UNI = union(temp,Pep{i}); 
        fprintf('.');
    end
    clear temp;
    disp('great sucess! found intersect ');

    % step 3, find frequencies of each union element. If element is not in
    %  the union, the frequency is zero

    UFR=zeros(numel(UNI),numel(files));

    for i=1:numel(Pep)
        [~,IX1,IX2] = intersect(Pep{i},UNI);  
        UFR(IX2,i)=Fre{i}(IX1); 
        fprintf('.');
    end

    disp('great sucess! found frequencies of all files');

    % step 4, sort the table by desired column and save it to file
    if sortby
        [~,IX]=sort(sum(UFR(:,sortby),2),'descend');
    else
        [~,IX]=sort(sum(UFR,2),'descend');
    end
    
    UFR = UFR(IX,:);
    UNI = UNI(IX);
    clear IX*;

    % calculate the SUM and place it on top (later)
    SUM = round(sum(UFR,1)/1000);
    UNI = ['Tag'; 'Total(x1000)'; UNI];  % add two lines on top of the list
    SP  = char(32*ones(size(UNI,1),1));
    cFr = [];
    
    %%%%%%% faster alternative to str2num
    for j=1:size(UFR,2)

        %the script fails if files with specific tags were not identified.
        %when files are not processed but names exist in the table, the tag
        %will be changed to ??? as a cautinary flag.
        %% modified by Jessica
        if isempty(TAG{j}), TAG{j}='NF0'; end
        
        % make a string that contains the tag, total number with "K" and
        % then a list of all frequencies. This is one long continous 
        % string is separated by new line charactes '\n' or char(10)
        % Place a stuffer character AAAAA on top to make sure all columns
        % are at least 5 character wide. Remove it later
        
        
        %% modified by jessica
        if (SUM(j) == 0)
           temp1 = ['AAAAA' char(10)...
                  TAG{j} char(10)...
                  num2str(SUM(j)) 'O' char(10)...
                  sprintf('%d\n', UFR(:,j) )]; 
        else    
            temp1 = ['AAAAA' char(10)...
                    TAG{j} char(10)...
                    num2str(SUM(j)) 'K' char(10)...
                    sprintf('%d\n', UFR(:,j) )];
        end
        
        % convert the long string into a cell array of strings     
        temp2=textscan(temp1, '%s');
        
        if j<size(UFR,2)
          
            cFr=[cFr char(temp2{1}) [SP(1,:); SP] ];
        else
            cFr=[cFr char(temp2{1})];
        end
        fprintf('.');
    end
    cFr = cFr(2:end,:);  % remove the stuffer characters


    cUN = char(UNI);
    AA  = nt2aacell(cUN); 
    
    % to make files readable on Windows, I use \r\n  instead of just \n
    % in ASCII this is char(13) followed by char(10). Th last lines has to
    % have space because othersie you end up with extra carriages and extra
    % blank line at the bottom of your text file
    RET  = char( [ 13*ones(size(UNI,1),1) 10*ones(size(UNI,1),1)] );
    RET(end,:) = char([32 32]);

    toSave=[cUN SP AA SP cFr RET];

    foutid = fopen(fullfile(savepath,savename),'w');
    
    for i = 1: size(toSave,1)
        fprintf( foutid, '%s', toSave(i,:));
    end
    
    fclose all;

    disp(['great sucess!  saved to ' savename]);


end

function [aac,ntc] = nt2aacell(ntc)

  Qfix=1; % true always unless we switch to non-supressing strain

  aalength = size(ntc,2) / 3;
  aac = ntc(:,1:aalength);
  aac(:) = '@';

  map = geneticcode(1);

  for i=1:aalength
      triplets = (ntc(:,(i-1)*3+1:i*3));
      [utr,~,Y] = unique(triplets,'rows');
      for j=1:size(utr,1)
          IX = (Y==j);
          if Qfix && strcmp(utr(j,:),'TAG')
              aac(IX,i) = 'Q';
          else
              try
              aac(IX,i) = map.(utr(j,:));
              catch
                  if strcmp(utr(j,:),'   ')
                      aac(IX,i)=' ';
                  else
                      aac(IX,i)='X';
                  end
              end
          end
      end
  end

  
end