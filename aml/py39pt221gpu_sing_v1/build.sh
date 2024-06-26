registry="singularitybase"
validator_image_repo="validations/base/singularity-tests"
installer_image_repo="installer/base/singularity-installer"
image_framework="PYTORCH"
image_accelerator="NVIDIA"
image_sku=""

az acr login -n $registry

base_image="nvidia/cuda:11.8.0-cudnn8-devel-ubuntu18.04"

validator_image_tag=`az acr repository show-manifests \
    --name $registry \
    --repository $validator_image_repo \
    --orderby time_desc \
    --query '[].{Tag:tags[0]}' \
    --output tsv --top 1`

validator_image="$registry.azurecr.io/$validator_image_repo:$validator_image_tag"

installer_image_tag=`az acr repository show-manifests \
    --name $registry \
    --repository $installer_image_repo \
    --orderby time_desc \
    --query '[].{Tag:tags[0]}' \
    --output tsv --top 1`

installer_image="$registry.azurecr.io/$installer_image_repo:$installer_image_tag"

build_str="docker build -t new . -f Dockerfile \
    --build-arg BASE_IMAGE=$base_image \
    --build-arg INSTALLER_IMAGE=$installer_image \
    --build-arg VALIDATOR_IMAGE=$validator_image \
    --build-arg IMAGE_FRAMEWORK=$image_framework \
    --build-arg IMAGE_ACCELERATOR=$image_sku \
    --progress=plain"

echo "$build_str"

eval $build_str
