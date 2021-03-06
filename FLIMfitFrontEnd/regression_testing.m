function regression_testing(handles)

% Copyright (C) 2013 Imperial College London.
% All rights reserved.
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along
% with this program; if not, write to the Free Software Foundation, Inc.,
% 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
%
% This software tool was developed with support from the UK 
% Engineering and Physical Sciences Council 
% through  a studentship from the Institute of Chemical Biology 
% and The Wellcome Trust through a grant entitled 
% "The Open Microscopy Environment: Image Informatics for Biological Sciences" (Ref: 095931).

% Author : Sean Warren



    test_folder = ['..' filesep 'TestDatasets' filesep];
   
    
    if ~exist(test_folder,'dir') || length(dir(test_folder)) < 4
       test_folder = '\\icfs17.cc.ic.ac.uk\fogim\Group\Software\Global Analysis\TestDatasets\'; 
    end
    
   
    
    % Get Tests
    %----------------------------------------------------
    contents = dir(test_folder);
    contents = contents(3:end);
    tests = {};
    
    for i=1:length(contents)
        if isdir([test_folder contents(i).name])
            tests{end+1} = contents(i).name;
        end
    end
    
    
    % Run Tests
    %----------------------------------------------------
    overall_tests_passed = 0;
    overall_tests_failed = 0;
    
    if ~strcmp(computer('arch'), 'maci64')
      m=memory; 
      m_start = m.MemUsedMATLAB;
    end
    
   
    
    for kk=1:1
    for i=1:1 %2:length(tests)
        
        tests_passed = 0;
        tests_failed = 0;
        
        disp('============================================');
        disp([tests{i}]);
        disp('============================================');
        
        folder = [test_folder tests{i} filesep];
        
        test_def = file2struct([folder 'test_def.txt']);
        test_spec = file_lines([folder 'test_spec.txt']);
        
        if ~isfield(test_def,'channels')
            test_def.channels = [];
        else
            test_def.channels = str2num(test_def.channels);
        end
        
        test_def.polarised = strcmp(test_def.polarised,'true');
        test_def.file = [folder test_def.file];
        
        test_def.file = strrep(test_def.file,'\',filesep);
        test_def.file = strrep(test_def.file,'/',filesep);
        
        if strcmp(test_def.data_series,'true')
            handles.data_series_controller.load_data_series(test_def.file,test_def.mode,test_def.polarised,'','all',test_def.channels);
        else
            handles.data_series_controller.load_single(test_def.file,test_def.polarised,'',test_def.channels);
        end
        
        handles.data_series_controller.data_series.load_data_settings([folder test_def.data_settings_file]);
        handles.fitting_params_controller.load_fitting_params([folder test_def.fit_param_file]);
        
        
        handles.fit_controller.fit();

        while(~handles.fit_controller.has_fit)
            pause(0.1);
        end
        
        f = handles.fit_controller; %#ok
        
        for j=1:length(test_spec)
            
            try
                test_passed = eval(test_spec{j});
            catch
                disp(['[X] Error running test! : ' test_spec{j}]);
                test_passed = false;
            end
            
            if test_passed
                test_result_text = '[*] PASS';
                tests_passed = tests_passed + 1;
                disp([test_result_text ' : ' test_spec{j}]);
            else
                test_result_text = '[X] FAIL';
                tests_failed = tests_failed + 1;
                fprintf(2,[test_result_text ' : ' test_spec{j} '\n']);
            end
            
            
            
        end
        
            
        disp('--------------------------------------------');
        disp(['PASSED ' num2str(tests_passed) '/' num2str(tests_passed+tests_failed)]);
        disp('');
        
        overall_tests_passed = overall_tests_passed + tests_passed;
        overall_tests_failed = overall_tests_failed + tests_failed;
        
         
    end
    
     
      if ~strcmp(computer('arch'), 'maci64')
         m=memory; 
         mem_dif(kk) = m.MemUsedMATLAB - m_start;
      end
    
    end
    
    disp('============================================');
    disp(['OVERALL: PASSED ' num2str(overall_tests_passed) '/' num2str(overall_tests_passed+overall_tests_failed)]);
    disp('============================================');
    
    %figure;
    %plot(mem_dif);
    
    function st = file2struct(file)
       
        fid=fopen(file);
        st = struct();
        
        fline = fgetl(fid);
        while ischar(fline)
             tokens=regexp(fline,'(\S+)\s*=\s*(.*)','tokens');
             if length(tokens) == 1
                 tokens = tokens{1};
                 st.(tokens{1}) = tokens{2};
             end
             fline = fgetl(fid);
        end
        fclose(fid);
        
        
    end

    function lines = file_lines(file)
       
        fid=fopen(file);
        lines = {};
        
        fline = fgetl(fid);
        while ischar(fline)
             lines{end+1} = fline;
             fline = fgetl(fid);
        end
        fclose(fid);
        
    end
        
    
end