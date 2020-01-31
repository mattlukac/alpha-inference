import numpy as np
import scipy.stats as stats
import seaborn as sns
sns.set_style('white')
sns.despine()
sns.set_context('talk')

#x = np.linspace(0,10,1000)
#y = stats.gamma.pdf(x, a=2, scale=3)

#gamma = sns.lineplot(x,y).set_title('shape=2 scale=3')
#fig = gamma.get_figure()
#fig.savefig('gamma.png', dpi=1200)

shape = np.random.uniform(0.1,3,1)
scale = np.random.uniform(500,1000,1)
gam = np.random.gamma(shape=shape, scale=scale, size=1000)
ax = sns.distplot(gam, kde=False, fit=stats.gamma, hist=None, fit_kws={'color':'darkred'})

# Get the line from the axes to generate shading
l = ax.lines[0]

# Get the xy data from the lines so that we can shade
x = l.get_xydata()[:,0]
y = l.get_xydata()[:,1]
ax.fill_between(x,y, color="darkred", alpha=0.3)
ax.set_yticks([])
fig = ax.get_figure()
fig.savefig('gamma.png', dpi=1200)
