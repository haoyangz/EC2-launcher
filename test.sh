docker run -v /cluster/zeng/code/research/recomb/generic_ec2/input:/mnt -i --rm --device /dev/nvidiactl --device /dev/nvidia-uvm --device /dev/nvidia0 haoyangz/caffe-with-spearmint-wrapper /root/caffe-with-spearmint-wrapper/run.py /mnt/runparam_docker.list