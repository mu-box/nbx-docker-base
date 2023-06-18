UUID=$(cat /proc/sys/kernel/random/uuid)
pass "unable to start the container" docker run -d --name $UUID mubox/nbx-data
defer docker stop $UUID
defer docker rm $UUID

# now we just need to verify that the image is setup correctly
