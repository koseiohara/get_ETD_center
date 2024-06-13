import numpy as np
import os
from io import BufferedReader


def read_direct(file, shape, recl, rec, kind, endian):

    # Change data type of shape to ndarray
    shape = np.array(shape)

    # kind_specifier='f' if single precision, 'd' if double precision
    kind_specifier   = get_kind(kind)
    # endian_specifier='<' if little-endian, '>' if big-endian
    endian_specifier = get_endian(endian)

    # Check arguments
    argcheck(file, shape, recl, rec, kind)

    # Skip unnecessary data
    skip_byte = recl * (rec-1)
    file.seek(skip_byte, os.SEEK_SET)
    # Read the desired data
    input_binary = file.read(recl)

    # Convert binary-type to float and reshape into the specified array shape
    # return array
    return np.reshape(np.frombuffer(input_binary, \
                                    dtype='{}{}'.format(endian_specifier, kind_specifier)), \
                                    shape)


def get_kind(kind):

    if (kind == 4):
        return 'f'
    elif (kind == 8):
        return 'd'
    else:
        print('')
        print('ERROR in read_direct -----------------------------')
        print('|   Invalid kind input')
        print('|   kind argument must be 4 or 8')
        print('--------------------------------------------------')
        exit(1)


def get_endian(endian):

    lower_endian = endian.lower()
    
    if (lower_endian == 'little'):
        return '<'
    elif (lower_endian == 'big'):
        return '>'
    else:
        print('')
        print('ERROR in read_direct -----------------------------')
        print('|   Invalid endian input')
        print('|   endian argument must be "little" or "big"')
        print('--------------------------------------------------')
        exit(1)


# Check Validity of arguments
def argcheck(file, shape, recl, rec, kind):

    if (type(file) is not BufferedReader):
        print('')
        print('ERROR in read_direct -----------------------------')
        print('|   Invalid data type of file')
        print('|   file must be the pointer for the opened file')
        print('|   Execute command below before calling this function :')
        print('|')
        print('|       file=open(filename, "rb")')
        print('|')
        print('--------------------------------------------------')
        exit(1)

    if (file.closed):
        print('')
        print('ERROR in read_direct -----------------------------')
        print('|   file has already been closed')
        print('--------------------------------------------------')
        exit(1)

    if (type(recl) is not int):
        print('')
        print('ERROR in read_direct -----------------------------')
        print('|   Invalid data type of recl')
        print('|   recl must be an integer variable')
        print('|   Inputted data is {}'.format(type(recl)))
        print('--------------------------------------------------')
        exit(1)

    if (recl <= 0):
        print('')
        print('ERROR in read_direct -----------------------------')
        print('|   Invalid value of recl')
        print('|   recl must be more than zero')
        print('|   Inputted recl is {}'.format(rec))
        print('--------------------------------------------------')
        exit(1)

    if (type(rec) is not int):
        print('')
        print('ERROR in read_direct -----------------------------')
        print('|   Invalid data type of rec')
        print('|   rec must be an integer variable')
        print('|   Inputted data is {}'.format(type(rec)))
        print('--------------------------------------------------')
        exit(1)

    if (rec <= 0):
        print('')
        print('ERROR in read_direct -----------------------------')
        print('|   Invalid value of rec')
        print('|   rec must be more than zero')
        print('|   Inputted rec is {}'.format(rec))
        print('--------------------------------------------------')
        exit(1)

    if (np.prod(shape)*kind != recl):
        print('')
        print('ERROR in read_direct -----------------------------')
        print('|   shape, recl, and kind arguments does not match each other')
        print('|   Data size of outputted array must same as the recl value')
        print('--------------------------------------------------')
        exit(1)


