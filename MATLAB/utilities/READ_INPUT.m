function INPUT = READ_INPUT(filename)
    
    % Open the file
    fid = fopen(['input/', filename], 'r');
    if fid == -1
        error('Cannot open file: %s', filename);
    end

    % Read the entire file content
    file_content = fread(fid, '*char')';
    fclose(fid);

    % Initialize INPUT structure
    INPUT = struct();
    INPUT.MODE      = '';
    INPUT.MODEL     = struct('NAME', '', 'L', '', 'W', '', 'thick', '', 'alpha', '', 'k', '');
    INPUT.BC        = struct('T_0', '', 'conditions', {{}});
    INPUT.SETTINGS  = struct('simT', '', 'dt', '', 'dL', '', 'dW', '', 'opt', '');

    
    % Define patterns to match each section
    patterns = struct();
    patterns.mode     = 'MODE\s+(\w+)';
    patterns.name     = 'NAME\s+(\w+)';
    patterns.length   = 'L\s+([\d.]+)';
    patterns.width    = 'W\s+([\d.]+)';
    patterns.thick    = 'thick\s+([\d.]+)';
    patterns.alpha    = 'alpha\s+([+-]?(\d+(\.\d*)?|\.\d+)([eE][+-]?\d+)?)';
    patterns.k        = 'k\s+([+-]?(\d+(\.\d*)?|\.\d+)([eE][+-]?\d+)?)';

    patterns.T_init   = 'T_0\s+([\d.]+)';
    patterns.bc       = 'BC\d+\s+\[([^\]]+)\]'; % Pattern to match BC entries within square brackets
    
    patterns.simT     = 'simT\s+([\d.]+)';
    patterns.dt       = 'dt\s+([\d.]+)';
    patterns.dL       = 'dL\s+([\d.]+)';
    patterns.dW       = 'dW\s+([\d.]+)';
    patterns.option   = 'option\s+''(\w+)''';
            
            


    % Match and extract each section using regular expressions
    INPUT.MODE         = regexp(file_content, patterns.mode, 'tokens', 'once');
    INPUT.MODEL.NAME   = regexp(file_content, patterns.name, 'tokens', 'once');
    L_matches          = regexp(file_content, patterns.length, 'tokens', 'once');
    W_matches          = regexp(file_content, patterns.width, 'tokens', 'once');
    thick_matches      = regexp(file_content, patterns.thick, 'tokens', 'once');
    alpha_matches      = regexp(file_content, patterns.alpha, 'tokens', 'once');
    k_matches          = regexp(file_content, patterns.k, 'tokens', 'once');

    Tinit_matches      = regexp(file_content, patterns.T_init, 'tokens', 'once');
    bc_matches         = regexp(file_content, patterns.bc, 'tokens');

    time_matches       = regexp(file_content, patterns.simT, 'tokens', 'once');
    dt_matches         = regexp(file_content, patterns.dt, 'tokens', 'once');
    dL_matches         = regexp(file_content, patterns.dL, 'tokens', 'once');
    dW_matches         = regexp(file_content, patterns.dW, 'tokens', 'once');
    option_matches     = regexp(file_content, patterns.option, 'tokens', 'once');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Convert single-element cells to strings
    if ~isempty(INPUT.MODE)
        INPUT.MODE = INPUT.MODE{1};
    end
    if ~isempty(INPUT.MODEL.NAME)
        INPUT.MODEL.NAME = INPUT.MODEL.NAME{1};
    end

    % Define ENV input
    if ~isempty(L_matches)
        INPUT.MODEL.L = str2double(L_matches{1});
    end
    if ~isempty(W_matches)
        INPUT.MODEL.W = str2double(W_matches{1});
    end
    if ~isempty(thick_matches)
        INPUT.MODEL.thick = str2double(thick_matches{1});
    end
    if ~isempty(alpha_matches)
        INPUT.MODEL.alpha = str2double(alpha_matches{1});
    end
    if ~isempty(k_matches)
        INPUT.MODEL.k = str2double(k_matches{1});
    end


    if ~isempty(Tinit_matches)
        INPUT.BC.T_0 = str2double(Tinit_matches{1});
    end
    % Process BC matches and store them in the INPUT structure
    if ~isempty(bc_matches)
        bc_conditions = cell(length(bc_matches), 1);
        for i = 1:length(bc_matches)
            bc_value = str2num(bc_matches{i}{1}); %#ok<ST2NM>
            bc_conditions{i} = bc_value;
        end
        INPUT.BC.conditions = bc_conditions;
    end


    if ~isempty(time_matches)
        INPUT.SETTINGS.simT = str2double(time_matches{1});
    end
    if ~isempty(dt_matches)
        INPUT.SETTINGS.dt = str2double(dt_matches{1});
    end
    if ~isempty(dL_matches)
        INPUT.SETTINGS.dL = str2double(dL_matches{1});
    end
    if ~isempty(dW_matches)
        INPUT.SETTINGS.dW = str2double(dW_matches{1});
    end

    if strcmp(option_matches, 'instant')
        if ~isempty(option_matches)
            INPUT.SETTINGS.opt = 0;
        end
    else
        INPUT.SETTINGS.opt = 1;
    end
    

    structdisp(INPUT);
    
end


