## ReSySeVR

**<u>*Note: This repo is based on snapshots of SySeVR in 2020, and has not yet been sync'd up with its latest updates.*</u>**

This is an **<u>*attempted*</u>** fixed version of SySeVR: [https://github.com/SySeVR/SySeVR](https://github.com/SySeVR/SySeVR). There are still some known issues.

### Notes

- Please follow the instructions in `config.sh`. Don't run it directly as it contains some branching instructions. Read and follow it.
- For a quick/sanity testing of the environment, you can remove most of the folders after executing `./split-sard.sh`, which will dramatically reduce the data processing time.
- You need to manually change the flag in `bgru.py` to switch the model between training and testing. Currently it's set to training. See corresponding switches in line 69 and line 110.

### Known Issues

- The data labeling script may end up assigning every slice the same label. For a quick fix, please refer to a new simplified labeling script provided in the `src_vf` folder.

### VF Extension

The VF extension simplified the data labeling process a bit, and provide a basic graph neural network pipeline that performs classification. Note that this is NOT a re-implementation of the original SySeVR.

The processed data (for SARD) can be downloaded here: [Google Drive](https://drive.google.com/drive/folders/11S-tQmdUcgoWAWt16olC5_pKOZDLL_J8?usp=sharing). Use the notebook in `src_vf` to continue with learning or manipulate the data processing.

The latest processed data (that is provided to the network, with pre-processing like new tokenization etc., as of July 27, 2021) can be found here: [Google Drive](https://drive.google.com/file/d/1-VmTGjM8KACsrra3Mlzj3WOAB2ASSZyN).

### References

- SySeVR_fix: [https://github.com/kingnop/SySeVR_fix](https://github.com/kingnop/SySeVR_fix)
- environment setup: https://github.com/tophertimzen/vagrantized-Joern/blob/master/setup.sh
- folder splitting:https://stackoverflow.com/a/36511395/14471117
- SySeVR guide: https://blog.csdn.net/weixin_42072280/article/details/106658014

