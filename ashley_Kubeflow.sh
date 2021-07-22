#!/bin/bash


cat << EOF > ./RBAC-snapshot-controller.yaml
# RBAC file for the snapshot controller.
#
# The snapshot controller implements the control loop for CSI snapshot functionality.
# It should be installed as part of the base Kubernetes distribution in an appropriate
# namespace for components implementing base system functionality. For installing with
# Vanilla Kubernetes, kube-system makes sense for the namespace.

apiVersion: v1
kind: ServiceAccount
metadata:
  name: snapshot-controller
  namespace: anonymous # TODO: replace with the namespace you want for your controller, e.g. kube-system

---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  # rename if there are conflicts
  name: snapshot-controller-runner
rules:
  - apiGroups: [""]
    resources: ["persistentvolumes"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["persistentvolumeclaims"]
    verbs: ["get", "list", "watch", "update"]
  - apiGroups: ["storage.k8s.io"]
    resources: ["storageclasses"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["events"]
    verbs: ["list", "watch", "create", "update", "patch"]
  - apiGroups: ["snapshot.storage.k8s.io"]
    resources: ["volumesnapshotclasses"]
    verbs: ["get", "list", "watch"]
  - apiGroups: ["snapshot.storage.k8s.io"]
    resources: ["volumesnapshotcontents"]
    verbs: ["create", "get", "list", "watch", "update", "delete"]
  - apiGroups: ["snapshot.storage.k8s.io"]
    resources: ["volumesnapshots"]
    verbs: ["get", "list", "watch", "update"]
  - apiGroups: ["snapshot.storage.k8s.io"]
    resources: ["volumesnapshots/status"]
    verbs: ["update"]

---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: snapshot-controller-role
subjects:
  - kind: ServiceAccount
    name: snapshot-controller
    namespace: anonymous # TODO: replace with the namespace you want for your controller, e.g. kube-system
roleRef:
  kind: ClusterRole
  # change the name also here if the ClusterRole gets renamed
  name: snapshot-controller-runner
  apiGroup: rbac.authorization.k8s.io

---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: anonymous # TODO: replace with the namespace you want for your controller, e.g. kube-system
  name: snapshot-controller-leaderelection
rules:
- apiGroups: ["coordination.k8s.io"]
  resources: ["leases"]
  verbs: ["get", "watch", "list", "delete", "update", "create"]

---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: snapshot-controller-leaderelection
  namespace: anonymous # TODO: replace with the namespace you want for your controller, e.g. kube-system
subjects:
  - kind: ServiceAccount
    name: snapshot-controller
    namespace: anonymous # TODO: replace with the namespace you want for your controller, e.g. kube-system
roleRef:
  kind: Role
  name: snapshot-controller-leaderelection
  apiGroup: rbac.authorization.k8s.io
EOF


cat << EOF > ./snapshot-controller-deployment.yaml
# This YAML file shows how to deploy the snapshot controller

# The snapshot controller implements the control loop for CSI snapshot functionality.
# It should be installed as part of the base Kubernetes distribution in an appropriate
# namespace for components implementing base system functionality. For installing with
# Vanilla Kubernetes, kube-system makes sense for the namespace.

---
kind: StatefulSet
apiVersion: apps/v1
metadata:
  name: snapshot-controller
  namespace: anonymous # TODO: replace with the namespace you want for your controller, e.g. kube-system
spec:
  serviceName: "snapshot-controller"
  replicas: 1
  selector:
    matchLabels:
      app: snapshot-controller
  template:
    metadata:
      labels:
        app: snapshot-controller
    spec:
      serviceAccount: snapshot-controller
      containers:
        - name: snapshot-controller
          image: k8s.gcr.io/sig-storage/snapshot-controller:v3.0.3
          args:
            - "--v=5"
            - "--leader-election=false"
          imagePullPolicy: IfNotPresent
EOF


kubectl apply -f RBAC-snapshot-controller.yaml
kubectl apply -f snapshot-controller-deployment.yaml


cat << EOF > ./snapshot-setup.sh
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/release-3.0/client/config/crd/snapshot.storage.k8s.io_volumesnapshotclasses.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/release-3.0/client/config/crd/snapshot.storage.k8s.io_volumesnapshotcontents.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/release-3.0/client/config/crd/snapshot.storage.k8s.io_volumesnapshots.yaml
EOF

chmod 755 snapshot-setup.sh

./snapshot-setup.sh


cat << EOF > ./snap-sc.yaml
#Use apiVersion v1 for Kubernetes 1.20 and above. For Kubernetes 1.17 - 1.19, use apiVersion v1beta1.
apiVersion: snapshot.storage.k8s.io/v1beta1
kind: VolumeSnapshotClass
metadata:
  name: csi-snapclass
driver: csi.trident.netapp.io
deletionPolicy: Delete
EOF


kubectl apply -f snap-sc.yaml



cat << EOF > ./snap.yaml
#Use apiVersion v1 for Kubernetes 1.20 and above. For Kubernetes 1.17 - 1.19, use apiVersion v1beta1.
apiVersion: snapshot.storage.k8s.io/v1beta1
kind: VolumeSnapshot
metadata:
  name: pvc1-snap
spec:
  volumeSnapshotClassName: csi-snapclass
  source:
    persistentVolumeClaimName: pvc1
EOF


kubectl apply -f snap.yaml


cat << EOF > ./pvc-dataset-vol-kubeflow.yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: dataset-vol
  namespace: anonymous
spec:
  accessModes: 
    - ReadWriteMany
  resources:
    requests:
     storage: 10Gi
  storageClassName: storage-class-nas
EOF

cat << EOF > ./pvc-kfp-model-vol-kubeflow.yaml

kind: PersistentVolumeClaim

apiVersion: v1

metadata:

 name: kfp-model-vol

 namespace: anonymous

spec:

 resources:
  
  requests:

   storage: 10Gi

 accessModes:

 - ReadWriteMany

 storageClassName: storage-class-nas
EOF



kubectl apply -f pvc-dataset-vol-kubeflow.yaml
kubectl apply -f pvc-kfp-model-vol-kubeflow.yaml



cd netapp-dataops-toolkit/netapp_dataops_k8s/Examples/Kubeflow/Pipelines

kubectl apply -f cluster-role-netapp-dataops.yaml
