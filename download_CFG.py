# SH-I

from urllib.request import urlopen
from urllib.request import urlretrieve

import os

term = input('Enter search term: ')

def primscreen(term):

    html = urlopen('http://www.functionalglycomics.org/glycomics/search/jsp/result.jsp?query=' + term)
    page = str(html.read())
    page_list = page.split('/glycomics/HServlet?operation=view&sideMenu=no&psId=')
    psid_list = [i.split('"')[0] for i in page_list[1:]]

    return psid_list

def download(psid, term):

    html = urlopen('http://www.functionalglycomics.org/glycomics/HServlet?operation=view&sideMenu=no&psId=' + psid)
    page = str(html.read())
    link = page.split('\\\')">Download</a></td>')[0].split('href="javascript:openWindow(\\\'')[-1]

    os.makedirs(term, exist_ok = True)

    urlretrieve(link, './' + term + '/' + psid + '.xls')

    print(psid + ' downloaded.')

for psid in primscreen(term):

    try:

        download(psid, term)

    except:

        pass
