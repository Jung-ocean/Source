import cdsapi
import datetime
import os

yyyy=int(os.environ['yyyy'])
mm=int(os.environ['mm'])

target_date = datetime.date(yyyy,mm,1)

filename='/data/jungjih/Models/ERA5/tmp.grib'
#filename=\
#('/data/jungjih/Models/ERA5/monthly/'
#+ 'ERA5_' + target_date.strftime("%Y%m") + '.nc')

c = cdsapi.Client()

c.retrieve(
    'reanalysis-era5-single-levels',
    {
        'product_type': ["reanalysis"],
        'variable': [
            '10m_u_component_of_wind',
            '10m_v_component_of_wind',
        ],
        'year': [target_date.strftime("%Y")],
        'month': [target_date.strftime("%m")],
        "day": [
          "01", "02", "03",
          "04", "05", "06",
          "07", "08", "09",
          "10", "11", "12",
          "13", "14", "15",
          "16", "17", "18",
          "19", "20", "21",
          "22", "23", "24",
          "25", "26", "27",
          "28", "29", "30",
          "31"
        ],
        "time": [
          "00:00", "01:00", "02:00",
          "03:00", "04:00", "05:00",
          "06:00", "07:00", "08:00",
          "09:00", "10:00", "11:00",
          "12:00", "13:00", "14:00",
          "15:00", "16:00", "17:00",
          "18:00", "19:00", "20:00",
          "21:00", "22:00", "23:00"
        ],       
        'data_format': 'grib',
        'download_format': 'unarchived',
        'area': [67, -186, 59, -169]
    },
    (filename))
