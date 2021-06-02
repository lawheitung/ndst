NetApp Data Science Toolkit for Traditional Environments
=========

The NetApp Data Science Toolkit for Traditional Environments is a Python library that makes it simple for data scientists and data engineers to perform various data management tasks, such as provisioning a new data volume, near-instantaneously cloning a data volume, and near-instantaneously snapshotting a data volume for traceability/baselining. This Python library can function as either a [command line utility](#command-line-functionality) or a [library of functions](#library-of-functions) that can be imported into any Python program or Jupyter Notebook.

## Compatibility

The NetApp Data Science Toolkit for Traditional Environments supports Linux and macOS hosts.

The toolkit must be used in conjunction with a data storage system or service in order to be useful. The toolkit simplifies the performing of various data management tasks that are actually executed by the data storage system or service. In order to facilitate this, the toolkit communicates with the data storage system or service via API. The toolkit is currently compatible with the following storage systems and services:

- NetApp AFF (running ONTAP 9.7 and above)
- NetApp FAS (running ONTAP 9.7 and above)
- NetApp Cloud Volumes ONTAP (running ONTAP 9.7 and above)
- NetApp ONTAP Select (running ONTAP 9.7 and above)

Note: The 'prepopulate flexcache' operation only supports ONTAP 9.8 and above. All other operations support ONTAP 9.7 and above.

<a name="getting-started"></a>

## Getting Started

The NetApp Data Science Toolkit for Traditional Environments requires that Python 3.5 or above be installed on the local host.

The following Python libraries that are not generally bundled with a standard Python installation are required in order for the NetApp Data Science Toolkit for Traditional Environments to function correctly - netapp-ontap, pandas, tabulate, requests, boto3, pyyaml. These libraries can be installed with a Python package manager like pip.

```sh
python3 -m pip install netapp-ontap pandas tabulate requests boto3 pyyaml
```

A config file must be created before the NetApp Data Management Toolkit for Traditional Environments can be used to perform data management operations. To create a config file, run the following command. This command will create a config file named 'config.json' in '~/.ntap_dsutil/'.

```sh
./ntap_dsutil.py config
```

#### Example Usage

```sh
./ntap_dsutil.py config
Enter ONTAP management interface or IP address (Note: Can be cluster or SVM management interface): 10.61.188.114
Enter SVM (Storage VM) name: ailab1
Enter SVM NFS data LIF hostname or IP address: 10.61.188.119
Enter default volume type to use when creating new volumes (flexgroup/flexvol) [flexgroup]:        
Enter export policy to use by default when creating new volumes [default]: 
Enter snapshot policy to use by default when creating new volumes [none]: 
Enter unix filesystem user id (uid) to apply by default when creating new volumes (ex. '0' for root user) [0]: 
Enter unix filesystem group id (gid) to apply by default when creating new volumes (ex. '0' for root group) [0]: 
Enter unix filesystem permissions to apply by default when creating new volumes (ex. '0777' for full read/write permissions for all users and groups) [0777]: 
Enter aggregate to use by default when creating new FlexVol volumes: vsim_ontap97_01_FC_1
Enter ONTAP API username (Note: Can be cluster or SVM admin account): vsadmin
Enter ONTAP API password (Note: Can be cluster or SVM admin account): 
Verify SSL certificate when calling ONTAP API (true/false): false
Do you intend to use this toolkit to trigger Cloud Sync operations? (yes/no): yes
Note: If you do not have a Cloud Central refresh token, visit https://services.cloud.netapp.com/refresh-token to create one.
Enter Cloud Central refresh token: 
Do you intend to use this toolkit to push/pull from S3? (yes/no): yes
Enter S3 endpoint: http://10.61.188.75:2113
Enter S3 Access Key ID: TN9ISEC5BDGIOK59LC3I
Enter S3 Secret Access Key: 
Verify SSL certificate when calling S3 API (true/false): false
Created config file: '/Users/moglesby/.ntap_dsutil/config.json'.
```

## Troubleshooting Errors

If you experience an error and do not know how to resolve it, visit the [Troubleshooting](troubleshooting.md) page.

## Tips and Tricks

- [Accelerating the AI training workflow with the NetApp Data Science Toolkit.](https://netapp.io/2020/12/14/accelerating-the-ai-training-workflow-with-the-netapp-data-science-toolkit/)
- [Easy AI dataset-to-model traceability with the NetApp Data Science Toolkit.](https://netapp.io/2021/01/13/easy-ai-dataset-to-model-traceability-with-the-netapp-data-science-toolkit/)

<a name="command-line-functionality"></a>

## Command Line Functionality

The simplest way to use the NetApp Data Science Toolkit is as a command line utility. When functioning as a command line utility, the toolkit supports the following operations.

Data volume management operations:
- [Clone a data volume.](#cli-clone-volume)
- [Create a new data volume.](#cli-create-volume)
- [Delete an existing data volume.](#cli-delete-volume)
- [List all data volumes.](#cli-list-volumes)
- [Mount an existing data volume locally.](#cli-mount-volume)

Snapshot management operations:
- [Create a new snapshot for a data volume.](#cli-create-snapshot)
- [Delete an existing snapshot for a data volume.](#cli-delete-snapshot)
- [List all snapshots for a data volume.](#cli-list-snapshots)
- [Restore a snapshot for a data volume.](#cli-restore-snapshot)

Data fabric operations:
- [List all Cloud Sync relationships.](#cli-list-cloud-sync-relationships)
- [Trigger a sync operation for an existing Cloud Sync relationship.](#cli-sync-cloud-sync-relationship)
- [Pull the contents of a bucket from S3 (multithreaded).](#cli-pull-from-s3-bucket)
- [Pull an object from S3.](#cli-pull-from-s3-object)
- [Push the contents of a directory to S3 (multithreaded).](#cli-push-to-s3-directory)
- [Push a file to S3.](#cli-push-to-s3-file)

Advanced data fabric operations:
- [Prepopulate specific files/directories on a FlexCache volume (ONTAP 9.8 and above ONLY).](#cli-prepopulate-flexcache)
- [List all SnapMirror relationships.](#cli-list-snapmirror-relationships)
- [Trigger a sync operation for an existing SnapMirror relationship.](#cli-sync-snapmirror-relationship)

### Data Volume Management Operations

<a name="cli-clone-volume"></a>

#### Clone a Data Volume

The NetApp Data Science Toolkit can be used to near-instantaneously create a new data volume that is an exact copy of an existing volume. This functionality utilizes NetApp FlexClone technology. This means that any clones created will be extremely storage-space-efficient. Aside from metadata, a clone will not consume additional storage space until its contents starts to deviate from the source volume. The command for cloning a data volume is `./ntap_dsutil.py clone volume`.

The following options/arguments are required:

```
    -n, --name=             Name of new volume..
    -v, --source-volume=    Name of volume to be cloned.
```

The following options/arguments are optional:

```
    -g, --gid=              Unix filesystem group id (gid) to apply when creating new volume (if not specified, gid of source volume will be retained) (Note: cannot apply gid of '0' when creating clone).
    -h, --help              Print help text.
    -m, --mountpoint=       Local mountpoint to mount new volume at after creating. If not specified, new volume will not be mounted locally. On Linux hosts - if specified, must be run as root.
    -s, --source-snapshot=  Name of the snapshot to be cloned (if specified, the clone will be created from a specific snapshot on the source volume as opposed to the current state of the volume).
    -u, --uid=              Unix filesystem user id (uid) to apply when creating new volume (if not specified, uid of source volume will be retained) (Note: cannot apply uid of '0' when creating clone).
```

##### Example Usage

Create a volume named 'project2' that is an exact copy of the volume 'project1'.

```sh
./ntap_dsutil.py clone volume --name=project2 --source-volume=project1
Creating clone volume 'project2' from source volume 'project1'.
Clone volume created successfully.
```

Create a volume named 'project2' that is an exact copy of the contents of volume 'project1' at the time that the snapshot 'snap1' was created, and locally mount the newly created volume at '~/project2'.

```sh
sudo -E ./ntap_dsutil.py clone volume --name=project2 --source-volume=project1 --source-snapshot=snap1 --mountpoint=~/project2
Creating clone volume 'project2' from source volume 'project1'.
Warning: Cannot apply uid of '0' when creating clone; uid of source volume will be retained.
Warning: Cannot apply gid of '0' when creating clone; gid of source volume will be retained.
Clone volume created successfully.
Mounting volume 'project2' at '~/project2'.
Volume mounted successfully.
```

For additional examples, run `./ntap_dsutil.py clone volume -h`.

<a name="cli-create-volume"></a>

#### Create a New Data Volume

The NetApp Data Science Toolkit can be used to rapidly provision a new data volume. The command for creating a new data volume is `./ntap_dsutil.py create volume`.

The following options/arguments are required:

```
    -n, --name=             Name of new volume.
    -s, --size=             Size of new volume. Format: '1024MB', '100GB', '10TB', etc.
```

The following options/arguments are optional:

```
    -a, --aggregate=        Aggregate to use when creating new volume (flexvol volumes only).
    -d, --snapshot-policy=  Snapshot policy to apply for new volume.
    -e, --export-policy=    NFS export policy to use when exporting new volume.
    -g, --gid=              Unix filesystem group id (gid) to apply when creating new volume (ex. '0' for root group).
    -h, --help              Print help text.
    -m, --mountpoint=       Local mountpoint to mount new volume at after creating. If not specified, new volume will not be mounted locally. On Linux hosts - if specified, must be run as root.
    -p, --permissions=      Unix filesystem permissions to apply when creating new volume (ex. '0777' for full read/write permissions for all users and groups).
    -r, --guarantee-space   Guarantee sufficient storage space for full capacity of the volume (i.e. do not use thin provisioning).
    -t, --type=             Volume type to use when creating new volume (flexgroup/flexvol).
    -u, --uid=              Unix filesystem user id (uid) to apply when creating new volume (ex. '0' for root user).
```

##### Example Usage

Create a volume named 'project1' of size 10TB.

```sh
./ntap_dsutil.py create volume --name=project1 --size=10TB
Creating volume 'project1'.
Volume created successfully.
```

Create a volume named 'project2' of size 2TB, and locally mount the newly created volume at '~/project2'.

```sh
sudo -E ./ntap_dsutil.py create volume --name=project2 --size=2TB --mountpoint=~/project2
[sudo] password for ai:
Creating volume 'project2'.
Volume created successfully.
Mounting volume 'project2' at '~/project2'.
Volume mounted successfully.
```

For additional examples, run `./ntap_dsutil.py create volume -h`.

<a name="cli-delete-volume"></a>

#### Delete an Existing Data Volume

The NetApp Data Science Toolkit can be used to near-instantaneously delete an existing data volume. The command for deleting an existing data volume is `./ntap_dsutil.py delete volume`.

The following options/arguments are required:

```
    -n, --name=     Name of volume to be deleted.
```

The following options/arguments are optional:

```
    -f, --force     Do not prompt user to confirm operation.
    -h, --help      Print help text.
```

##### Example Usage

Delete the volume named 'test1'.

```sh
./ntap_dsutil.py delete volume --name=test1
Warning: All data and snapshots associated with the volume will be permanently deleted.
Are you sure that you want to proceed? (yes/no): yes
Deleting volume 'test1'.
Volume deleted successfully.
```

<a name="cli-list-volumes"></a>

#### List All Data Volumes

The NetApp Data Science Toolkit can be used to print a list of all existing data volumes. The command for printing a list of all existing data volumes is `./ntap_dsutil.py list volumes`.

No options/arguments are required for this command.

##### Example Usage

```sh
./ntap_dsutil.py list volumes
Volume Name    Size    Type       NFS Mount Target            Local Mountpoint      FlexCache    Clone    Source Volume    Source Snapshot
-------------  ------  ---------  --------------------------  --------------------  -----------  -------  ---------------  ---------------------------
test5          2.0TB   flexvol    10.61.188.49:/test5                               no           yes      test2            clone_test5.1
test1          10.0TB  flexvol    10.61.188.49:/test1                               no           no
test2          2.0TB   flexvol    10.61.188.49:/test2                               no           no
test4          2.0TB   flexgroup  10.61.188.49:/test4         /mnt/tmp              no           no
ailab_data01   10.0TB  flexvol    10.61.188.49:/ailab_data01                        no           no
home           10.0TB  flexgroup  10.61.188.49:/home                                no           no
ailab_data02   10.0TB  flexvol    10.61.188.49:/ailab_data02                        no           no
project        2.0TB   flexvol    10.61.188.49:/project                             yes          no
test3          2.0TB   flexgroup  10.61.188.49:/test3         /home/ai/test3        no           no
test1_clone    10.0TB  flexvol    10.61.188.49:/test1_clone   /home/ai/test1_clone  no           yes      test1            ntap_dsutil_20201124_172255
```

<a name="cli-mount-volume"></a>

#### Mount an Existing Data Volume Locally

The NetApp Data Science Toolkit can be used to mount an existing data volume on your local host. The command for mounting an existing volume locally is `./ntap_dsutil.py mount volume`. If executed on a Linux host, this command must be run as root. It is usually not necessary to run this command as root on macOS hosts.

The following options/arguments are required:

```
    -m, --mountpoint=       Local mountpoint to mount volume at.
    -n, --name=             Name of volume.
```

##### Example Usage

Locally mount the volume named 'project1' at '~/project1'.

```sh
sudo -E ./ntap_dsutil.py mount volume --name=project1 --mountpoint=~/project1
[sudo] password for ai:
Mounting volume 'project1' at '~/project1'.
Volume mounted successfully.
```

### Snapshot Management Operations

<a name="cli-create-snapshot"></a>

#### Create a New Snapshot for a Data Volume

The NetApp Data Science Toolkit can be used to near-instantaneously save a space-efficient, read-only copy of an existing data volume. These read-only copies are called snapshots. This functionality can be used to version datasets and/or implement dataset-to-model traceability. The command for creating a new snapshot for a specific data volume is `./ntap_dsutil.py create snapshot`.

The following options/arguments are required:

```
    -v, --volume=   Name of volume.
```

The following options/arguments are optional:

```
    -h, --help      Print help text.
    -n, --name=     Name of new snapshot. If not specified, will be set to 'ntap_dsutil_<timestamp>'.
```

##### Example Usage

Create a snapshot named 'final_dataset' for the volume named 'test1'.

```sh
./ntap_dsutil.py create snapshot --volume=test1 --name=final_dataset
Creating snapshot 'final_dataset'.
Snapshot created successfully.
```

Create a snapshot for the volume named 'test1'.

```sh
./ntap_dsutil.py create snapshot -v test1
Creating snapshot 'ntap_dsutil_20201113_125210'.
Snapshot created successfully.
```

<a name="cli-delete-snapshot"></a>

#### Delete an Existing Snapshot for a Data Volume

The NetApp Data Science Toolkit can be used to near-instantaneously delete an existing snapshot for a specific data volume. The command for deleting an existing snapshot for a specific data volume is `./ntap_dsutil.py delete snapshot`.

The following options/arguments are required:

```
    -n, --name=     Name of snapshot to be deleted.
    -v, --volume=   Name of volume.
```

The following options/arguments are optional:

```
    -h, --help      Print help text.
```

##### Example Usage

Delete the snapshot named 'snap1' for the volume named 'test1'.

```sh
./ntap_dsutil.py delete snapshot --volume=test1 --name=snap1
Deleting snapshot 'snap1'.
Snapshot deleted successfully.
```

<a name="cli-list-snapshots"></a>

#### List All Snapshots for a Data Volume

The NetApp Data Science Toolkit can be used to print a list of all existing snapshots for a specific data volume. The command for printing a list of all snapshots for a specific data volume is `./ntap_dsutil.py list snapshots`.

The following options/arguments are required:

```
    -v, --volume=   Name of volume.
```

##### Example Usage

List all snapshots for the volume named 'test1'.

```sh
./ntap_dsutil.py list snapshots --volume=test1
Snapshot Name                Create Time
---------------------------  -------------------------
snap1                        2020-11-13 20:17:48+00:00
ntap_dsutil_20201113_151807  2020-11-13 20:18:07+00:00
snap3                        2020-11-13 21:43:48+00:00
ntap_dsutil_20201113_164402  2020-11-13 21:44:02+00:00
final_dataset                2020-11-13 21:45:16+00:00
```

<a name="cli-restore-snapshot"></a>

#### Restore a Snapshot for a Data Volume

The NetApp Data Science Toolkit can be used to near-instantaneously restore a specific snapshot for a data volume. This action will restore the volume to its exact state at the time that the snapshot was created. The command for restoring a specific snapshot for a data volume is `./ntap_dsutil.py restore snapshot`.

Warning: When you restore a snapshot, all subsequent snapshots are deleted.

The following options/arguments are required:

```
    -n, --name=     Name of snapshot to be restored.
    -v, --volume=   Name of volume.
```

The following options/arguments are optional:

```
    -f, --force     Do not prompt user to confirm operation.
    -h, --help      Print help text.
```

##### Example Usage

Restore the volume 'project2' to its exact state at the time that the snapshot named 'initial_dataset' was created.

Warning: This will delete any snapshots that were created after 'initial_dataset' was created.

```sh
/ntap_dsutil.py restore snapshot --volume=project2 --name=initial_dataset
Warning: When you restore a snapshot, all subsequent snapshots are deleted.
Are you sure that you want to proceed? (yes/no): yes
Restoring snapshot 'initial_dataset'.
Snapshot restored successfully.
```

### Data Fabric Operations

<a name="cli-list-cloud-sync-relationships"></a>

#### List All Cloud Sync Relationships

The NetApp Data Science Toolkit can be used to print a list of all existing Cloud Sync relationships that exist under the user's NetApp Cloud Central account. The command for printing a list of all existing Cloud Sync relationships is `./ntap_dsutil.py list cloud-sync-relationships`.

No options/arguments are required for this command.

Note: To create a new Cloud Sync relationship, visit [cloudsync.netapp.com](https://cloudsync.netapp.com).

##### Example Usage

```sh
./ntap_dsutil.py list cloud-sync-relationships
- id: 5f4cf53cf7f32c000bc61616
  source:
    nfs:
      export: /iguaziovol01
      host: 172.30.0.4
      path: ''
      provider: nfs
      version: '3'
    protocol: nfs
  target:
    nfs:
      export: /cvs-ab7eaeff7a0843108ec494f7cd0e23c5
      host: 172.30.0.4
      path: ''
      provider: cvs
      version: '3'
    protocol: nfs
- id: 5fe2706697a1892a3ae6db55
  source:
    nfs:
      export: /cloud_sync_source
      host: 192.168.200.41
      path: ''
      provider: nfs
      version: '3'
    protocol: nfs
  target:
    nfs:
      export: /trident_pvc_230358ad_8778_4670_a70e_33327c885c6e
      host: 192.168.200.41
      path: ''
      provider: nfs
      version: '3'
    protocol: nfs
```

<a name="cli-sync-cloud-sync-relationship"></a>

#### Trigger a Sync Operation for an Existing Cloud Sync Relationship

The NetApp Data Science Toolkit can be used to trigger a sync operation for an existing Cloud Sync relationshp under the user's NetApp Cloud Central account. NetApp's Cloud Sync service can be used to replicate data to and from a variety of file and object storage platforms. Potential use cases include the following:

- Replicating newly acquired sensor data gathered at the edge back to the core data center or to the cloud to be used for AI/ML model training or retraining.
- Replicating a newly trained or newly updated model from the core data center to the edge or to the cloud to be deployed as part of an inferencing application.
- Replicating data from an S3 data lake to a high-performance AI/ML training environment for use in the training of an AI/ML model.
- Replicating data from a Hadoop data lake (through Hadoop NFS Gateway) to a high-performance AI/ML training environment for use in the training of an AI/ML model.
- Saving a new version of a trained model to an S3 or Hadoop data lake for permanent storage.
- Replicating NFS-accessible data from a legacy or non-NetApp system of record to a high-performance AI/ML training environment for use in the training of an AI/ML model.

The command for triggering a sync operation for an existing Cloud Sync relationship is `./ntap_dsutil.py sync cloud-sync-relationship`.

The following options/arguments are required:

```
    -i, --id=       ID of the relationship for which the sync operation is to be triggered.
```

The following options/arguments are optional:

```
    -h, --help      Print help text.
    -w, --wait      Wait for sync operation to complete before exiting.
```

Tip: Run `./ntap_dsutil.py list cloud-sync-relationships` to obtain the relationship ID.

Note: To create a new Cloud Sync relationship, visit [cloudsync.netapp.com](https://cloudsync.netapp.com).

##### Example Usage

```sh
./ntap_dsutil.py sync cloud-sync-relationship --id=5fe2706697a1892a3ae6db55 --wait
Triggering sync operation for Cloud Sync relationship (ID = 5fe2706697a1892a3ae6db55).
Sync operation successfully triggered.
Sync operation is not yet complete. Status: RUNNING
Checking again in 60 seconds...
Sync operation is not yet complete. Status: RUNNING
Checking again in 60 seconds...
Sync operation is not yet complete. Status: RUNNING
Checking again in 60 seconds...
Success: Sync operation is complete.
```

<a name="cli-pull-from-s3-bucket"></a>

#### Pull the Contents of a Bucket from S3 (multithreaded)

The NetApp Data Science Toolkit can be used to pull the contents of a bucket from S3. The command for pulling the contents of a bucket from S3 is `./ntap_dsutil.py pull-from-s3 bucket`.

Note: To pull to a data volume, the volume must be mounted locally.

Warning: This operation has not been tested at scale and may not be appropriate for extremely large datasets.

The following options/arguments are required:

```
    -b, --bucket=           S3 bucket to pull from.
    -d, --directory=        Local directory to save contents of bucket to.
```

The following options/arguments are optional:

```
    -h, --help              Print help text.
    -p, --key-prefix=       Object key prefix (pull will be limited to objects with key that starts with this prefix).
```

##### Example Usage

Pull all objects in S3 bucket 'project1' and save them to a directory named 'testdl/' on data volume 'project1', which is mounted locally at './test_scripts/test_data/'.

```sh
./ntap_dsutil.py pull-from-s3 bucket --bucket=project1 --directory=./test_scripts/test_data/testdl
Downloading object 'test1.csv' from bucket 'project1' and saving as './test_scripts/test_data/testdl/test1.csv'.
Downloading object 'test2/dup/test3.csv' from bucket 'project1' and saving as './test_scripts/test_data/testdl/test2/dup/test3.csv'.
Downloading object 'test2/dup/test2.csv' from bucket 'project1' and saving as './test_scripts/test_data/testdl/test2/dup/test2.csv'.
Downloading object 'test2/test3/test3.csv' from bucket 'project1' and saving as './test_scripts/test_data/testdl/test2/test3/test3.csv'.
Downloading object 'test2/test2.csv' from bucket 'project1' and saving as './test_scripts/test_data/testdl/test2/test2.csv'.
Download complete.
```

Pull all objects in S3 bucket 'project1' with a key that starts with 'test2/', and save them to local directory './test_scripts/test_data/testdl/'.

```sh
./ntap_dsutil.py pull-from-s3 bucket --bucket=project1 --key-prefix=test2/ --directory=./test_scripts/test_data/testdl
Downloading object 'test2/dup/test3.csv' from bucket 'project1' and saving as './test_scripts/test_data/testdl/test2/dup/test3.csv'.
Downloading object 'test2/test3/test3.csv' from bucket 'project1' and saving as './test_scripts/test_data/testdl/test2/test3/test3.csv'.
Downloading object 'test2/test2.csv' from bucket 'project1' and saving as './test_scripts/test_data/testdl/test2/test2.csv'.
Downloading object 'test2/dup/test2.csv' from bucket 'project1' and saving as './test_scripts/test_data/testdl/test2/dup/test2.csv'.
Download complete.
```

<a name="cli-pull-from-s3-object"></a>

#### Pull an Object from S3

The NetApp Data Science Toolkit can be used to pull an object from S3. The command for pulling an object from S3 is `./ntap_dsutil.py pull-from-s3 object`.

Note: To pull toa data volume, the volume must be mounted locally.

The following options/arguments are required:

```
    -b, --bucket=           S3 bucket to pull from.
    -k, --key=              Key of S3 object to pull.
```

The following options/arguments are optional:

```
    -f, --file=             Local filepath (including filename) to save object to (if not specified, value of -k/--key argument will be used)
    -h, --help              Print help text.
```

##### Example Usage

Pull the object 'test1.csv' from S3 bucket 'testbucket' and save locally as './test_scripts/test_data/test.csv'.

```sh
./ntap_dsutil.py pull-from-s3 object --bucket=testbucket --key=test1.csv --file=./test_scripts/test_data/test.csv
Downloading object 'test1.csv' from bucket 'testbucket' and saving as './test_scripts/test_data/test.csv'.
Download complete.
```

<a name="cli-push-to-s3-directory"></a>

#### Push the Contents of a Directory to S3 (multithreaded)

The NetApp Data Science Toolkit can be used to push the contents of a directory to S3. The command for pushing the contents of a directory to S3 is `./ntap_dsutil.py push-to-s3 directory`.

Note: To push from a data volume, the volume must be mounted locally.

Warning: This operation has not been tested at scale and may not be appropriate for extremely large datasets.

The following options/arguments are required:

```
    -b, --bucket=           S3 bucket to push to.
    -d, --directory=        Local directory to push contents of.
```

The following options/arguments are optional:

```
    -e, --extra-args        Extra args to apply to newly-pushed S3 objects (For details on this field, refer to https://boto3.amazonaws.com/v1/documentation/api/latest/guide/s3-uploading-files.html#the-extraargs-parameter).
    -h, --help              Print help text.
    -p, --key-prefix=       Prefix to add to key for newly-pushed S3 objects (Note: by default, key will be local filepath relative to directory being pushed).
```

##### Example Usage

Push the contents of data volume 'project1', which is mounted locally at 'project1_data/', to S3 bucket 'ailab'; apply the prefix 'test/' to all object keys.

```sh
./ntap_dsutil.py push-to-s3 directory --bucket=ailab --directory=project1_data/ --key-prefix=proj1/
Uploading file 'project1_data/test2/test3/test3.csv' to bucket 'ailab' and applying key 'proj1/test2/test3/test3.csv'.
Uploading file 'project1_data/test2/dup/test3.csv' to bucket 'ailab' and applying key 'proj1/test2/dup/test3.csv'.
Uploading file 'project1_data/test2/test2.csv' to bucket 'ailab' and applying key 'proj1/test2/test2.csv'.
Uploading file 'project1_data/test2/dup/test2.csv' to bucket 'ailab' and applying key 'proj1/test2/dup/test2.csv'.
Uploading file 'project1_data//test1.csv' to bucket 'ailab' and applying key 'proj1/test1.csv'.
Upload complete.
```

Push the contents of the local directory 'test_data/' to S3 bucket 'testbucket'.

```sh
./ntap_dsutil.py push-to-s3 directory --bucket=testbucket --directory=test_data/
Uploading file 'test_data/test2/test3/test3.csv' to bucket 'testbucket' and applying key 'test2/test3/test3.csv'.
Uploading file 'test_data/test2/dup/test3.csv' to bucket 'testbucket' and applying key 'test2/dup/test3.csv'.
Uploading file 'test_data/test2/test2.csv' to bucket 'testbucket' and applying key 'test2/test2.csv'.
Uploading file 'test_data/test2/dup/test2.csv' to bucket 'testbucket' and applying key 'test2/dup/test2.csv'.
Uploading file 'test_data//test1.csv' to bucket 'testbucket' and applying key 'test1.csv'.
Upload complete.
```

<a name="cli-push-to-s3-file"></a>

#### Push a File to S3

The NetApp Data Science Toolkit can be used to push a file to S3. The command for pushing a file to S3 is `./ntap_dsutil.py push-to-s3 file`.

Note: To push from a data volume, the volume must be mounted locally.

The following options/arguments are required:

```
    -b, --bucket=           S3 bucket to push to.
    -f, --file=             Local file to push.
```

The following options/arguments are optional:

```
    -e, --extra-args        Extra args to apply to newly-pushed S3 object (For details on this field, refer to https://boto3.amazonaws.com/v1/documentation/api/latest/guide/s3-uploading-files.html#the-extraargs-parameter).
    -h, --help              Print help text.
    -k, --key=              Key to assign to newly-pushed S3 object (if not specified, key will be set to value of -f/--file argument).
```

##### Example Usage

Push the file 'test_scripts/test_data/test1.csv' to S3 bucket 'testbucket'; assign the key 'test1.csv' to the newly-pushed object.

```sh
./ntap_dsutil.py push-to-s3 file --bucket=testbucket --file=test_scripts/test_data/test1.csv --key=test1.csv
Uploading file 'test_scripts/test_data/test1.csv' to bucket 'testbucket' and applying key 'test1.csv'.
Upload complete.
```

### Advanced Data Fabric Operations

<a name="cli-prepopulate-flexcache"></a>

#### Prepopulate Specific Files/Directories on a FlexCache Volume

The NetApp Data Science Toolkit can be used to prepopulate specific files/directories on a FlexCache volume. This can be usefule when you have a FlexCache volume acting as a local cache for a remote volume, and you want to prepopulate (i.e. hydrate) the cache with specific files/directories. The command for prepopulating specific files/directories on a FlexCache volume is `./ntap_dsutil.py prepopulate flexcache`.

Compatibility: ONTAP 9.8 and above ONLY

The following options/arguments are required:

```
    -n, --name=     Name of FlexCache volume.
    -p, --paths=    Comma-separated list of dirpaths/filepaths to prepopulate.
```

##### Example Usage

Prepopulate the file '/test2/test2.csv' and the contents of the directory '/test2/misc' on a FlexCache volume named 'flexcache_cach'.

```sh
./ntap_dsutil.py prepopulate flexcache --name=flexcache_cache --paths=/test2/misc,/test2/test2.csv
FlexCache 'flexcache_cache' - Prepopulating paths:  ['/test2/misc', '/test2/test2.csv']
FlexCache prepopulated successfully.
```

<a name="cli-list-snapmirror-relationships"></a>

#### List All SnapMirror Relationships

The NetApp Data Science Toolkit can be used to print a list of all existing SnapMirror relationships for which the destination volume resides on the user's storage system. The command for printing a list of all existing SnapMirror relationships is `./ntap_dsutil.py list snapmirror-relationships`.

No options/arguments are required for this command.

Note: To create a new SnapMirror relationship, access ONTAP System Manager.

##### Example Usage

```sh
./ntap_dsutil.py list snapmirror-relationships
UUID                                  Type    Healthy    Current Transfer Status    Source Cluster    Source SVM    Source Volume    Dest Cluster    Dest SVM    Dest Volume
------------------------------------  ------  ---------  -------------------------  ----------------  ------------  ---------------  --------------  ----------  -------------
9e8d14c8-359d-11eb-b94d-005056935ebe  async   True       <NA>                       user's cluster    ailab1        sm01             user's cluster  ailab1      vol_sm01_dest
```

<a name="cli-sync-snapmirror-relationship"></a>

#### Trigger a Sync Operation for an Existing SnapMirror Relationship

The NetApp Data Science Toolkit can be used to trigger a sync operation for an existing SnapMirror relationshp for which the destination volume resides on the user's storage system. NetApp's SnapMirror volume replication technology can be used to quickly and efficiently replicate data between NetApp storage systems. For example, SnapMirror could be used to replicate newly acquired data, gathered on a different NetApp storage system, to the user's NetApp storage system to be used for AI/ML model training or retraining. The command for triggering a sync operation for an existing SnapMirror relationship is `./ntap_dsutil.py sync snapmirror-relationship`.

Tip: Run `./ntap_dsutil.py list snapmirror-relationships` to obtain the relationship UUID.

The following options/arguments are required:

```
    -i, --uuid=     UUID of the relationship for which the sync operation is to be triggered.
```

The following options/arguments are optional:

```
    -h, --help      Print help text.
    -w, --wait      Wait for sync operation to complete before exiting.
```

Note: To create a new SnapMirror relationship, access ONTAP System Manager.

##### Example Usage

```sh
./ntap_dsutil.py sync snapmirror-relationship --uuid=132aab2c-4557-11eb-b542-005056932373 --wait
Triggering sync operation for SnapMirror relationship (UUID = 132aab2c-4557-11eb-b542-005056932373).
Sync operation successfully triggered.
Waiting for sync operation to complete.
Status check will be performed in 10 seconds...
Sync operation is not yet complete. Status: transferring
Checking again in 60 seconds...
Success: Sync operation is complete.
```

<a name="library-of-functions"></a>

## Advanced: Importable Library of Functions

The NetApp Data Science Toolkit can also be utilized as a library of functions that can be imported into any Python program or Jupyter Notebook. In this manner, data scientists and data engineers can easily incorporate data management tasks into their existing projects, programs, and workflows. This functionality is only recommended for advanced users who are proficient in Python.

To import the NetApp Data Science Toolkit library functions into a Python program, ensure that the `ntap_dsutil.py` file is in the same directory as the program, and include the following line of code in the program:

```py
from ntap_dsutil import cloneVolume, createVolume, deleteVolume, listVolumes, mountVolume, createSnapshot, deleteSnapshot, listSnapshots, restoreSnapshot, listCloudSyncRelationships, syncCloudSyncRelationship, pullBucketFromS3, pullObjectFromS3, pushDirectoryToS3. pushFileToS3, prepopulateFlexCache, listSnapMirrorRelationships, syncSnapMirrorRelationship
```

Note: The prerequisite steps outlined in the [Getting Started](#getting-started) section still appy when the toolkit is being utilized as an importable library of functions.

When being utilized as an importable library of functions, the toolkit supports the following operations.

Data volume management operations:
- [Clone a data volume.](#lib-clone-volume)
- [Create a new data volume.](#lib-create-volume)
- [Delete an existing data volume.](#lib-delete-volume)
- [List all data volumes.](#lib-list-volumes)
- [Mount an existing data volume locally.](#lib-mount-volume)

Snapshot management operations:
- [Create a new snapshot for a data volume.](#lib-create-snapshot)
- [Delete an existing snapshot for a data volume.](#lib-delete-snapshot)
- [List all snapshots for a data volume.](#lib-list-snapshots)
- [Restore a snapshot for a data volume.](#lib-restore-snapshot)

Data fabric operations:
- [List all Cloud Sync relationships.](#lib-list-cloud-sync-relationships)
- [Trigger a sync operation for an existing Cloud Sync relationship.](#lib-sync-cloud-sync-relationship)
- [Pull the contents of a bucket from S3 (multithreaded).](#lib-pull-from-s3-bucket)
- [Pull an object from S3.](#lib-pull-from-s3-object)
- [Push the contents of a directory to S3 (multithreaded).](#lib-push-to-s3-directory)
- [Push a file to S3.](#lib-push-to-s3-file)

Advanced data fabric operations:
- [Prepopulate specific files/directories on a FlexCache volume (ONTAP 9.8 and above ONLY).](#lib-prepopulate-flexcache)
- [List all SnapMirror relationships.](#lib-list-snapmirror-relationships)
- [Trigger a sync operation for an existing SnapMirror relationship.](#lib-sync-snapmirror-relationship)

### Examples

[Examples.ipynb](Examples.ipynb) is a Jupyter Notebook that contains examples that demonstrate how the NetApp Data Science Toolkit can be utilized as an importable library of functions.

### Data Volume Management Operations

<a name="lib-clone-volume"></a>

#### Clone a Data Volume

The NetApp Data Science Toolkit can be used to near-instantaneously create a new data volume that is an exact copy of an existing volume as part of any Python program or workflow. This functionality utilizes NetApp FlexClone technology. This means that any clones created will be extremely storage-space-efficient. Aside from metadata, a clone will not consume additional storage space until its contents starts to deviate from the source volume.

##### Function Definition

```py
def cloneVolume(
    newVolumeName: str,             # Name of new volume (required).
    sourceVolumeName: str,          # Name of volume to be cloned (required).
    sourceSnapshotName: str = None, # Name of the snapshot to be cloned (if specified, the clone will be created from a specific snapshot on the source volume as opposed to the current state of the volume).
    unixUID: str = None,            # Unix filesystem user id (uid) to apply when creating new volume (if not specified, uid of source volume will be retained) (Note: cannot apply uid of '0' when creating clone).
    unixGID: str = None,            # Unix filesystem group id (gid) to apply when creating new volume (if not specified, gid of source volume will be retained) (Note: cannot apply gid of '0' when creating clone).
    mountpoint: str = None,         # Local mountpoint to mount new volume at. If not specified, volume will not be mounted locally. On Linux hosts - if specified, calling program must be run as root.
    printOutput: bool = False       # Denotes whether or not to print messages to the console during execution.
) :
```

##### Return Value

None

##### Error Handling

If an error is encountered, the function will raise an exception of one of the following types. These exception types are defined in `ntap_dsutil.py`.

```py
InvalidConfigError              # Config file is missing or contains an invalid value.
APIConnectionError              # The storage system/service API returned an error.
InvalidVolumeParameterError     # An invalid parameter was specified.
InvalidSnapshotParameterError   # An invalid parameter was specified.
MountOperationError             # The volume was not succesfully mounted locally.
```

<a name="lib-create-volume"></a>

#### Create a New Data Volume

The NetApp Data Science Toolkit can be used to rapidly provision a new data volume as part of any Python program or workflow.

##### Function Definition

```py
def createVolume(
    volumeName: str,                # Name of new volume (required).
    volumeSize: str,                # Size of new volume (required). Format: '1024MB', '100GB', '10TB', etc.
    guaranteeSpace: bool = False,   # Guarantee sufficient storage space for full capacity of the volume (i.e. do not use thin provisioning).
    volumeType: str = "flexvol",    # Volume type to use when creating new volume (flexgroup/flexvol).
    unixPermissions: str = "0777",  # Unix filesystem permissions to apply when creating new volume (ex. '0777' for full read/write permissions for all users and groups).
    unixUID: str = "0",             # Unix filesystem user id (uid) to apply when creating new volume (ex. '0' for root user).
    unixGID: str = "0",             # Unix filesystem group id (gid) to apply when creating new volume (ex. '0' for root group).
    exportPolicy: str = "default",  # NFS export policy to use when exporting new volume.
    snapshotPolicy: str = "none",   # Snapshot policy to apply for new volume.
    aggregate: str = None,          # Aggregate to use when creating new volume (flexvol volumes only).
    mountpoint: str = None,         # Local mountpoint to mount new volume at. If not specified, volume will not be mounted locally. On Linux hosts - if specified, calling program must be run as root.
    printOutput: bool = False       # Denotes whether or not to print messages to the console during execution.
) :
```

##### Return Value

None

##### Error Handling

If an error is encountered, the function will raise an exception of one of the following types. These exception types are defined in `ntap_dsutil.py`.

```py
InvalidConfigError              # Config file is missing or contains an invalid value.
APIConnectionError              # The storage system/service API returned an error.
InvalidVolumeParameterError     # An invalid parameter was specified.
MountOperationError             # The volume was not succesfully mounted locally.
```

<a name="lib-delete-volume"></a>

#### Delete an Existing Data Volume

The NetApp Data Science Toolkit can be used to near-instantaneously delete an existing data volume as part of any Python program or workflow. 

##### Function Definition

```py
def deleteVolume(
    volumeName: str,            # Name of volume (required).
    printOutput: bool = False   # Denotes whether or not to print messages to the console during execution.
) :
```

##### Return Value

None

##### Error Handling

If an error is encountered, the function will raise an exception of one of the following types. These exception types are defined in `ntap_dsutil.py`.

```py
InvalidConfigError              # Config file is missing or contains an invalid value.
APIConnectionError              # The storage system/service API returned an error.
InvalidVolumeParameterError     # An invalid parameter was specified.
```

<a name="lib-list-volumes"></a>

#### List All Data Volumes

The NetApp Data Science Toolkit can be used to retrieve a list of all existing data volumes as part of any Python program or workflow.

##### Function Definition

```py
def listVolumes(
    checkLocalMounts: bool = False,     # If set to true, then the local mountpoints of any mounted volumes will be included in the returned list and included in printed output.
    printOutput: bool = False           # Denotes whether or not to print messages to the console during execution.
) -> list() :
```

##### Return Value

The function returns a list of all existing volumes. Each item in the list will be a dictionary containing details regarding a specific volume. The keys for the values in this dictionary are "Volume Name", "Size", "Type", "NFS Mount Target", "FlexCache" (yes/no), "Clone" (yes/no), "Source Volume", "Source Snapshot". If `checkLocalMounts` is set to `True`, then "Local Mountpoint" will also be included as a key in the dictionary.

##### Error Handling

If an error is encountered, the function will raise an exception of one of the following types. These exception types are defined in `ntap_dsutil.py`.

```py
InvalidConfigError              # Config file is missing or contains an invalid value.
APIConnectionError              # The storage system/service API returned an error.
```

<a name="lib-mount-volume"></a>

#### Mount an Existing Data Volume Locally

The NetApp Data Science Toolkit can be used to mount an existing data volume on your local host as part of any Python program or workflow. On Linux hosts, mounting requires root privileges, so any Python program that invokes this function must be run as root. It is usually not necessary to invoke this function as root on macOS hosts.

##### Function Definition

```py
def mountVolume(
    volumeName: str,            # Name of volume (required).
    mountpoint: str,            # Local mountpoint to mount volume at (required).
    printOutput: bool = False   # Denotes whether or not to print messages to the console during execution.
) :
```

##### Return Value

None

##### Error Handling

If an error is encountered, the function will raise an exception of one of the following types. These exception types are defined in `ntap_dsutil.py`.

```py
InvalidConfigError              # Config file is missing or contains an invalid value.
APIConnectionError              # The storage system/service API returned an error.
InvalidVolumeParameterError     # An invalid parameter was specified.
MountOperationError             # The volume was not succesfully mounted locally.
```

### Snapshot Management Operations

<a name="lib-create-snapshot"></a>

#### Create a New Snapshot for a Data Volume

The NetApp Data Science Toolkit can be used to near-instantaneously save a space-efficient, read-only copy of an existing data volume as part of any Python program or workflow. These read-only copies are called snapshots. This functionality can be used to version datasets and/or implement dataset-to-model traceability.

##### Function Definition

```py
def createSnapshot(
    volumeName: str,                    # Name of volume (required).
    snapshotName: str = None,           # Name of new snapshot. If not specified, will be set to 'ntap_dsutil_<timestamp>'.
    printOutput: bool = False           # Denotes whether or not to print messages to the console during execution.
) :
```

##### Return Value

None

##### Error Handling

If an error is encountered, the function will raise an exception of one of the following types. These exception types are defined in `ntap_dsutil.py`.

```py
InvalidConfigError              # Config file is missing or contains an invalid value.
APIConnectionError              # The storage system/service API returned an error.
InvalidVolumeParameterError     # An invalid parameter was specified.
```

<a name="lib-delete-snapshot"></a>

#### Delete an Existing Snapshot for a Data Volume

The NetApp Data Science Toolkit can be used to near-instantaneously delete an existing snapshot for a specific data volume as part of any Python program or workflow. 

##### Function Definition

```py
def deleteSnapshot(
    volumeName: str,            # Name of volume (required).
    snapshotName: str,          # Name of snapshot to be deleted (required).
    printOutput: bool = False   # Denotes whether or not to print messages to the console during execution.
) :
```

##### Return Value

None

##### Error Handling

If an error is encountered, the function will raise an exception of one of the following types. These exception types are defined in `ntap_dsutil.py`.

```py
InvalidConfigError              # Config file is missing or contains an invalid value.
APIConnectionError              # The storage system/service API returned an error.
InvalidSnapshotParameterError   # An invalid parameter was specified.
InvalidVolumeParameterError     # An invalid parameter was specified.
```

<a name="lib-list-snapshots"></a>

#### List All Existing Snapshots for a Data Volume

The NetApp Data Science Toolkit can be used to retrieve a list of all existing snapshots for a specific data volume as part of any Python program or workflow.

##### Function Definition

```py
def listSnapshots(
    volumeName: str,            # Name of volume.
    printOutput: bool = False   # Denotes whether or not to print messages to the console during execution.
) -> list() :
```

##### Return Value

The function returns a list of all existing snapshots for the specific data volume. Each item in the list will be a dictionary containing details regarding a specific snapshot. The keys for the values in this dictionary are "Snapshot Name", "Create Time".

##### Error Handling

If an error is encountered, the function will raise an exception of one of the following types. These exception types are defined in `ntap_dsutil.py`.

```py
InvalidConfigError              # Config file is missing or contains an invalid value.
APIConnectionError              # The storage system/service API returned an error.
InvalidVolumeParameterError     # An invalid parameter was specified.
```

<a name="lib-restore-snapshot"></a>

#### Restore a Snapshot for a Data Volume

The NetApp Data Science Toolkit can be used to near-instantaneously restore a specific snapshot for a data volume as part of any Python program or workflow. This action will restore the volume to its exact state at the time that the snapshot was created.

Warning: A snapshot restore operation will delete all snapshots that were created after the snapshot that you are restoring.

##### Function Definition

```py
def restoreSnapshot(
    volumeName: str,            # Name of volume (required).
    snapshotName: str,          # Name of snapshot to be restored (required).
    printOutput: bool = False   # Denotes whether or not to print messages to the console during execution.
) :
```

##### Return Value

None

##### Error Handling

If an error is encountered, the function will raise an exception of one of the following types. These exception types are defined in `ntap_dsutil.py`.

```py
InvalidConfigError              # Config file is missing or contains an invalid value.
APIConnectionError              # The storage system/service API returned an error.
InvalidSnapshotParameterError   # An invalid parameter was specified.
InvalidVolumeParameterError     # An invalid parameter was specified.
```

### Data Fabric Operations

<a name="lib-list-cloud-sync-relationships"></a>

#### List All Cloud Sync Relationships

The NetApp Data Science Toolkit can be used to retrieve a list of all existing Cloud Sync relationships that exist under the user's NetApp Cloud Central account, as part of any Python program or workflow.

Note: To create a new Cloud Sync relationship, visit [cloudsync.netapp.com](https://cloudsync.netapp.com).

##### Function Definition

```py
def listCloudSyncRelationships(
    printOutput: bool = False   # Denotes whether or not to print messages to the console during execution.
) -> list() :
```

##### Return Value

The function returns a list of all existing Cloud Sync relationships. Each item in the list will be a dictionary containing details regarding a specific Cloud Sync relationship. The keys for the values in this dictionary are "id", "source", "target".

##### Error Handling

If an error is encountered, the function will raise an exception of one of the following types. These exception types are defined in `ntap_dsutil.py`.

```py
InvalidConfigError              # Config file is missing or contains an invalid value.
APIConnectionError              # The Cloud Sync API returned an error.
```

<a name="lib-sync-cloud-sync-relationship"></a>

#### Trigger a Sync Operation for an Existing Cloud Sync Relationship

The NetApp Data Science Toolkit can be used to trigger a sync operation for an existing Cloud Sync relationshp under the user's NetApp Cloud Central account, as part of any Python program or workflow. NetApp's Cloud Sync service can be used to replicate data to and from a variety of file and object storage platforms. Potential use cases include the following:

- Replicating newly acquired sensor data gathered at the edge back to the core data center or to the cloud to be used for AI/ML model training or retraining.
- Replicating a newly trained or newly updated model from the core data center to the edge or to the cloud to be deployed as part of an inferencing application.
- Replicating data from an S3 data lake to a high-performance AI/ML training environment for use in the training of an AI/ML model.
- Replicating data from a Hadoop data lake (through Hadoop NFS Gateway) to a high-performance AI/ML training environment for use in the training of an AI/ML model.
- Saving a new version of a trained model to an S3 or Hadoop data lake for permanent storage.
- Replicating NFS-accessible data from a legacy or non-NetApp system of record to a high-performance AI/ML training environment for use in the training of an AI/ML model.

Tip: Use the listCloudSyncRelationships() function to obtain the relationship ID.

Note: To create a new Cloud Sync relationship, visit [cloudsync.netapp.com](https://cloudsync.netapp.com).

##### Function Definition

```py
def syncCloudSyncRelationship(
    relationshipID: str,                # ID of the relationship for which the sync operation is to be triggered (required).
    waitUntilComplete: bool = False,    # Denotes whether or not to wait for sync operation to complete before returning.
    printOutput: bool = False           # Denotes whether or not to print messages to the console during execution.
) :
```

##### Return Value

None

##### Error Handling

If an error is encountered, the function will raise an exception of one of the following types. These exception types are defined in `ntap_dsutil.py`.

```py
InvalidConfigError              # Config file is missing or contains an invalid value.
APIConnectionError              # The Cloud Sync API returned an error.
CloudSyncSyncOperationError     # The sync operation failed.
```

<a name="lib-pull-from-s3-bucket"></a>

#### Pull the Contents of a Bucket S3 (multithreaded)

The NetApp Data Science Toolkit can be used to pull the contents of a bucket from S3 as part of any Python program or workflow.

Note: To pull to a data volume, the volume must be mounted locally.

Warning: This operation has not been tested at scale and may not be appropriate for extremely large datasets.

##### Function Definition

```py
def pullBucketFromS3(
    s3Bucket: str,                  # S3 bucket to pull from (required).
    localDirectory: str,            # Local directory to save contents of bucket to (required).
    s3ObjectKeyPrefix: str = "",    # Object key prefix (pull will be limited to objects with key that starts with this prefix).
    printOutput: bool = False       # Denotes whether or not to print messages to the console during execution.
) :
```

##### Return Value

None

##### Error Handling

If an error is encountered, the function will raise an exception of one of the following types. These exception types are defined in `ntap_dsutil.py`.

```py
InvalidConfigError              # Config file is missing or contains an invalid value.
APIConnectionError              # The S3 API returned an error.
```

<a name="lib-pull-from-s3-object"></a>

#### Pull an Object from S3

The NetApp Data Science Toolkit can be used to pull an object from S3 as part of any Python program or workflow.

Note: To pull to a data volume, the volume must be mounted locally.

##### Function Definition

```py
def pullObjectFromS3(
    s3Bucket: str,              # S3 bucket to pull from. (required).
    s3ObjectKey: str,           # Key of S3 object to pull (required).
    localFile: str = None,      # Local filepath (including filename) to save object to (if not specified, value of s3ObjectKey argument will be used).
    printOutput: bool = False   # Denotes whether or not to print messages to the console during execution.
) :
```

##### Return Value

None

##### Error Handling

If an error is encountered, the function will raise an exception of one of the following types. These exception types are defined in `ntap_dsutil.py`.

```py
InvalidConfigError              # Config file is missing or contains an invalid value.
APIConnectionError              # The S3 API returned an error.
```

<a name="lib-push-to-s3-directory"></a>

#### Push the Contents of a Directory to S3 (multithreaded)

The NetApp Data Science Toolkit can be used to push the contents of a directory to S3 as part of any Python program or workflow.

Note: To push from a data volume, the volume must be mounted locally.

Warning: This operation has not been tested at scale and may not be appropriate for extremely large datasets.

##### Function Definition

```py
def pushDirectoryToS3(
    s3Bucket: str,                  # S3 bucket to push to (required).
    localDirectory: str,            # Local directory to push contents of (required).
    s3ObjectKeyPrefix: str = "",    # Prefix to add to key for newly-pushed S3 objects (Note: by default, key will be local filepath relative to directory being pushed).
    s3ExtraArgs: str = None,        # Extra args to apply to newly-pushed S3 objects (For details on this field, refer to https://boto3.amazonaws.com/v1/documentation/api/latest/guide/s3-uploading-files.html#the-extraargs-parameter).
    printOutput: bool = False       # Denotes whether or not to print messages to the console during execution.
) :
```

##### Return Value

None

##### Error Handling

If an error is encountered, the function will raise an exception of one of the following types. These exception types are defined in `ntap_dsutil.py`.

```py
InvalidConfigError              # Config file is missing or contains an invalid value.
APIConnectionError              # The S3 API returned an error.
```

<a name="lib-push-to-s3-file"></a>

#### Push a File to S3

The NetApp Data Science Toolkit can be used to push a file to S3 as part of any Python program or workflow.

Note: To push from a data volume, the volume must be mounted locally.

##### Function Definition

```py
def pushFileToS3(
    s3Bucket: str,              # S3 bucket to push to (required).
    localFile: str,             # Local file to push (required).
    s3ObjectKey: str = None,    # Key to assign to newly-pushed S3 object (if not specified, key will be set to value of localFile).
    s3ExtraArgs: str = None,    # Extra args to apply to newly-pushed S3 object (For details on this field, refer to https://boto3.amazonaws.com/v1/documentation/api/latest/guide/s3-uploading-files.html#the-extraargs-parameter).
    printOutput: bool = False   # Denotes whether or not to print messages to the console during execution.
) :
```

##### Return Value

None

##### Error Handling

If an error is encountered, the function will raise an exception of one of the following types. These exception types are defined in `ntap_dsutil.py`.

```py
InvalidConfigError              # Config file is missing or contains an invalid value.
APIConnectionError              # The S3 API returned an error.
```

### Advanced Data Fabric Operations

<a name="lib-prepopulate-flexcache"></a>

#### Prepopulate Specific Files/Directories on a FlexCache Volume

The NetApp Data Science Toolkit can be used to prepopulate specific files/directories on a FlexCache volume as part of any Python program or workflow. This can be usefule when you have a FlexCache volume acting as a local cache for a remote volume, and you want to prepopulate (i.e. hydrate) the cache with specific files/directories.

Compatibility: ONTAP 9.8 and above ONLY

##### Function Definition

```py
def prepopulateFlexCache(
    volumeName: str,            # Name of FlexCache volume (required).
    paths: list,                # List of dirpaths/filepaths to prepopulate (required).
    printOutput: bool = False
) :
```

##### Return Value

None

##### Error Handling

If an error is encountered, the function will raise an exception of one of the following types. These exception types are defined in `ntap_dsutil.py`.

```py
InvalidConfigError              # Config file is missing or contains an invalid value.
APIConnectionError              # The storage system/service API returned an error.
InvalidVolumeParameterError     # An invalid parameter was specified.
```

<a name="lib-list-snapmirror-relationships"></a>

#### List All SnapMirror Relationships

The NetApp Data Science Toolkit can be used to retrieve a list of all existing SnapMirror relationships for which the destination volume resides on the user's storage system, as part of any Python program or workflow.

Note: To create a new SnapMirror relationship, access ONTAP System Manager.

##### Function Definition

```py
def listSnapMirrorRelationships(
    printOutput: bool = False   # Denotes whether or not to print messages to the console during execution.
) -> list() :
```

##### Return Value

The function returns a list of all existing SnapMirror relationships for which the destination volume resides on the user's storage system. Each item in the list will be a dictionary containing details regarding a specific SnapMirror relationship. The keys for the values in this dictionary are "UUID", "Type", "Healthy", "Current Transfer Status", "Source Cluster", "Source SVM", "Source Volume", "Dest Cluster", "Dest SVM", "Dest Volume".

##### Error Handling

If an error is encountered, the function will raise an exception of one of the following types. These exception types are defined in `ntap_dsutil.py`.

```py
InvalidConfigError              # Config file is missing or contains an invalid value.
APIConnectionError              # The storage system/service API returned an error.
```

<a name="lib-sync-snapmirror-relationship"></a>

#### Trigger a Sync Operation for an Existing SnapMirror Relationship

The NetApp Data Science Toolkit can be used to trigger a sync operation for an existing SnapMirror relationshp for which the destination volume resides on the user's storage system, as part of any Python program or workflow. NetApp's SnapMirror volume replication technology can be used to quickly and efficiently replicate data between NetApp storage systems. For example, SnapMirror could be used to replicate newly acquired data, gathered on a different NetApp storage system, to the user's NetApp storage system to be used for AI/ML model training or retraining.

Tip: Use the listSnapMirrorRelationships() function to obtain the UUID.

Note: To create a new SnapMirror relationship, access ONTAP System Manager.

##### Function Definition

```py
def syncSnapMirrorRelationship(
    uuid: str,                          # UUID of the relationship for which the sync operation is to be triggered (required).
    waitUntilComplete: bool = False,    # Denotes whether or not to wait for sync operation to complete before returning.
    printOutput: bool = False           # Denotes whether or not to print messages to the console during execution.
) :
```

##### Return Value

None

##### Error Handling

If an error is encountered, the function will raise an exception of one of the following types. These exception types are defined in `ntap_dsutil.py`.

```py
InvalidConfigError                  # Config file is missing or contains an invalid value.
APIConnectionError                  # The storage system/service API returned an error.
SnapMirrorSyncOperationError        # The sync operation failed.
InvalidSnapMirrorParameterError     # An invalid parameter was specified.
```

## Support

Report any issues via GitHub: https://github.com/NetApp/netapp-data-science-toolkit/issues.
