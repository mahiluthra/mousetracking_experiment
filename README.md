# mousetracking_experiment
Javascript mousetracking experiment and R code for analyses

Experiment structure and analyses are inspired by Freeman and Ambady (2010; https://link.springer.com/content/pdf/10.3758/BRM.42.1.226)

The experiment has been designed on JavaScript using the jsPsych library (https://www.jspsych.org/). Since this experiment is browser based, it can be conveniently used for online experiments (e.g., on MTurk). However, given that online experiments have less controlled environments, reliability might be affected.

The jspsych directory includes plugins needed to create a mouse tracking experiment. Code for a sample mousetracking experiment has also been included-- other experiments can be adapted from this sample experiment. By default the experiment tracks mouse-coordinates in a 600x1000 pixel container. These dimensions can easily be altered. The current code is unable to identify the screen dimensions of the user and adapt accordingly. 

R code for cleaning data, conducting simple analyses (timenormalizing coordinates, calculating area under the curve), and plotting have been included. Below is an example of mouse trajectory plots resulting from this experiment. More complex analyses methods can easily be conducting using cleaned mouse trajectory data.

![mt_fig](mt_fig.png)
