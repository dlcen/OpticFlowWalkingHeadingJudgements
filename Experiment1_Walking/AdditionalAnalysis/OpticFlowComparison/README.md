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
For each virtual environment, there is a folder that contains the code for the dot sampling in this room, `DotSampling.m`.

#### Line

#### Outline

#### Room

#### Cloud

### Flow vector calculation
The viewer was 6m from the target and moving towards it at 1m/s. The eye-height of the viewer was 1.5m.
