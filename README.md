# Point cloud tools for Matlab

**Note**: If you just want to align 2 point clouds with the ICP algorithm, check out a newer and simpler solution called **simpleICP**. You can find it on [Github](https://github.com/pglira/simpleICP) or at the [Matlab file exchange](https://de.mathworks.com/matlabcentral/fileexchange/81273-simpleicp). However, if you want to work and visualize point clouds in Matlab, or you need a more flexible and powerful ICP algorithm to align > 2 point clouds at once, this here might be the right library for you.

## Documentation

The documentation is hosted here: http://www.geo.tuwien.ac.at/downloads/pg/pctools/pctools.html

Currently included are:

* **pointCloud class**: a Matlab class to **read**, **manipulate** and **write** point clouds

* **globalICP class**: a Matlab class to **optimize the alignment** of **many point clouds** with the **ICP algorithm**

![alt tag](http://www.geo.tuwien.ac.at/downloads/pg/pctools/img/PointCloudToolsSmall.png)

Also available on:
[![View Point cloud tools for Matlab on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://de.mathworks.com/matlabcentral/fileexchange/54412-point-cloud-tools-for-matlab)

Please cite related papers if you use this code:
```
@article{glira2015a,
  title={A Correspondence Framework for ALS Strip Adjustments based on Variants of the ICP Algorithm},
  author={Glira, Philipp and Pfeifer, Norbert and Briese, Christian and Ressl, Camillo},
  journal={Photogrammetrie-Fernerkundung-Geoinformation},
  volume={2015},
  number={4},
  pages={275--289},
  year={2015},
  publisher={E. Schweizerbart'sche Verlagsbuchhandlung}
}
```