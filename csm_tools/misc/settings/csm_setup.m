% Enter the email address
%answer = inputdlg({'Email Address:'},'Please enter your FULL email (@imperial.ac.uk)',[1 50]);
%csm_settings.setValue('registered_email',answer{1});

% Toolbox folders
uiwait(msgbox('Please select the CSM Toolbox Folder'));
toolbox_path = uigetdir('', 'Please select the CSM Toolbox folder');
uiwait(msgbox('Please select your workspace folder'));
workspace_path = uigetdir('', 'Please select your workspace folder');

csm_settings.setValue('toolbox_path',toolbox_path);
csm_settings.setValue('workspace_path',workspace_path);

% Unit tests
%answer = questdlg('Have you installed the unit tests?');
%if strcmp(answer,'Yes')
 %   uiwait(msgbox('Please select the Unit Test folder'));
 %   unit_test_path = uigetdir('', 'Please select the Unit Test folder');
 %   test_data_path = strcat( unit_test_path, filesep, 'data' );
 %   csm_settings.setValue('unit_test_path',unit_test_path);
 %   csm_settings.setValue('test_data_path',test_data_path);
%end

csm_settings.setValue('collect_stats','off');

csm_settings.loadSettings();

%csm_settings.checkLicence();