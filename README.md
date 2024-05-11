# Toolkit for Quantitative Spatial Models

**© Gabriel M. Ahlfeldt, Tobias Seidel**

Version 0.9, 2024

## General remarks

This toolkit covers a class of quantitative spatial models established by Monte, Redding, Rossi-Hansberg (2018). We aim to provide an accessible and easy-to-use simulation framework within `MATLAB` (Monte, Reeding, Rossi-Hansberg use `Mathematica`) that helps developing the intuition for the key mechanisms in the model as well as the programming implementation of the model. To this end, this toolkit contains a codebook which summarizes the various exogenous and endogenous objects of the model, its equilibrium conditions, and various solvers used to take the model to the data. We build on Seidel and Wieckerth (2020) who apply a variant of the Monte, Redding, Rossi-Hansberg (2018) model to Germany. The toolkit introduces a subset of codes that are crucial for the quantification and simulation of the model, with applications that serve didactic purposes and are unrelated to the substantive analyses in both papers. For more general applicability, the toolkit is designed to also work in instances where the researcher does not observe bilateral commuting flows (and possibly not even wages). 

This toolkit has been developed as core component of the course [Quantitative Spatial Economics](https://sites.google.com/view/bqse/bqse-teaching) taught by Gabriel Ahlfeldt to research students at the Berlin School of Economics and Humboldt University.

## General rnstructions

Before you can start, you **need to install the following MATLAB toolboxes:**

- Global optimization toolbox
- Optimization toolbox
- Mapping toolbox
- Statistics and machine learning toolbox

To install a MATLAB toolbox, open MATLAB and go to the 'Home' tab. Click on 'Add-Ons' in the menu. From there, browse or search for the toolbox you want to install. Click on the toolbox to view its details. Then, proceed by clicking 'Install.' Follow the on-screen instructions, which will include accepting the license agreement and selecting the installation path. After the installation is complete, the toolbox will be ready to use. Make sure you have the appropriate licenses for the toolbox you've selected.

## Further resources:

 Monte, Redding, Rossi-Hansberg (2018): Commuting, Migration, and Local Employment Elasticities, \emph{American Economic Review}, 108(12), pp. 3855-90, https://doi.org/10.1257/aer.20151507
 
 Seidel, Wieckerth (2020): Rush hours and urbanization}, \emph{Regional Science and Urban Economics}, 85, https://doi.org/10.1016/j.regsciurbeco.2020.103580

