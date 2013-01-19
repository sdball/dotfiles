#!/usr/bin/env python
# coding=UTF-8

# by Steve Losh
# http://stevelosh.com/blog/2010/02/my-extravagant-zsh-prompt/#my-right-prompt-battery-capacity

# modified by sdball@gmail.com 2010-02-02
# * added colorprint to work with BASH color codes
# * specified unicode characters as unicode strings

# modified by sdball@gmail.com 2010-11-20
# * switched to colorama for coloring

import sys
import math, subprocess
from colorama import Fore, Back, Style

p = subprocess.Popen(["ioreg", "-rc", "AppleSmartBattery"], stdout=subprocess.PIPE)
output = p.communicate()[0]
o_max = [l for l in output.splitlines() if 'MaxCapacity' in l][0]
o_cur = [l for l in output.splitlines() if 'CurrentCapacity' in l][0]
o_plugged = [l for l in output.splitlines() if 'ExternalChargeCapable' in l][0]

b_max = float(o_max.rpartition('=')[-1].strip())
b_cur = float(o_cur.rpartition('=')[-1].strip())
b_plugged = o_plugged.rpartition('=')[-1].strip() == 'Yes'

charge = b_cur / b_max
charge_threshold = int(math.ceil(10 * charge))
# Output

filled_char = u"\u25CF"
empty_char = u"\u25CB"
# filled_char = '*'
# empty_char = '-'

total_slots, slots = 10, []
filled = int(math.ceil(charge_threshold * (total_slots / 10.0))) * filled_char
empty = (total_slots - len(filled)) * empty_char

out = ''.join([filled, empty])

color_out = (
    Fore.GREEN if len(filled) > 6 or b_plugged
    else Fore.WHITE + Style.DIM if len(filled) > 4
    else Fore.RED
)

try:
    flag = sys.argv[1]
except IndexError, e:
    flag = None

if flag == 'color':
    print (Fore.RESET + Style.RESET_ALL
          + color_out + out
          + Fore.RESET + Style.RESET_ALL)
else:
    if b_plugged:
        print "%s (P)" % out
    else:
        print "%s (-)" % out
