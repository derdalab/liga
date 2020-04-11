# SH-I

import sys, os
import pandas as pd
import numpy as np

terms = pd.read_csv('terms.csv')['terms']
term_str = ', '.join(list(terms))
print('Terms from terms.csv: ' + term_str)

def check_form(path):
    block()
    data = pd.read_excel(path)
    enable()
    if data.iloc[1, 1] == 'Glycan Structure':
        return 'ancient'
    elif data.iloc[1, 1] == 'Structure':
        return 'old'
    elif 'Structure on Masterlist' in data.columns:
        return 'new'
    else:
        return 'unknown'

def norm(arr):

    arr = np.ma.array(arr, mask=np.isnan(arr))

    p = (arr - arr.min())
    q = arr.max() - arr.min()

    return (p / q).data

def block():
    sys.stdout = open(os.devnull, 'w')

def enable():
    sys.stdout = sys.__stdout__

for lectin in terms:

    print('')
    print('Working on ' + lectin + '...')

    path = './' + lectin + '/'

    file = pd.read_csv('format/' + 'ancient.csv')
    for fn in sorted(os.listdir(path)):
        try:
            if check_form(path+fn) == 'ancient':
                print('Extracting data from ' + fn + '.')
                block()
                data = pd.read_excel(path+fn, header=1, nrows=466)
                enable()
                psid = fn.split('.')[0]
                try:
                    title = data.columns[26] if data.columns[26] != 'Unnamed: 26' else data.columns[27]
                except:
                    title = psid
                values = list(data.iloc[1:, 2])
                col = [psid] + values
                try:
                    file[title] = col
                except:
                    pass
        except:
            pass
    file.to_csv('temp/ancient.csv', index=False)

    file = pd.read_csv('format/' + 'old.csv')
    for fn in sorted(os.listdir(path)):
        try:
            if check_form(path+fn) == 'old':
                print('Extracting data from ' + fn + '.')
                block()
                data = pd.read_excel(path+fn)
                enable()
                psid = fn.split('.')[0]
                title = data.columns[7]
                values = list(data.iloc[0:, 2])
                col = [psid] + values
                try:
                    file[title] = col
                except:
                    pass
        except:
            pass
    file.to_csv('temp/old.csv', index=False)

    file = pd.read_csv('format/' + 'new.csv')
    for fn in sorted(os.listdir(path)):
        try:
            if check_form(path+fn) == 'new':
                print('Extracting data from ' + fn + '.')
                block()
                data = pd.read_excel(path+fn)
                enable()
                psid = fn.split('.')[0]
                title = data.columns[7]
                values = list(data.iloc[0:, 2])
                col = [psid] + values
                try:
                    file[title] = col
                except:
                    pass
        except:
            pass
    file.to_csv('temp/new.csv', index=False)

    ancient = pd.read_csv('temp/ancient.csv', skiprows = [1])
    old = pd.read_csv('temp/old.csv', skiprows = [1])
    new = pd.read_csv('temp/new.csv', skiprows = [1])

    print('Extracion complete.')

    order = pd.read_excel('format/order.xlsx')

    order = pd.merge(order, new,
                 left_on='new',
                 right_on='Title',
                 how='left')
    del order['Title']

    order = pd.merge(order, old,
                 left_on='old',
                 right_on='Title',
                 how='left')
    del order['Title']

    order = pd.merge(order, ancient,
                 left_on='ancient',
                 right_on='Title',
                 how='left')
    del order['Title']

    order.to_csv(lectin + '.csv', index=False)

    print(lectin + '.csv created.')
