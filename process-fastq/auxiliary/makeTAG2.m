function [TAGout] = makeTAG2(Fnuc, Rnuc, matches, mismatches, tiles, mismatch_cutoff)
% this function takes a array of tiles and mismatches and creates a cell
% array of TAGs 


% create an array of TAGs by serial matrix multiplication
    TAG= BLOCK( ['>L{}M{ }',char(32*ones(1,(2*4+3)))],  size(Fnuc,1) );  % default tag
    
    TAG((mismatches == 0),7) = '0';
    
    TAG((mismatches>mismatch_cutoff),7) = '*';
    
% find reads with 1 to 4 mismatches    
    mis_idx = find(mismatches >0 & mismatches <=4);
    
% locate the positions of mismatches 
    for i = 1:size(mis_idx,1)
        
        mis_idx_tmp = mis_idx(i);
        
        tile_tmp = tiles(mis_idx_tmp); 
        
        if(tile_tmp<0)
            F_tmp = Fnuc(mis_idx_tmp,1:(size(Fnuc,2)+tile_tmp));
            R_tmp = Rnuc(mis_idx_tmp,(abs(tile_tmp)+1):end);
            
        elseif(tile_tmp>0)
            F_tmp = Fnuc(mis_idx_tmp,(abs(tile_tmp)+1):end);
            R_tmp = Rnuc(mis_idx_tmp,1:(size(Rnuc,2)-tile_tmp));
            
        else
            F_tmp = Fnuc(mis_idx_tmp,:);
            R_tmp = Rnuc(mis_idx_tmp,:);
        end
        ex_id = F_tmp == '~' | R_tmp == '~';
        
        F_tmp(ex_id) = [];
        
        R_tmp(ex_id) = [];
        
        mis_loc = find(F_tmp ~= R_tmp);
        
        mis_loc_str = sprintf('%d,',mis_loc);
        
        mis_loc_str(end) = [];

        mis_loc_str = [mis_loc_str,'}',char(32*ones(1,2*4+3-size(mis_loc_str,2)))];
        
        try
        TAG(mis_idx_tmp,:) = [TAG(mis_idx_tmp,1:7),mis_loc_str];
        catch
        disp(mis_idx_tmp);
        disp(Fnuc(mis_idx_tmp,:));
        disp(Rnuc(mis_idx_tmp,:));
        disp(tiles(mis_idx_tmp,:));
        disp(TAG(mis_idx_tmp,:));
          disp(size(TAG,2));
            disp(mis_loc_str);
              disp(size(mis_loc_str,2));
        end
    end
    
    % calculate the initial number of ~ in each line
    aF = F_find_wave_num(Fnuc,0);
    bF = F_find_wave_num(Fnuc,1);
    aR = F_find_wave_num(Rnuc,0);
    bR = F_find_wave_num(Rnuc,1);
    
    % calculate the number of '~' on the left of the read
    try
    numbers(:,1) = abs(tiles)+double(tiles>0).*aR + double(tiles<0).*aF;
    catch
        disp('error');
    end
    
    % calculate the number of nuc. in the middle 
    numbers(:,2) = matches+mismatches;
    
    % calculate the number of '~' on the right of the read
    numbers(:,3) = abs(tiles)+double(tiles>0).*bF + double(tiles<0).*bR;
    
    COMMA = char ( double(',')*ones(size(Fnuc,1),1) ) ;

    % faster alternative to num2str(Fr)
    cFr =[];
    for i=1:3
        temp = textscan( sprintf('%d\n', numbers(:,i) ), '%s' );
        cFr = [cFr char(temp{1}) COMMA];
    end
    
    TAGout = [TAG(:,1:3) cFr(:,1:end-1) TAG(:,4:end)];

end



function wave_num = F_find_wave_num(nuc,loc)

nuc_multi_flag = ones(size(nuc,1),1);
wave_num = zeros(size(nuc,1),1);
if(loc == 1)
    nuc = fliplr(nuc);
end

for i = 1:size(nuc,2)
    nuc_multi_flag = nuc_multi_flag.*double(nuc(:,i) == '~');
    wave_num = wave_num+ nuc_multi_flag;
    if(sum(nuc_multi_flag) == 0)
        break
    end
end
end

function [TAG]=BLOCK(tag,N)
% convert string to a block of identical strings repeated N times        
    TAG=ones( N, numel(tag) );

    for ii=1:numel(tag)           
        TAG(:,ii) = TAG(:,ii)*double( tag(ii) );
    end

    TAG = char(TAG);
        
end