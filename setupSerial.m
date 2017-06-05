function obj=setupSerial()

numPort=inputdlg('Please input serail port of Arduino Uno on your PC : ','Serial port');
comPort=['COM',char(numPort)];

obj=serial(comPort);
obj.InputBufferSize=2048;
obj.BytesAvailableFcnMode = 'byte';
obj.BytesAvailableFcnCount = 256;
obj.BytesAvailableFcn={@Bytes_Available_Function,obj};
obj.BaudRate=115200;
obj.Parity='none';
fopen(obj);

    function Bytes_Available_Function(~,~,serialobj)
        flushinput(serialobj)
    end

end