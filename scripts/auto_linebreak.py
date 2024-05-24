import os, re, itertools, statistics
LINEWIDTH = 40
LINECOUNTMAX = 3
LONGTEXT = re.compile(r'(?<=[\]^])([^\[\]]{%d,})(?=\[)' % LINEWIDTH)
BREAK = '[linebreak]' # or \u83
BREAKABLES = set('。,.:;!?⋯一')
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
            ans += line[bps[p]:min(bps[p+1] + 1,len(line))]
            if bps[p+1] != len(line): ans += BREAK            
        return ans
    else:
        return line
for script in os.listdir('script'):
    file = os.path.join('script/', script)
    lines = open(file, 'r', encoding='utf-8').readlines()
    lines = [process_line(line) for line in lines]
    open(file, 'w', encoding='utf-8').writelines(lines)