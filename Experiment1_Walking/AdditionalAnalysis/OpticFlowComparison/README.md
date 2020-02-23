# Comparing the richness of optic flow in the four virtual environments

## Overview of the pipeline

![pipeline](./Figures/AnalysisPipeline.jpg)

* __Dot sampling__ is to sample dots from the visual elements in the virtual environment. Based on the position of these dots, flow vectors are calculated.
* __Flow vector calculation__ is to calculate the flow vectors from the sampled visual dots. Specifically, the vectors were calculated as the projection of the relative motion of the dots on the retina of a moving viewer.
* __Translational field__ and __Translational + rotational field__: depending on whether the viewer is fixating on the target or not during the movement, two types of flow fields were calculated here. **Translational field** is calculated for a pure translation of the viewer with the gaze fixed at the moving direction. __Translational and rotational field__, however, is calculated for the situation that the viewer is moving in a direction away from the target but the gaze is fixed at the target.
  - From the __translational field__, we calculated a __speed gradient__ on the speed of the flow vectors in the field.
  - From the __translational and rotational field__, we calculated the number of pairs of dots that could form __motion parallax__ for each virtual environment, according to the definition by [Longuet-Higgins & Prazdny, 1980](https://royalsocietypublishing.org/doi/abs/10.1098/rspb.1980.0057).

## Details of each step in the pipeline

### Dot sampling
For each virtual environment, there is a folder that includes the code for sampling the dots in this virtual environment, `DotSampling.m`.  Running the code will yield a .csv file that records the position of each sampled dot in the world coordinate with the original point at the starting point (7m from the target) in the actual experiment. It will also generate a .mat file that contains the position of the sampled dots relative to the viewer (6m from the target) in this analysis.

#### Line
![sampling line condition](./Line/SampleDotsDemo.png)

The visual dots are sampled along four edges of the image of target post projects on the 2D plane at the starting point (i.e., top, bottom, left and right).

#### Outline
![sampling outline condition](./Outline/SampleDotsDemo.png)

The visual dots are sampled along the lines that constitute the whole outline of the room.

#### Room
![sampling room condition](./Room/SampleDotsDemo.png)

The visual dots are sampled along the black-white edges on the random-noised pattern of the wall texture. The image file of the texture is `wallTex_Brightened.jpg`, contained in the 'Room' folder. MATLAB function `edge` (using the Canny method) is used for extracting the black-white edges on the texture pattern.

#### Cloud
![sampling cloud condition](./Cloud/SampleDotsDemo.png)

The sampled dots for the *Cloud* condition contain two groups. One group contains the sampled dots from the target post, which is calculated in the same way as for the *Line* condition. The other group contains the dots that constitute the cloud. In the experiment, there were a total of 5250 dots in the cloud. Each dot had a limited lifetime of 500ms. Following a protocol similar to [Foulkes, Rushton and Warren, 2013](https://www.frontiersin.org/articles/10.3389/fnbeh.2013.00053/full#B11) and an estimate of visual persistence of around 100ms ([Di Lollo, 1980](https://psycnet.apa.org/record/1981-06942-001)), it is estimated perception of 20% more dots than were presented on any single frame. Therefore, a total of 6300 dots were created for the analysis.

### Flow vector calculation
The viewer was 6m from the target and moving towards it at 1m/s. The eye-height of the viewer was 1.5m.
