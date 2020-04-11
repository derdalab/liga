# SH-I

import string

def brac(str):

    """Converts round brackets to square."""

    brac = str.maketrans('()', '[]')

    str = str.translate(brac)

    return str

def conv(str):

    """Converts string to IUPAC Condensed."""

    glycan = str.split('-')

    if len(glycan) == 2:

        mono_1 = glycan[0]
        mono_1 = mono_1[:-1] + '(' + mono_1[-1:]

        return mono_1 + '1-'

    if len(glycan) == 3:

        mono_1 = glycan[0]
        mono_1 = mono_1[:-2] + '(' + mono_1[-2:]

        mono_2 = glycan[1]
        mono_2 = mono_2[:1] + ')' + mono_2[1:-1] + '(' + mono_2[-1:] + '1'

        return mono_1 + '-' + mono_2 + '-'

    else:

        mono_1 = glycan[0]
        mono_1 = mono_1[:-2] + '(' + mono_1[-2:]

        mono_mid = glycan[1:-2]

        for i, x in enumerate(mono_mid):

            x = x[:1] + ')' + x[1:-2] + '(' + x[-2:]

            mono_mid[i] = x

        mono_n = glycan[-2]
        mono_n = mono_n[:1] + ')' + mono_n[1:-1] + '(' + mono_n[-1:] + '1'

        return mono_1 + '-' + '-'.join(mono_mid) + '-' + mono_n + '-'

def link(str):

    """Returns the linkage."""

    glycan = str.split('-')
    link = glycan[-1]

    return link

def lac(str):

    """Expands Lactose."""

    iupac = str.replace('Lac', 'Gal(b1-4)Glc')

    return iupac

if __name__ == '__main__':
    print('This file needs to be imported.')
    print('Read the function docs for use.')
