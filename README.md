## ReSySeVR

This is a fixed version of SySeVR: [https://github.com/SySeVR/SySeVR](https://github.com/SySeVR/SySeVR).

### Notes

- Please follow the instructions in `config.sh`. Don't run it directly as it contains some branching instructions. Read and follow it.

- For a quick/sanity testing of the environment, you can remove most of the folders after executing `./split-sard.sh`, which will dramatically reduce the data processing time.
- You need to manually change the flag in `bgru.py` to switch the model between training and testing. Currently it's set to training. See corresponding switches in line 69 and line 110.

### References

- SySeVR_fix: [https://github.com/kingnop/SySeVR_fix](https://github.com/kingnop/SySeVR_fix)
- environment setup: https://github.com/tophertimzen/vagrantized-Joern/blob/master/setup.sh
- folder splitting:https://stackoverflow.com/a/36511395/14471117
- SySeVR guide: https://blog.csdn.net/weixin_42072280/article/details/106658014

