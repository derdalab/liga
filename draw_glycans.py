# SH-I

import pandas as pd
import matlab.engine

def draw(glycan, filename):

    try:

        glycan = glycan.replace('GlcNac', 'GlcNAc')
        glycan = glycan.replace('KDN', 'Kdn')
        glycan = glycan.replace('(3S)', '[S(3)]')
        glycan = glycan.replace('(4S)', '[S(4)]')
        glycan = glycan.replace('(6S)', '[S(6)]')
        glycan = glycan.replace('(6P)', '[P(6)]')

        eng = matlab.engine.start_matlab()

        eng.drawglycan(glycan,
                       'linkinfodist', 0.9,
                       'fileout', 'glycan_drawings/' + filename,
                       'visible', 'off',
                       'showlink', 'no',
                       nargout = 0)

        eng.quit()

    except:

        open('glycan_drawings/' + filename, 'a').close()

def draw_error(glycan, filename):

    glycan = glycan.replace('GlcNac', 'GlcNAc')
    glycan = glycan.replace('KDN', 'Kdn')
    glycan = glycan.replace('(3S)', '[S(3)]')
    glycan = glycan.replace('(4S)', '[S(4)]')
    glycan = glycan.replace('(6S)', '[S(6)]')
    glycan = glycan.replace('(6P)', '[P(6)]')

    eng = matlab.engine.start_matlab()

    eng.drawglycan(glycan,
                   'linkinfodist', 0.9,
                   'fileout', 'glycan_drawings/' + filename,
                   'visible', 'off',
                   'showlink', 'yes',
                   nargout = 0)

    eng.quit()

data = pd.read_csv('glycan_drawings/glycans.csv')

for index, glycan in zip(data['Index'], data['IUPAC']):

    filename = str(index) + '_' + glycan

    draw(glycan, filename)

    print(index, glycan)
