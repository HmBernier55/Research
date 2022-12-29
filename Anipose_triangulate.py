# import numpy as np
# from aniposelib.utils import load_pose2d_fnames
# from aniposelib.cameras import Camera, CameraGroup
# import pandas as pd
from anipose.triangulate import triangulate
import toml


fname_dict = {
    'A': '2022-05-27-MAX-camA.xlsx',
    'B': '2022-05-27-MAX-camB.xlsx',
    'C': '2022-05-27-MAX-camC.xlsx',
    'D': '2022-05-27-MAX-camD.xlsx',
    'E': '2022-05-27-MAX-camE.xlsx',
    'F': '2022-05-27-MAX-camF.xlsx',
}
config = toml.load("config.toml")
p3ds = triangulate(config,r"C:\Users\12053\anaconda3\envs\Hunter_research\New-Project",fname_dict,"points_3d_triangulate_05_27_MAX.xlsx")
