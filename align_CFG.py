# SH-I

import os
import seaborn as sns
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

def check_form(path):
    data = pd.read_excel(path)
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

lectins = ['ACG', 'CTB', 'DC_SIGN', 'Gal4', 'LCA', 'MAL', 'NPL', 'PSA', 'SBA', 'SNL', 'UEA']

for lectin in lectins:

    path = 'CFG_data/' + lectin + '/'

    file = pd.read_csv('format/' + 'ancient.csv')
    for fn in sorted(os.listdir(path)):
        try:
            if check_form(path+fn) == 'ancient':
                data = pd.read_excel(path+fn, header=1, nrows=466)
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
    file.to_csv(lectin + '/ancient.csv', index=False)

    file = pd.read_csv('format/' + 'old.csv')
    for fn in sorted(os.listdir(path)):
        try:
            if check_form(path+fn) == 'old':
                data = pd.read_excel(path+fn)
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
    file.to_csv(lectin + '/old.csv', index=False)

    file = pd.read_csv('format/' + 'new.csv')
    for fn in sorted(os.listdir(path)):
        try:
            if check_form(path+fn) == 'new':
                data = pd.read_excel(path+fn)
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
    file.to_csv(lectin + '/new.csv', index=False)

    ancient = pd.read_csv(lectin + '/ancient.csv', skiprows = [1])
    old = pd.read_csv(lectin + '/old.csv', skiprows = [1])
    new = pd.read_csv(lectin + '/new.csv', skiprows = [1])

    order = pd.read_excel('order.xlsx')

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

    order.to_csv(lectin+'_all.csv', index=False)

    data = pd.read_csv(lectin + '_all.csv')
    val = data.iloc[:, 3:]

    for col_name in val.columns:

        arr = val[col_name].values
        arr_n = norm(arr)
        val[col_name] = arr_n

    val = val.T
    val = val.set_index(val.index.map(lambda x: x.split(' Alexa')[0]))

    n = len(val.index) / 3
    plt.figure(figsize = (30,n))
    sns.heatmap(val, cmap='Blues')
    plt.xlabel('Glycans')
    plt.ylabel('Lectins')
    plt.savefig(lectin+'_heat.pdf', bbox_inches = 'tight')

    print(lectin + ' made.')
