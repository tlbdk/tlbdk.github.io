---
title:  "Quick Kubernetes intro"
description: ""
pubDate:   2024-12-19 10:11:00 +0100
categories: Kubernetes
slug: kubernetes/2024/12/19/into.html
heroImage: "/kubernetes.svg"
---

This gives a some quick examples of a service running in 3 copies exposed on http and https behind a load balancer, with a setup that allow zero downtime deployments and a multi environment deployments with environment specifics in separate files

Client (HTTP/HTTPS)-> Load balancer (HTTP)-> 3 x Service

## Overview of files

* [my-api.deployment.yaml](#my-apideploymentyaml): Defines what pods(containers) to run, environments variables to set, liveliness, readiness, startup checks and   
* [my-api.service.yaml](#my-apiserviceyaml): Creates a common reference for all pods that can be used by the ingress to create the load balancers

Environment specific files: 

* [my-api.ingress.yaml](#my-apiingressyaml): Creates a load balancer pointing to all the pods
* [common.configmap.yaml](#commonconfigmapyaml): Common environment variables
* [my-api.configmap.yaml](#my-apiconfigmapyaml): Deployment specific environment variables
* [my-api.secretsmap.yaml](#my-apisecretsmapyaml): Deployment specific secrets environment variables such as passwords, should be committed in an encrypted repo
* [my-api-files.secretsmap.yaml](#my-api-filessecretsmapyaml): Deployment specific secrets files such as private keys or other things too large to share as environment variables, should be committed in an encrypted repo


## my-api.deployment.yaml

``` yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-api
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    metadata:
      labels:
        app: my-api
        type: backend
    spec:
      serviceAccountName: my-api
      containers:
        - name: my-api
          image: URL_TO_CONTAINER_IMAGE
          imagePullPolicy: Always # Make sure we are not using an old cached version on the node
          securityContext:
            readOnlyRootFilesystem: true
            allowPrivilegeEscalation: false
            runAsNonRoot: true
            runAsUser: 65534
            runAsGroup: 65534
            capabilities:
              add: []
          envFrom:
            - configMapRef:
                name: common
            - configMapRef:
                name: my-api
            - secretRef:
                name: my-api
          ports:
            - name: listen-port
              containerPort: 3000
          startupProbe:
            failureThreshold: 60
            httpGet:
              path: /_startup
              port: listen-port
              scheme: HTTP
            periodSeconds: 1
            successThreshold: 1
            timeoutSeconds: 10
          livenessProbe:
            httpGet:
              path: /_status
              port: listen-port
            failureThreshold: 3
            initialDelaySeconds: 30
            periodSeconds: 5
            successThreshold: 1
            timeoutSeconds: 6
          readinessProbe:
            httpGet:
              path: /_readiness
              port: listen-port
            failureThreshold: 3
            initialDelaySeconds: 10
            periodSeconds: 5
            successThreshold: 1
            timeoutSeconds: 6
          volumeMounts:
            - name: my-api
              mountPath: /keys
              readOnly: true
          resources:
            requests:
              cpu: 1000m
              memory: 4000M
      volumes:
        - name: my-api
          secret:
            secretName: my-api-files

```

## my-api.service.yaml
``` yaml
apiVersion: v1
kind: Service
metadata:
  name: my-api
  labels:
    app: my-api
spec:
  ports:
    - name: http
      port: 80
      protocol: TCP
      targetPort: 3000
  type: ClusterIP
  selector:
    app: my-api
```


## my-api.ingress.yaml
``` yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-api
spec:
  tls:
  - hosts:
    - my-api.domain.tld
  rules:
  - host: my-api.domain.tld
    http:
      paths:
      - path: /
        pathType: ImplementationSpecific
        backend:
          service:
            name: my-api
            port:
              name: http

```


## common.configmap.yaml
``` yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: common
data:
  LOG_LEVEL: DEBUG
  ENVIRONMENT: production
  NODE_ENV: production
```

## my-api.configmap.yaml
``` yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: common
data:
  DATABASE_URL: pg://username:${password}@1.2.3.4/some-database # Password is replaced with DATABASE_PASSWORD when reading the environment variable
```

## my-api.secretsmap.yaml

``` yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-api
data:
  DATABASE_PASSWORD: cGFzc3dvcmQ= # Base64 encoded passwords, echo -n 'password' | base64
```

# my-api-files.secretsmap.yaml

``` yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-api-files
data:
  private-key.pem: cGFzc3dvcmQ= # Base64 encoded binary file, base64 --input private-key.pem
```