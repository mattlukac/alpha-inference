import numpy as np
import scipy.stats as stats
import seaborn as sns
import sys
from scipy.stats import gamma

sns.set_style('white')
sns.despine()
sns.set_context('talk')

# Get shape and scale parameters
#shape = np.random.uniform(0.2,2,1)
#scale = np.random.uniform(500,1000,1)

#mean = 375.0
#sd = 290.0
#lMean = 200.0
#uMean = 575.0
#lSD = 180.0
#uSD = 450.0

#regions = {'missense':[375.0, 290.0, 200.0, 575.0, 180.0, 450.0],
#	   'synonymous':[380.0, 310.0, 190.0, 740.0, 170.0, 520.0],
#	   'intron':[295.0, 250.0, 140.0, 510.0, 120.0, 410.0],
#	   'intergenic':[160.0, 153.0, 78.0, 270.0, 80.0, 250.0],
#	   '3prime_UTR':[310.0, 260.0, 173.0, 600.0, 150.0, 480.0],
#	   '5prime_UTR':[310.0, 267.0, 170.0, 520.0, 180.0, 420.0]
#	  }
regions = ['missense', 'synonymous', 'intron', 'intergenic', '3prime_UTR', '5prime_UTR']
values = []
for region in regions:
    x = np.load('../models/tennessenEuro/backups/0.14027949339813656_valLoss/jptPredictions/' + region + '_200kb_chr1.npy')
    regionList = []
    regionList.append(np.mean(x[:,0]))
    regionList.append(np.mean(x[:,1]))
    regionList.append(np.quantile(x[:,0], 0.025))
    regionList.append(np.quantile(x[:,0], 0.975))
    regionList.append(np.quantile(x[:1], 0.025))
    regionList.append(np.quantile(x[:1], 0.975))
    values.append(regionList)

regionDict = dict(zip(regions, values))

def plotGammaCI(avgMean, avgSD, lMean, uMean, lSD, uSD, title):
    meanCI = np.linspace(lMean, uMean, 50)
    sdCI = np.linspace(lSD, uSD, 50)
    alphaCI = (meanCI / sdCI)**2
    betaCI = sdCI**2 / meanCI
    alpha = (avgMean / avgSD)**2
    beta = avgSD**2 / avgMean
    plotGamma(alpha, beta, title, solid=True)
    for idx in range(50):
        plotGamma(alphaCI[idx], betaCI[idx], title, solid=False)

def plotGamma(alpha, beta, title, solid):
    if solid:
        a=0.8
    else:
        a=0.4

    gamMax = np.max(gamma.pdf(x=np.linspace(0.1,1200,500),a=alpha, scale=beta))
    # Make histogram plot
    gamHist = np.random.gamma(shape=alpha, scale=beta, size=1000)
    axHist = sns.distplot(gamHist, kde=False, fit=stats.gamma, hist=None, fit_kws={'color':'darkred', 'alpha':a})

    # Get the line from the axes to generate shading
    lHist = axHist.lines[0]

    # Get the xy data from the lines so that we can shade
    xHist = lHist.get_xydata()[:,0]
    yHist = lHist.get_xydata()[:,1]

    # Save histogram plot
    axHist.fill_between(xHist,yHist, color="lightblue", alpha=0.3)
    axHist.set_xlim([0,1200])
    axHist.set_ylim([0,gamMax*1.5])
    axHist.set_title(title)
    figHist = axHist.get_figure()
    figHist.savefig(title + '.png', dpi=1200)

for key, value in regionDict.items():
    plotGammaCI(value[0], value[1], value[2], value[3], value[4], value[5], key + '_inferred_DFE')

#figHist.clf()

# Similarly, make density plot
#gam = np.random.gamma(shape=alpha, scale=beta, size=1000)
#ax = sns.distplot(gam, kde=False, fit=stats.gamma, hist=None, fit_kws={'color':'darkred'})

#l = ax.lines[0]

#x = l.get_xydata()[:,0]
#y = l.get_xydata()[:,1]

#ax.fill_between(x,y, color="darkred", alpha=0.3)
#ax.set_yticks([])
#fig = ax.get_figure()
#fig.savefig('gamma.png', dpi=1200)
