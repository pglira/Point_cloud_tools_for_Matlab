function plot_saveColors(hFig)

colors = get(groot, 'DefaultAxesColorOrder'); % https://de.mathworks.com/matlabcentral/answers/160332-rgb-values-for-2014b-default-colors

hFig.UserData.colors = {colors(1,:)   'darkblue'   'db' % first column: rgb values; second column: color name; third column: short color name
                        colors(2,:)   'orange'     'o'
                        colors(3,:)   'darkyellow' 'dy'
                        colors(4,:)   'purple'     'p'
                        colors(5,:)   'lightgreen' 'lg'
                        colors(6,:)   'lightblue'  'lb'
                        colors(7,:)   'darkred'    'dr'
                        [1 1 0]       'yellow'	   'y'  % standard colors
                        [1 0 1]       'magenta'	   'm'	
                        [0 1 1]       'cyan'	   'c'	  
                        [1 0 0]       'red'	       'r'	    
                        [0 1 0]       'green'	   'g'	  
                        [0 0 1]       'blue'	   'b'	  
                        [1 1 1]       'white'	   'w'	  
                        [0 0 0]       'black'	   'k'
                        [0.3 0.3 0.3] 'darkgray'   'dgy'
                        [0.5 0.5 0.5] 'gray'       'gy'
                        [0.7 0.7 0.7] 'ligthgray'  'lgy'};
                        
end