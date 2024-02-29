import cdsapi
import datetime
import os

yyyy=int(os.environ['yyyy'])
mm=int(os.environ['mm'])

target_date = datetime.date(yyyy,mm,1)

filename=\
('/data/jungjih/Models/ERA5/monthly/'
+ 'ERA5_' + target_date.strftime("%Y%m") + '.nc')

c = cdsapi.Client()

c.retrieve(
    'reanalysis-era5-single-levels-monthly-means',
    {
        'product_type': 'monthly_averaged_reanalysis',
        'variable': [
            '10m_u_component_of_wind', '10m_v_component_of_wind', '2m_dewpoint_temperature',
            '2m_temperature', 'mean_sea_level_pressure', 'sea_surface_temperature',
            'total_precipitation',
        ],
        'year': target_date.strftime("%Y"),
        'month': target_date.strftime("%m"),
        'time': '00:00',
        'format': 'netcdf',
    },
    (filename))
