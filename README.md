# Toolkit for Quantitative Spatial Models

**© Gabriel M. Ahlfeldt, Tobias Seidel**

Version 0.9, 2024

## General remarks

This toolkit covers a class of quantitative spatial models established by Monte, Redding, Rossi-Hansberg (2018). We aim to provide an accessible and easy-to-use simulation framework within `MATLAB` (Monte, Reeding, Rossi-Hansberg use `Mathematica`) that helps developing the intuition for the key mechanisms in the model as well as the programming implementation of the model. To this end, this toolkit contains a codebook which summarizes the various exogenous and endogenous objects of the model, its equilibrium conditions, and various solvers used to take the model to the data. We build on Seidel and Wickerath (2020) who apply a variant of the Monte, Redding, Rossi-Hansberg (2018) model to Germany. The toolkit introduces a subset of codes that are crucial for the quantification and simulation of the model, with applications that serve didactic purposes and are unrelated to the substantive analyses in both papers. For more general applicability, the toolkit is designed to also work in instances where the researcher does not observe bilateral commuting flows (and possibly not even wages). 

This toolkit has been developed as core component of the course [Quantitative Spatial Economics](https://sites.google.com/view/bqse/bqse-teaching) taught by Gabriel Ahlfeldt to research students at the Berlin School of Economics and Humboldt University.

## General instructions

Before you can start, you **need to install the following MATLAB toolboxes:**

- Global optimization toolbox
- Optimization toolbox
- Mapping toolbox
- Statistics and machine learning toolbox

To install a MATLAB toolbox, open MATLAB and go to the 'Home' tab. Click on 'Add-Ons' in the menu. From there, browse or search for the toolbox you want to install. Click on the toolbox to view its details. Then, proceed by clicking 'Install.' Follow the on-screen instructions, which will include accepting the license agreement and selecting the installation path. After the installation is complete, the toolbox will be ready to use. Make sure you have the appropriate licenses for the toolbox you've selected.

## How to Use the Toolkit

The toolkit is designed as a didactic journey through the codes essential for the quantification and simulation of this class of models. The aim is to convey how to quantify the model and conduct simple counterfactuals.

Once you are set up, execute the codes in the order in which they are being called by `SW2020_toolkit.m` in the `scripts` folder. When you use the toolkit for the first time, it is especially important that you execute the scripts exactly in the order outlined by `SW2020_toolkit.m` as intermediate inputs will be generated that will be used at later stages. There are also didactic reasons for proceeding in the given order since the structure broadly follows the use of the model in the paper and codes become progressively more complex. For the best learning experience, we recommend that you open the scripts and go through the code line by line (instead of calling scripts from `SW2020_toolkit.m`). Plenty of comments have been added to refer to the relevant equations in the paper. It will likely be beneficial to triangulate between the code, the pseudo codes summarized in the **codebook**, and the Monte, Redding, Rossi-Hansberg (2018) and Seidel, Wickerath (2020) papers to understand how the code implements the model.

Throughout the quantification of the model, we use the `MAPIT` program to illustrate selected variables recovered using the structure of the model. You can use `MAPIT` to conveniently plot any model input or output at any stage of the analysis to develop your intuition for the various endogenous and exogenous objects. `MAPIT` is relatively slow. If you want to experiment with the code and reduce the computational time, you may find it convenient to outcomment the use of `MAPIT`.

After recovering the unobserved exogenous location characteristics, we use various solution algorithms to solve for the spatial equilibrium. For illustrative purposes, we perform a series of simple counterfactuals. Specifically, we implement a hypothetical border along the former border between East and West Germany that may either prevent commuting, trade, or both. Notice that the population remains mobile across residences. This way, the model provides insights into who the population would like to reoptimize their location choices in light of the asymmetry of the strength of the shock that arises from the two different parts home market size. You can use `MAPIT` to inspect the effects on any endogenous outcome and execute similar counterfactuals by changing other primitives of the model. The toolkit will hopefully be sufficiently transparent for you to conveniently run your own counterfactuals.

Monte, Redding, Rossi-Hansberg (2020) and Seidel, Wickerath (2020) quantify the model using observed commuting flows. They rationalize zero commuting flows by setting commuting costs to infinity. The advantage of this approach is that it allows for arbitrary commuting costs on routes with positive commuting flows. Depending on your application, you may wish to use commuting cost matrices that are smooth functions of network distance, travel time, or other distance measures. This will be particularly desirable in counterfactuals if you wish to allow for changes in commuting flows at the extensive margin. For example, a new road or rail may lead to commuting flows on certain routes changing from zero to positive values. You may also simply not observe bilateral commuting flows. To facilitate the applicability of the toolkit in such instances, you can use Algorithm `getBiTK` to predict bilateral commuting flows that are consistent with observed workplace employment, residence population and commuting costs. The algorithm recovers a measure of workplace amenities, that ensures that workplace employment predicted by the model matches data. Please run the script `OwnData.m` in the `scripts' folder in these instances. Make sure that the code reads your commuting cost matrix (`basline`) as well as workplace employment (`L_n`) and residence population (`R_n`) measures. You also not observe wages in your application. In this case, you may interpret the inverted fundamental as transformed wages as in Ahlfeldt, Redding, Sturm, Wolf (2015) from which you can recover model-consistent wages. Please refer to the **codebook** for further detail. 

When using the toolkit in your work, please cite Seidel and Wickerath (2020).

## MATLAB Files and Data Folders

| Directory | File | Description | Additional Information |
| --- | --- | --- | --- |
| `matlab/data/input` | | Folder containing required data inputs to execute this toolkit | -|
| `matlab/data/input` | `prepdata_big_TD86.mat` | MATLAB file containing 1986 variable generated using `matlab/prepdata_TD86.m` code. | This is a large data set, you need to download it to your machine from an external URL. [Download](https://box.hu-berlin.de/f/3f364937b4a240e883f8/?dl=1) |
| `matlab/data/input` | `prepdata_big_TD.mat` | MATLAB file containing 2006 variable generated using `matlab/prepdata_TD.m` code. | This is a large data set, you need to download it to your machine from an external URL. [Download](https://box.hu-berlin.de/f/54d2f718ec8644e5888f/?dl=1) |
| `matlab/data/input` | `ttpublic_2006_ren.mat` | MATLAB file generated by `prepdata_TD06ftpub.m` containing travel times without cars used for counterfactuals. | This is a large data set, you need to download it to your machine from an external URL. [Download](https://box.hu-berlin.de/f/9eb052b712204866beda/?dl=1) |
| `matlab/data/input` | `roptimis_all.mat` | MATLAB file containing parameter values estimated using the GMM procedure in Section 7. | -|
| `matlab/data/output` | | Folder containing data files generated by the scripts in this toolkit. | Will be populated while you execute the MATLAB programs. |
| `matlab/figs` | | Folder containing various subfolders that will be populated as you execute the MATLAB programs. |-|
| `matlab/section6` | | Folder containing various subfolders and code for the quantification and simulation of the model with exogenous fundamentals. |-|
| `matlab/section7` | | Folder containing various subfolders and code for the quantification and simulation of the model with endogenous agglomeration forces. |-|

## Further resources:

 Monte, Redding, Rossi-Hansberg (2018): Commuting, Migration, and Local Employment Elasticities, \emph{American Economic Review}, 108(12), pp. 3855-90, https://doi.org/10.1257/aer.20151507
 
 Seidel, Wickerath (2020): Rush hours and urbanization, \emph{Regional Science and Urban Economics}, 85, https://doi.org/10.1016/j.regsciurbeco.2020.103580

