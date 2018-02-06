

% --------------------------------------------------------------------
% function to perform logistic regression and compute ROC curve
% --------------------------------------------------------------------


function [OT_d_regridded, OT_d_regridded_daysum] = mf_get_OT_today(OT_rpath, hours_day, lat, lon)



% flags
flags.archive = 1; % 0: Do not archive OT data (i.e. delete files)
                   % 1: Archive OT data (i.e. move files to archive directory)


% --------------------------------------------------------------------
% initialisation
% --------------------------------------------------------------------


% initialise basename of the file
basename = 'NASA_LARC_SEVIRI_OTDETECTION_';


% initialise grid size from original msg images
nlon_msg = 560;
nlat_msg = 672;



% --------------------------------------------------------------------
% manipulations
% --------------------------------------------------------------------


% get time info
now.date_vec = clock;
now.year     = now.date_vec(1);
now.month    = now.date_vec(2);
now.day      = now.date_vec(3);
now.hour     = now.date_vec(4);
now.min      = now.date_vec(5);
now.sec      = now.date_vec(6);
now.dayofyr  = nansum(eomday(now.year, 1:now.month-1)) + now.day;
disp(sprintf(['Time is ' num2str(now.hour, '%02d') ':' num2str(now.min, '%02d') 'h on ' num2str(now.day) '/' num2str(now.month) '/' num2str(now.year) '\n'])) %#ok<*DSPS>


% % % % % TESTING
% % % for ind  = 97:110;
% % % now.dayofyr  = ind;
now.dayofyr  = 036;
now.hour     = 18;
% % % % % TESTING


% check that prediction is made during the richt time of the day
if now.hour < hours_day(end)
    error('myApp:timeofday', ['warnings can only be delivered between  ' num2str(hours_day(end)) 'h and 23.59h UTC'])
end
    

% construct output file directory, name and url
filedir = [num2str(now.year, '%04d') num2str(now.dayofyr, '%03d')];
  

% create archive directory
if flags.archive == 1
    archivedir = ['archive/' filedir];
    mkdir(archivedir);
end


% print status message to screen
disp(sprintf(['downloading OT data from ' OT_rpath]))


% initialise variable
OT_d = 0;


% loop over files
for i=1:length(hours_day);
    for j=[00 15 30 45]
                

        % construct output file name and url
        filename = [basename num2str(now.year, '%04d') num2str(now.dayofyr, '%03d') '.' num2str(hours_day(i), '%02d') num2str(j, '%02d') '.nc'];
        url      = [OT_rpath '/' filedir '/' filename];

        
        % download OT data from remote path only if file is there
        [status, ~] = system(['wget -P data/ -N ' url]);

        
        % if dowload was succesful: load and process data
        if status == 0 % download succesful
            
            
            % print status message to screen
            disp(sprintf([filename ' succesfully downloaded']))
            
            
            % fix error with old matlab versions, this should not be used anymore in newer matlab versions
            %mf_fix_netcdf4_dimid(filename);


            % load raw variables
            lat_msg                        =       ncread(filename, 'latitude'                                      ) ;
            lon_msg                        =       ncread(filename, 'longitude'                                     ) ;
            ir_brightness_temperature      = rot90(ncread(filename, 'ir_brightness_temperature'                     ));
            try
                tropopause_temperature         = rot90(ncread(filename, 'tropopause_temperature'                        ));
                ot_anvilmean_brightn_temp_diff = rot90(ncread(filename, 'ot_anvilmean_brightness_temperature_difference'));
            catch errmessage %#ok<*NASGU>
                disp('failed to load all required variables; assume no OTs were detected on this image')
                tropopause_temperature         = NaN(size(ir_brightness_temperature));
                ot_anvilmean_brightn_temp_diff = NaN(size(ir_brightness_temperature));
            end

            
            % detect OT from raw variables, by looking for pixels meeting each of the following 3 conditions: 
            cond1    = ir_brightness_temperature                          <  217.5; % colder than 217.5 K (ir_brightness_temperature in NetCDF file) 
            cond2    = ir_brightness_temperature - tropopause_temperature <= 5;     % ir_brightness_temperature up to 5 K warmer than the tropopause temperature (tropopause_temperature in NetCDF file)
            cond3    = ot_anvilmean_brightn_temp_diff                     >= 6;     % ir_brightness_temperature 6 K or more colder than the anvil (ot_anvilmean_brightness_temperature_difference in NetCDF file)
            OT_15min = cond1 .* cond2 .* cond3;

        
        % if dowload was NOT succesful: assume no OTs were detected
        else % dowload unsuccesful
            
            
            disp(sprintf(['failed to download ' filename '; assume no OTs were detected']))
            OT_15min = zeros(nlat_msg, nlon_msg); 
            
            
        end
   
        
        % aggregate all OT
        OT_d = OT_d + OT_15min;
        
        
%         % archive or delete OT data
%         if     flags.archive == 0
%             delete(filename);                 % delete file
%         elseif flags.archive == 1
%             movefile(filename,archivedir,'f') % copy file
%         end

        
    end

end


% debugging        
% figure;imagesc(OT_d);colorbar        
% debugging        


% print white line to the screen
disp(sprintf('\n'))


% brute-force regridding:
[nlat, nlon]   = size(lat);
OT_d_regridded = zeros(nlat, nlon);
res_lat        = abs( lat(2,1) - lat(1,1) );
res_lon        = abs( lon(1,2) - lon(1,1) );


% loop over pixels in the new coarse grid
for i=1:nlat
    for j=1:nlon
        
        % get the corresponding pixels in the fine grid
        rows_msg = find(lat_msg >= lat(i,1)-res_lat/2 & lat_msg < lat(i,1)+res_lat/2);
        cols_msg = find(lon_msg >= lon(1,j)-res_lon/2 & lon_msg < lon(1,j)+res_lon/2);
        
        % sum them, and assign the coarse pixel this value
        OT_d_regridded(i,j) = nansum(nansum(OT_d(rows_msg, cols_msg)));
        
    end
end


% % % % debugging        
% % % figure;imagesc(OT_d_regridded);colorbar; caxis([0 200]);        
% % % OT_d_regridded_daysum(ind) = nansum(nansum(OT_d_regridded));
OT_d_regridded_daysum = NaN;
% % % % debugging        

% % % end


end
