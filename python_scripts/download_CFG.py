# SH-I

import os
import pandas as pd
from urllib.request import urlopen
from urllib.request import urlretrieve

terms = pd.read_csv('terms.csv')['terms']
term_str = ', '.join(list(terms))
print('Terms from terms.csv: ' + term_str)

def primscreen(term):

    html = urlopen('http://www.functionalglycomics.org/glycomics/search/jsp/result.jsp?query=' + term)
    page = str(html.read())
    page_list = page.split('/glycomics/HServlet?operation=view&sideMenu=no&psId=')
    psid_list = [i.split('"')[0] for i in page_list[1:]]

    return psid_list

def download(psid, term):
    if psid + '.xls' in os.listdir('./' + term):
        print(psid + ' already exists.')
        pass
    else:
        html = urlopen('http://www.functionalglycomics.org/glycomics/HServlet?operation=view&sideMenu=no&psId=' + psid)
        page = str(html.read())
        link = page.split('\\\')">Download</a></td>')[0].split('href="javascript:openWindow(\\\'')[-1]
        urlretrieve(link, './' + term + '/' + psid + '.xls')
        print(psid + ' downloaded.')

for term in terms:
    os.makedirs(term, exist_ok = True)
    print('')
    print('Searching for ' + term + '...')
    try:
        psids = primscreen(term)
    except:
        print('Search failed. Please try again.')
    print(str(len(psids)) + ' files found for ' + term + '.')
    if len(psids) == 0:
        pass
    else:
        print('')
        print('Downloading...')
        for psid in psids:
            try:
                download(psid, term)
            except:
                pass
