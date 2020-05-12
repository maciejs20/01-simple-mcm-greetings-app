# Clone the repo

Create the directory to hold the workshop and cd into it:

```
mkdir mcm-workshop
cd mcm-workshop
```

now clone the app repository:

```
git clone https://github.com/maciejs20/01-simple-mcm-greetings-app.git
```

enter the greetings repository:

```
cd 01-simple-mcm-greetings-app
```









## Channels

The channel resource defines the location of an resource to be deployed. These resources can be a Helm repository, Kubernetes namespace, Object store or Git repository.

```
apiVersion: app.ibm.com/v1alpha1
kind: Channel
metadata:
  name: greetings
  namespace: greetings-channel-ns
  labels:
    app: greetings-app
    subApp: greetings-channel
spec:
  type: Namespace
  pathname: greetings-channel-ns
  sourceNamespaces:
    - greetings-channel-ns
```





## Placement Rules

PlacementRules are an MCM resource that define where resources should be deployed. PlacementRules by themeselves do not do anything, but can be included as a reference in other resource types or embedded in other MCM resource types.



```
apiVersion: app.ibm.com/v1alpha1
kind: PlacementRule
metadata:
  name: greetings
  namespace: greetings-subscription-ns
  labels:
    app: greetings-app
    subApp: greetings-subscription
spec:
  clusterReplicas: 1
  clusterLabels:
    matchLabels:
      name: gandhi
      # region: US
```





## Subscriptions

The Subscription resource is the resource that combines the `Channel` and the `PlacementRule` to determine which resources should be deployed and where they should be deployed. A subscription does this by referencing a specific Deployable resource defined by a Channel and will either embed a PlacementRule or reference an existing PlacementRule. The Subscription can also modify the defualt values that maybe defined in a Deployable by defining `overrides`.

```
apiVersion: app.ibm.com/v1alpha1
kind: Subscription
metadata:
  name: greetings
  namespace: greetings-subscription-ns
  labels:
    app: greetings-app
    subApp: greetings-subscription
spec:
  channel: greetings-channel-ns/greetings
  placement:
    placementRef:
      name: greetings
      kind: PlacementRule
      group: app.ibm.com
```

## Applications

The Application resource is used to reference other MCM resources that we want to define as an Application. Since an Application may be composed of multiple MCM resources we can use selectors to compine the different components.

If you login to the MCM Console and Navigate to Manage Applications you will not see our etcd subscription. Even though we have already deployed the components we will not be able to manage them as a whole until we create an Application resource.

```
apiVersion: app.k8s.io/v1beta1
kind: Application
metadata:
  name: greetings
  namespace: greetings-subscription-ns
  labels:
    app: greetings-app
    subApp: greetings-subscription
spec:
  selector:
    matchExpressions:
    - key: app
      operator: In
      values:
      - greetings-app
  componentKinds:
  - group: app.ibm.com
    kind: Subscription
```



**namespace:** greetings-channel-ns

| Name                 | Kind       | Config                | Args                                    | Labels                                               |
| -------------------- | ---------- | --------------------- | --------------------------------------- | ---------------------------------------------------- |
| deployment-greetings | Deployable | Deployment: greetings |                                         | app: greetings-app<br/>    subApp: greetings-channel |
| service-greetings    | Deployable | Service: greetings    |                                         | app: greetings-app<br/>    subApp: greetings-channel |
| deployment-weather   | Deployable | Deployment: weather   |                                         | app: greetings-app<br/>    subApp: greetings-channel |
| service-weather      | Deployable | Service: weather      |                                         | app: greetings-app<br/>    subApp: greetings-channel |
| greetings            | Channel    | Namespace             | sourceNamespaces - greetings-channel-ns | app: greetings-app<br/>    subApp: greetings-channel |



**namespace:** greetings-subscription-ns


| Name      | Type          | Config                                  | Args                                                         | Labels                                                    |
| --------- | ------------- | --------------------------------------- | ------------------------------------------------------------ | --------------------------------------------------------- |
| greetings | Application   |                                         | - key: app<br/>      operator: In<br/>      values:<br/>      - greetings-app | app: greetings-app<br/>    subApp: greetings-subscription |
| greetings | PlacementRule |                                         | clusterLabels:<br/>    matchLabels:<br/>      name: gandhiq  | app: greetings-app<br/>    subApp: greetings-subscription |
| greetings | Subscription  | channel: greetings-channel-ns/greetings | placementRef:<br/>      name: greetings<br/>      kind: PlacementRule | app: greetings-app<br/>    subApp: greetings-subscription |
|           |               |                                         |                                                              |                                                           |





**namespace:** greetings-app-ns (after succesfull deployment, comes from Deployable obiects)

| Name      | Type       | Config   | Args                  | Labels                                           |
| --------- | ---------- | -------- | --------------------- | ------------------------------------------------ |
| greetings | Deployment |          | gandhicloud/greetings | app: greetings-app,    subApp: greetings-channel |
| greetings | Service    | NodePort | 9092:32422            | app: greetings-appsubApp: greetings-channel      |
| weather   | Deployment |          | gandhicloud/weather   | app: greetings-appsubApp: greetings-channel      |
| weather   | Service    | NodePort | 9091:32421            | app: greetings-app, subApp: greetings-channel    |
|           |            |          |                       |                                                  |

