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
    INPUT.MODEL     = struct('NAME', '', 'L', '', 'W', '', 'alpha', '');
    INPUT.BC        = struct('T_init', '', 'conditions', {{}});
    INPUT.SETTINGS  = struct('simT', '', 'dt', '', 'dL', '', 'dW', '', 'option', '');

    
    % Define patterns to match each section
    patterns = struct();
    patterns.mode     = 'MODE\s+(\w+)';
    patterns.name     = 'NAME\s+(\w+)';
    patterns.length   = 'L\s+([\d.]+)';
    patterns.width    = 'W\s+([\d.]+)';
    patterns.alpha    = 'alpha\s+([+-]?(\d+(\.\d*)?|\.\d+)([eE][+-]?\d+)?)';

    patterns.T_init   = 'T_init\s+([\d.]+)';
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
    alpha_matches      = regexp(file_content, patterns.alpha, 'tokens', 'once');

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
    if ~isempty(alpha_matches)
        INPUT.MODEL.alpha = str2double(alpha_matches{1});
    end


    if ~isempty(Tinit_matches)
        INPUT.BC.T_init = str2double(Tinit_matches{1});
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
            INPUT.SETTINGS.option = 1;
        end
    else
        if ~isempty(option_matches)
            INPUT.SETTINGS.option = 0;
        end
    end
    


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%     if strcmp(INPUT.MODE, 'simulation')
%             INPUT.VALUE     = struct('DESIGN_opt', '', 'FRAME', '', 'QUAT_DESIGN', [], 'QUAT_SINGLE', [], 'QUAT_PROF', []);

%             patterns.design_opt = 'DESIGN\s+(\w+)';
%             design_opt_matches  = regexp(file_content, patterns.design_opt, 'tokens', 'once');
            
%             if ~isempty(design_opt_matches)
%                 INPUT.VALUE.DESIGN_opt = str2double(design_opt_matches{1});
%             end

%             if INPUT.VALUE.DESIGN_opt == 0
%                 patterns.quat_sin   = 'QUAT_SINGLE\s+\[(.*?)\]';
%                 patterns.quat_prof  = 'QUAT_PROF\s+''(.*?)''';
                
%                 quat_sin_matches    = regexp(file_content, patterns.quat_sin, 'tokens', 'once');
%                 quat_prof_matches   = regexp(file_content, patterns.quat_prof, 'tokens', 'once');
    
%                 if ~isempty(quat_sin_matches)
%                     INPUT.VALUE.QUAT_SINGLE = str2num(quat_sin_matches{1});
%                 end

%                 if ~isempty(quat_prof_matches)
%                     data_file = quat_prof_matches{1};
%                     [~, INPUT.VALUE.QUAT_PROF] = import(data_file, '%f%f%f%f');
%                 end

%             elseif INPUT.VALUE.DESIGN_opt == 1
%                 patterns.frame      = 'FRAME\s+''(\w+)''';
%                 patterns.quat_des   = 'QUAT_DESIGN\s+\[(.*?)\]';
                
%                 frame_matches       = regexp(file_content, patterns.frame, 'tokens', 'once');
%                 quat_des_matches    = regexp(file_content, patterns.quat_des, 'tokens', 'once');

%                 if ~isempty(quat_des_matches)
%                     INPUT.VALUE.QUAT_DESIGN = str2num(quat_des_matches{1});
%                 end
%                 if ~isempty(frame_matches)
%                     INPUT.VALUE.FRAME = frame_matches{1};
%                 end

%             else
%                 fprintf('%s\n', 'INVALID DESIGN OPTION')
%             end

         

%     elseif strcmp(INPUT.MODE, 'propagation')
%             INPUT.TREND     = struct('QUAT', [], 'ECI', [],...
%                                      'LLA', [], 'ECLI', [], 'SUN', []);
            
%             patterns.QUAT       = 'QUAT\s+''(.*?)''';
%             patterns.ECI        = 'ECI\s+''(.*?)''';
%             patterns.LLA        = 'LLA\s+''(.*?)''';
%             patterns.ECLIPSE    = 'ECLIPSE\s+''(.*?)''';
%             patterns.SUN        = 'SUN\s+''(.*?)''';

%             Q_matches           = regexp(file_content, patterns.QUAT, 'tokens', 'once');
%             ECI_matches         = regexp(file_content, patterns.ECI, 'tokens', 'once');
%             LLA_matches         = regexp(file_content, patterns.LLA, 'tokens', 'once');
%             ECLIPSE_matches     = regexp(file_content, patterns.ECLIPSE, 'tokens', 'once');
%             SUN_matches         = regexp(file_content, patterns.SUN, 'tokens', 'once');
            
%             Q_file           = Q_matches{1};
%             [~, temp]        = import(Q_file, '%s%f%f%f%f');
%             INPUT.TREND.QUAT = temp(2:16:89*16,1:4);
            
%             ECI_file = ECI_matches{1};
%             [~, INPUT.TREND.ECI] = import(ECI_file, '%s%f%f%f%f');
            
%             LLA_file = LLA_matches{1};
%             [INPUT.TREND.DATE, INPUT.TREND.LLA] = import(LLA_file, '%s%f%f');
            
%             ECLIPSE_file = ECLIPSE_matches{1};
%             [~, INPUT.TREND.ECLI] = import(ECLIPSE_file, '%s%f');
            
%             SUN_FILE = SUN_matches{1};
%             [~, INPUT.TREND.SUN] = import(SUN_FILE, '%s%f%f%f');

%     end

    

end


