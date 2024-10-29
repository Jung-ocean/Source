import cdsapi
import datetime
import os

yyyy=int(os.environ['yyyy'])
im=int(os.environ['mm'])

days =  [
  '01', '02', '03',
  '04', '05', '06',
  '07', '08', '09',
  '10', '11', '12',
  '13', '14', '15',
  '16', '17', '18',
  '19', '20', '21',
  '22', '23', '24',
  '25', '26', '27',
  '28', '29', '30',
  '31',
]

start_day = datetime.date(yyyy,im,1)
year_inc = int((im)/12)
end_day = datetime.date( yyyy+year_inc, im%12+1, 1)
num_days = (end_day-start_day).days

filename_East=\
('/data/jungjih/Models/GloFAS/'
+ start_day.strftime("%Y") + '//' + 'BSf_GloFas'
+ start_day.strftime("_%Y_%m_E") + '.grib')

filename_West=\
('/data/jungjih/Models/GloFAS/'
+ start_day.strftime("%Y") + '//' + 'BSf_GloFas'
+ start_day.strftime("_%Y_%m_W") + '.grib' )

c = cdsapi.Client()

c.retrieve(
    'cems-glofas-historical',
    {
      'system_version': 'version_4_0',
      'variable': 'river_discharge_in_the_last_24_hours',
      'data_format': 'grib',
      'download_format': 'unarchived',
      'hyear': start_day.strftime("%Y"),
      'hmonth': start_day.strftime("%m"),
      'hydrological_model': 'lisflood',
      'product_type': 'consolidated',
      'hday': days[0:num_days], 
      'area': [
      68, -180, 46,
      -154,
      ],
    },
    (filename_East))

c.retrieve(
    'cems-glofas-historical',
    {
      'system_version': 'version_4_0',
      'variable': 'river_discharge_in_the_last_24_hours',
      'data_format': 'grib',
      'download_format': 'unarchived',
      'hyear': start_day.strftime("%Y"),
      'hmonth': start_day.strftime("%m"),
      'hydrological_model': 'lisflood',
      'product_type': 'consolidated',
      'hday': days[0:num_days], 
      'area': [
      68, 150, 46,
      180,
      ],
    },
    (filename_West))

