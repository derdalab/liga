# SH-I

print('This file downloads all of CFG data.')
print('That\'s a lot of data. Might take a while.')
print('Press return to continue...')
input()

import urllib.request
import os

id_list = list(range(10000))

prefix = 'http://www.functionalglycomics.org/glycomics/HFileServlet?operation=downloadRawFile&fileType=DAT&sideMenu=no&objId=100'

os.makedirs('all_CFG', exist_ok = True)
print('all_CFG directory created.')

for num in id_list:

    id = str(num).zfill(4)
    url = prefix + id

    try:
        filename = 'primscreen_' + id + '.xls'
        if filename in os.listdir('all_CFG/'):
            print(filename + ' already exists.')
            pass
        else:
            urllib.request.urlretrieve(url, 'all_CFG/' + filename)
            print(filename + ' downloaded.')
    except:
        pass
