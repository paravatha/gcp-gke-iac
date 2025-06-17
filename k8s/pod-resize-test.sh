# create a pod with a container that has resource requests and limits
k apply -f pod.yaml
# check the pod status
k get pod resize-demo --output=yaml

# resize the pod cpu using the resize subresource
k patch pod resize-demo --subresource resize --patch \
  '{"spec":{"containers":[{"name":"pause", "resources":{"requests":{"cpu":"800m"}, "limits":{"cpu":"800m"}}}]}}'
# check the pod status again
k get pod resize-demo --output=yaml

k get po
# pod RESTARTS should be 0

# resize the pod memory using the resize subresource
k patch pod resize-demo --subresource resize --patch \
  '{"spec":{"containers":[{"name":"pause", "resources":{"requests":{"memory":"300Mi"}, "limits":{"memory":"300Mi"}}}]}}'

# check the pod status again
k get pod resize-demo --output=yaml

# pod RESTARTS should be 1