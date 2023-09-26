classdef pcssp_module < SCDDSclass_algo
    % derived class for PCSSP modules using the SCDDS core framework for model
    % referencing with data dictionaries.
    
    
    methods
        
        function fpstruct = getfpindatadict(obj)
            % TO DO: check use of
            % Simulink.data.evalinGlobal(obj,'paramname') for this
            
            
            if(~isempty(obj.fpinits)) % only try when fixed params are defined
                for ii=1:numel(obj.fpinits) % loop over all FP inits
                    if ~strcmpi(obj.fpinits{ii}{3},'datadictionary')
                        fprintf('fixed params not in datadict, use obj.printinits to check');
                    else
                        % open the main sldd and grab fixed parameters
                        dictionaryObj = Simulink.data.dictionary.open(obj.getdatadictionary);
                        designDataObj = getSection(dictionaryObj, 'Design Data');
                        % append structure
                        

                        name = designDataObj.getEntry(obj.fpinits{ii}{2}{1}).Name;
                        fpstruct.(name) = designDataObj.getEntry(obj.fpinits{ii}{2}{1}).getValue;
                        
                    end
                    
                    
                end
            end
        end
        
        
        
        
        function set_model_argument(obj,param,param_name)
            
            % function to parametrize referenced models via a model mask
            
            % this function takes the Simulink.Parameter or FP struct and its desired
            % mask name as input.
            % It then sticks the param in the model workspace of the 
            % wrapper. If the parameters
            % are already there, the function checks whether they need
            % updating and does so accordingly.
            
            
            % grab model WS
            hws = get_param(obj.modelname, 'modelworkspace');
            
            % grab current model argument names
            model_arg_names = get_param(obj.modelname,'ParameterArgumentNames');
            
            % append string for set_param command later
            if ~isempty(model_arg_names)
                model_arg_string = [model_arg_names,',', param_name];
            else
                model_arg_string = param_name;
            end
              
            % only update param in model workspace when (1) the param is not
            % there or (2) outdated/dirty. The isequaln command is insensitive to
            % ordering within the structures
            
            if ~hws.hasVariable(param_name) % params absent
                
                % Create bus objects in sldd
                %                 dictionaryObj = Simulink.data.dictionary.open(obj.getdatadictionary);
                
                % seems that the bus must live in the base WS. Commented
                % out for now
                %                 businfoTP = Simulink.Bus.createObject(param.Value,[],[],dictionaryObj);
                %                 param.DataType = ['Bus: ' businfoTP.busName];
                
                hws.assignin(param_name, param);
                % set param as model argument
                set_param(obj.modelname,'ParameterArgumentNames',model_arg_string);
                
            elseif hws.hasVariable(param_name) % model WS has a var with the same name
                param_MWS = hws.getVariable(param_name); % param in model WS
                
                assert(strcmpi(class(param_MWS),class(param)),...
                    'class clash of variables in function input vs model Workspace');
                
                if isa(param_MWS,'struct')
                    paramMWS_value = param_MWS;
                    param_value = param;
                elseif isa(param_MWS,'Simulink.Parameter')
                    paramMWS_value = param_MWS.Value;
                    param_value = param.Value;
                else
                    error('parameter %s is not a struct or Simulink.Parameter',param_name)
                    
                end
                
                % update param_MWS with the new param value
                if isequaln(paramMWS_value,param_value)
                        fprintf('variable %s is already up to date, skipping\n',param_name);
                        return
                else
                    hws.assignin(param_name, param);
                    
                    % set param as model argument
                    set_param(obj.modelname,'ParameterArgumentNames',model_arg_string);
                end
                
                
            end
            
        end
        
        
        function build(obj)
            % set configuration to gcc
            sourcedd = 'configurations_container_pcssp.sldd';
            SCDconf_setConf('configurationSettingsRTF',sourcedd);
            % build
            rtwbuild(obj.modelname);
            
        end


        %% RTF helper functions

        function write_RTF_xml(obj)
            % helper function to write XML parameter structure for RTF FBs

            % The RTF XML application-buffer looks for example as follows:

            %  <?xml version="1.0" encoding="UTF-8"?>
            %  <FunctionBlock Name="KMAG" Type="SimulinkBlock">
            %  <Parameter Name="LibraryPath" Value="~/pcssp_KMAG/build/libpcssp.so"/>
            %  <Parameter Name="BlockName" Value="KMAG"/>
            %  <Parameter Name="P" Value="[1,1,1,1,1,1,1,1,1,1]"/>

            % this function uses the matlab writestruct fcn to mimick this
            % XML structure for RTF applications.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % fixed RTF XML type header
            xml_out.NameAttribute = string(obj.getname);
            xml_out.TypeAttribute = "SimulinkBlock"; 
            

            % fill fixed XML parameter fields
            xml_out.Parameter(1).NameAttribute  = "LibraryPath";
            xml_out.Parameter(1).ValueAttribute = join(["~/", string(obj.getname), "/build/"]);
            
            % loop over TPs of pcssp_module to fill XML parameter fields
            for ii=1:numel(obj.exportedtps)
                tp_name = obj.exportedtps{ii};
                tp_val = feval(obj.exportedtpsdefaults{ii});
                xml_out.Parameter(ii).NameAttribute = tp_name;


                if isa(tp_val,'struct')
                    tp_valXML = tp_val;
                elseif isa(tp_val,'Simulink.Parameter')
                    tp_valXML = tp_val.Value;
                else
                    error('parameter %s is not a struct or Simulink.Parameter',tp_name)

                end


                xml_out.Parameter(ii).ValueAttribute = jsonencode(tp_valXML);

                
            end

            writestruct(xml_out,[obj.getname , '_params.xml'], "StructNodeName","FunctionBlock");




        end
        
        
        
    end
    
end