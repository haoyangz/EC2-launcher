A tool that lauches docker jobs on Amazon EC2.

## Connection Mode
Two connection modes are provided: VPN and S3. 

+ For Gifford lab only, the VPN mode establish a direct connection between /cluster and the EC2 instance through a VPN. With this model, the user can access /cluster on EC2 instance as if you are physically running on the cluster.

+ For general users, the S3 mode is the only choice. In this model, the input data will be automatically uploaded to S3 storage and all the output will also be dumped to S3. The user will need to manually retrieve the output from S3 if needed.

## Example Usage

#### VPN mode
```
docker run -i -v /cluster/ec2:/cluster/ec2 -v /etc/passwd:/root/passwd:ro \
	-v CREDFILE:/credfile:ro -v RUNFILE:/commandfile \
	--rm haoyangz/ec2-launcher \
	python ec2run.py CPU VPN -u $(id -un) 
```
+ `CREDFILE`: The path to EC2 cred file. (example/cred)
+ `RUNFILE`: The file containing bash commands to run. Each line should be one complete bash command which will be run as one job (process). To specify the number of jobs per instance, checkout the "Option" section below. If needed, multiple bash commands can be concatenated into oneline seperated by ";" and they will be sequentially executed. (example/testscript.txt, example/testscript-gpu.txt)
+ `-u $(id -un)`: this is not required but suggested. See "Options" section for more details.

#### S3 mode

```
docker run -i -v DATADIR:/indata -v /etc/passwd:/root/passwd:ro \
	-v CREDFILE:/credfile:ro -v RUNFILE:/commandfile \	--rm haoyangz/ec2-launcher-test \
	python ec2run.py CPU S3 -b BUCKETNAME -ru RUNNAME
```

+ `DATADIR`: The directory of the input data. All the subfolder of this directory will be recursively copied to $BUCKETNAME$/$RUNNAME$/input on S3 and then to /scratch/input on the EC2 instance. Therefore, configure your commands in RUNFILE to get data from /scratch/input
+ `RUNFILE`: **Note** You should configure your commands in RUNFILE to output to /scratch/output, all the contents of which will be copied to S3 folder $BUCKETNAME$/$RUNNAME$/output when finished. (example/testscript-s3.txt, example/testscript-s3-gpu.txt)
+ `CREDFILE`: Same as in VPN mode (example/cred)
+ `BUCKETNAME`: The S3 bucket to store the input and output  **(required)**
+ `RUNNAME`: The subfolder of S3 bucket to store the input and output. So all the data will be under $BUCKETNAME$/$RUNNAME$ on S3.  **(required)**



## Options
Run the following command to get the full list of options:

```
python ec2run.py -h
```

which will output the following:


```
positional arguments:
  mode                  Running model (GPU/CPU)
  connection            connection type (VPN/S3)

optional arguments:
  -h, --help            show this help message and exit
  -a AMI, --ami AMI     Target AMI (default 864d84ee).
  -s SUBNET, --subnet SUBNET    VPN (?) subnet.
  -i ITYPE, --itype ITYPE   Instance type (default r3.xlarge).
  -k KEYNAME, --keyname KEYNAME    Keyname (default starcluster; credential file overrides this).
  -r REGION, --region REGION 	EC2 region (default us-east-1).
  -p PRICE, --price PRICE 		Spot bid price (default 0.34).
  -u USER, --user USER  User (default is $USER).
  -e EMAIL, --email EMAIL 		Email (default is $USER@csail.mit.edu).
  -n SPLITSIZE, --splitsize SPLITSIZE 		Number of commands per instance (default 1).
  -b BUCKET, --bucket BUCKET 		The S3 bucket for data transfer (for S3 mode only)
  -ru RUNNAME, --runname RUNNAME		The S3 runname for data transfer (for S3 mode only)

```

#### Commonly tweakable options

+ `AMI`: Choose the right OS that matches your usage.
+ `ITYPE` Choose the right machine [type](https://aws.amazon.com/ec2/instance-types/) that matches your usage.
+ `REGION`: This is only tweakable for S3 mode as VPN is only built on us-east-1d
+ `PRICE`: In EC2 console, check out "Pricing History" under instances -> Spot Requests for a good price.
+ `USER`: The commands in `RUNFILE` will be run as this user. This is only meaningful for VPN mode, in which the EC2 instance directly writes the output to /cluster as that user.
+ `EMAIL`: No need to specifcy for Gifford lab
+ `SPLITSIZE`: This number of jobs will be running in parallel in one instance.
+ `BUCKET`: For S3 mode only
+ `RUNNAME`: For S3 mode only

## Notes for GPU jobs

+ The default AMI and ITYPE are for CPU jobs only. To run GPU jobs, the suitable AMI and ITYPE should be provided (for example AMI: ami-763a311e and ITYPE: g2.2xlarge)

## To do

+ Make the mounted drive size a configurable parameter
+ Use IAM role configuration instead of authentic credentials to access S3 from EC2 instance for security