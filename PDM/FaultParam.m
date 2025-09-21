% 1) Create BusElement objects
be1 = Simulink.BusElement; 
be1.Name = 'EffModFan';
be1.DataType = 'double';

be2 = Simulink.BusElement; 
be2.Name = 'EffModLPC';
be2.DataType = 'double';

be3 = Simulink.BusElement; 
be3.Name = 'N1Scale';
be3.DataType = 'double';

be4 = Simulink.BusElement; 
be4.Name = 'FuelMod';
be4.DataType = 'double';

% 2) Create the bus and assign its elements
FaultParamsBus = Simulink.Bus;
FaultParamsBus.HeaderFile = '';
FaultParamsBus.Description = 'Bus for engine fault parameters';
FaultParamsBus.DataScope = 'Auto';
FaultParamsBus.Alignment = -1;
FaultParamsBus.Elements = [be1; be2; be3; be4];

% 3) Put the bus in the base workspace
assignin('base','FaultParamsBus',FaultParamsBus);

disp('✅ FaultParamsBus created successfully');
