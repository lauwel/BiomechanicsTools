function compareStruct(struct1,struct2) 
% 
% Compare two structures to see if they have the same fields, and if the
% fields themselves are different. Will display differences, and then show
% the differences.
% ----------------------------INPUT VARIABLES------------------------------
% 
%  struct1             = first structure to compare
%  struct2             =  second structure to compare
%               =
% 
% ----------------------------OUTPUT VARIABLES-----------------------------
% 
%               =
%               = 
%               =
% 
% -------------------------------HISTORY-----------------------------------
% 
% Created 21-Dec-2021 by L. Welte (github.com/lauwel)
% -------------------------------------------------------------------------

fields1 = fields(struct1);
fields2 = fields(struct2);

if length(fields1) >= length(fields2)
    nFields = length(fields1);
else % fields 1 needs to be the longest
    nFields = length(fields2);
    fields_temp = fields1;
    fields1 = fields2;
    fields2 = fields_temp;    
end

for f = 1:nFields
    IsameFields(f,:) = strcmp(fields1{f},fields2);
    if ~IsameFields(f,:) % a field is missing in one
        fprintf('Missing field detected: %s\n',fields1{f})
    end
end

list_same_fields = fields1(any(IsameFields')');

for f = 1:length(list_same_fields)
    if isstruct(struct1.(list_same_fields{f})) || isstruct(struct2.(list_same_fields{f}) )
        warning('Undefined behaviour for nested structures.')
        fprintf('in: %s\n',list_same_fields{f})
        continue
    end
    if ~strcmp(class(struct1.(list_same_fields{f})), class(struct2.(list_same_fields{f}))) % if they are different classes
        
        fprintf('Class difference detected: %s\n',list_same_fields{f})
        continue
    else
        switch class(struct1.(list_same_fields{f}))
            case 'string'
                diff_struct = ~strcmp(struct1.(list_same_fields{f}),struct2.(list_same_fields{f}));
            case 'char'
                diff_struct = ~strcmp(struct1.(list_same_fields{f}),struct2.(list_same_fields{f}));
            case 'double'
                
                diff_struct = any((struct1.(list_same_fields{f}) - struct2.(list_same_fields{f})) ~= 0 );
            case 'uint8'
                
                diff_struct = any((struct1.(list_same_fields{f}) - struct2.(list_same_fields{f})) ~= 0 );
            case 'uint16'
                
                diff_struct =any((struct1.(list_same_fields{f}) - struct2.(list_same_fields{f})) ~= 0 );
            case 'cell'
                
                diff_struct = ~strcmp(struct1.(list_same_fields{f}),struct2.(list_same_fields{f}));
        end
        
    end
%     diff_struct = struct1.(list_same_fields{f}) - struct2.(list_same_fields{f}) ;
    if diff_struct 
        
        fprintf('Difference detected: %s\n',list_same_fields{f})
        struct1.(list_same_fields{f})
        struct2.(list_same_fields{f})
    end
end



