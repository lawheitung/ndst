# Kubeflow Pipeline Definition: Clone Volume

import kfp.compiler as compiler
import kfp.dsl as dsl

# Define Kubeflow pipeline
@dsl.pipeline(
    name="Clone Volume",
    description="Template for cloning a volume in Kubernetes."
)
def clone_volume(
    # Define variables that the user can set in the pipelines UI; set default values
    source_volume_pvc_name: str = "gold-datavol",
    new_volume_pvc_name: str = "datavol-clone-1",
    clone_from_snapshot__yes_or_no: str = "no",
    source_volume_snapshot_name: str = "n/a"
) :
    # Pipeline Steps:
    
    # Create a clone of the source volume
    name = "clone-volume"
    image = "python:3"
    command = ["/bin/bash", "-c"]
    file_outputs = {"new_volume_pvc_name": "/new_volume_pvc_name.txt"}
    args = "\
        python3 -m pip install ipython kubernetes pandas tabulate && \
        git clone https://github.com/NetApp/netapp-data-science-toolkit && \
        mv /netapp-data-science-toolkit/Kubernetes/ntap_dsutil_k8s.py / && \
        echo '" + str(new_volume_pvc_name) + "' > /new_volume_pvc_name.txt && \
        /ntap_dsutil_k8s.py clone volume --namespace={{workflow.namespace}} --new-pvc-name=" + str(new_volume_pvc_name)
    with dsl.Condition(clone_from_snapshot__yes_or_no == "yes") :
        clone_volume = dsl.ContainerOp(
            name=name+"-from-snapshot",
            image=image,
            command=command,
            arguments=[args + " --source-snapshot-name=" + str(source_volume_snapshot_name)],
            file_outputs=file_outputs
        )
    with dsl.Condition(clone_from_snapshot__yes_or_no == "no") :
        clone_volume = dsl.ContainerOp(
            name=name,
            image=image,
            command=command,
            arguments=[args + " --source-pvc-name=" + str(source_volume_pvc_name)],
            file_outputs=file_outputs
        )

if __name__ == '__main__' :
    compiler.Compiler().compile(clone_volume, __file__ + '.yaml')
