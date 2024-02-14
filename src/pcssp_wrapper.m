classdef pcssp_wrapper < SCDDSclass_wrapper
  % superclass for SCDDSdemo wrapper
  %
  %
  % [ SCDDS - Simulink Control Development & Deployment Suite ] Copyright SPC-EPFL Lausanne 2022.
  % Distributed under the terms of the GNU Lesser General Public License, LGPL-3.0-only.
  
  methods
      
      % class constructor
      function obj = pcssp_wrapper(name,dt)
          if nargin<2, dt=1e-3; end % default wrapper period
          obj@SCDDSclass_wrapper(name,dt)
          obj.createdd = true;
          
      end
  
      function build(obj)
          % set configuration to gcc
          sourcedd = 'configurations_container_RTF.sldd';
          SCDconf_setConf('configurationSettingsRTFcpp',sourcedd);
          % build
          build@SCDDSclass_wrapper(obj); % call superclass method       
          
      end


      function compile(obj)
         try
           eval(sprintf('%s([],[],[],''compile'')',obj.name));
         catch ME
             try
                eval(sprintf('%s([],[],[],''term'')',obj.name)); % terminate if necessary
             catch
                rethrow(ME); % rethrow error so we can see it
             end
         end
         eval(sprintf('%s([],[],[],''term'')',obj.name)); % terminate is successful
      end


      function test_harness(obj)
         harnessname = sprintf('%s_harness_run',obj.name);
         if ~exist(harnessname,'file')
           warning('no harness %s found, skipping test',harnessname);
           return
         else
           fprintf('running test harness %s\n',harnessname);

           % link sldd to harness model (for buses etc?)
           harnessmdl = [obj.name '_harness'];
           load_system(harnessmdl);
           set_param(harnessmdl,'DataDictionary',obj.ddname);
           run(sprintf('%s(obj)',harnessname)); % run script with name <wrapper_name>_harness_run.m
         end
                  
       end
      
  end
  
  
end