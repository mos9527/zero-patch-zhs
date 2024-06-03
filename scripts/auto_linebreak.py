'''对单行过长的文本进行自动分行处理

该优化将保证被划分的行数为LINECOUNTMAX，同时保证行长度方差最小
注：本脚本将覆写原有脚本

usage:
scripts\script> python auto_linebreak.py
'''
import os, re, itertools, statistics
LINEWIDTH = 30
LINECOUNTMAX = 3
LONGTEXT = re.compile(r'([^\[\]]{%d,})(?=\[)' % LINEWIDTH)
BREAK = '[linebreak]' # or \u83
BREAKABLES = set('。,.:;!?')
def optimize_line(line, span):
    # Split line into multiple lines, while minimizing variance of line lengths
    # This is O(C(n, LINECOUNTMAX - 1))...yikes
    points = []
    for i in range(*span):
        if line[i] in BREAKABLES: points.append(i)
    ans = None
    ans_min_s = float('inf')
    for c in itertools.combinations(points, LINECOUNTMAX - 1):
        lens = [c[0] - span[0]] + [c[i] - c[i - 1] for i in range(1, len(c))] + [span[-1] - c[-1]]  
        S = statistics.variance(lens)
        if S < ans_min_s:
            ans = c
            ans_min_s = S
    return ans
def process_line(line):
    breakpoints = set()
    for result in LONGTEXT.finditer(line):
        span = result.span()
        optimized = optimize_line(line, span)
        if optimized:
            breakpoints.update(optimized)
    if breakpoints:
        ans = ""
        bps = sorted(breakpoints | {0, len(line)})
        for p in range(0, len(bps) - 1):
            ans += line[bps[p] + (p != 0):bps[p+1]]
            if bps[p+1] != len(line): ans += BREAK            
        return ans
    else:
        return line
for script in os.listdir('script'):
    file = os.path.join('script/', script)
    lines = open(file, 'r', encoding='utf-8').readlines()
    lines = [process_line(line) for line in lines]
    open(file, 'w', encoding='utf-8').writelines(lines)