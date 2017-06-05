function auto_manipulations(hObject,~,serialobj,buf_len,freq)
%%
h_fig=findobj('UserData',1);
%h1=findobj('label','New file'); %handle to uimenu object: new file
h2=findobj('UserData',4); %h_speed
h3=findobj('String','rotate'); %rotate
h5=findobj('String','Save'); %save data
h6=findobj('String','STOP'); %stop
h7=findobj('UserData',5); %result
h8=findobj('UserData',7); % line 1
h9=findobj('UserData',8); % line 2
h10=findobj('UserData',9); % variance
h11=findobj('UserData',10); %Material type
h12=findobj('UserData',11); %Initial value

%num_loops=1;
speed_low=30;
interval=30;

n=h11.Value;
material=h11.String(n);

if strcmp(material,'high viscosity material')
    speed_high=150;
else
    speed_high=300;
end

global a;


%flag=0;
tc_data = zeros(1,buf_len);
viscosity_data=zeros(1,buf_len);
serialobj.ReadAsyncMode='continuous';
%h_wait=waitbar(0);

%for j=1:num_loops
   
initial_val=getinitial_value;

for n=speed_low:interval:speed_high
    
    if ~hObject.Value
%         flag=1;
        break;
    end   
    a=1;
    %         pro_1=(j-1)/num_loops;
    %         pro_2=(1/num_loops)*n/speed_high;
    %         str=sprintf('Current Progress : %d%%',(pro_1+pro_2)*100);
    %         disp(str);
    set(h2,'String',num2str(n));
    m=round(60.*freq./n);
    pause(0.1);
    hgfeval(get(h3,'callback')); %begin to ratate
    
    while a
        
%          if ~hObject.Value&&~ishandle(h_fig)
%             break;
%          end
        
        fprintf(serialobj,'%s','d'); %begin to acquire data from serial port
        tc = str2double(fgetl(serialobj))-initial_val;
        [tc_data,viscosity,viscosity_data,var_visco]=updateplot(tc,tc_data,viscosity_data,m,buf_len);
        set(h8,'Ydata',tc_data);
        set(h9,'Ydata',viscosity_data);
        set(h7,'String',num2str(viscosity));
        set(h10,'String',num2str(var_visco));
        drawnow;
        t=timer('ExecutionMode','singleshot','StartDelay',20,'TimerFcn',@update);
        start(t);
    end
    hgfeval(get(h6,'callback')); % stop rotating
    hgfeval(get(h5,'callback')); % save the data
    pause(300); % 5 minutes to cool down the resin
    
end

% if ~hObject.Value||flag==1;
%     break;
% else
%     pause(6); % 10 minutes between 2 different loops
% end

%end
% close(h_wait);

    function update(obj,~)
        %callback function of timer object in outside loops
        fprintf(serialobj,'%s','x');
        %flushinput(serialobj);
        a=0;
        stop(obj);
        delete(obj);
        
    end

    function ini_val=getinitial_value
        fprintf(serialobj,'%s','d');
        pause(2);
        ini_val= str2double(fgetl(serialobj));
        h12.String=num2str(ini_val);
        fprintf(serialobj,'%s','x');
    end

end