---
title:  "Google Workspace API access"
description: "What are the option for accessing Google Workspace API from GCP"
pubDate:   2025-06-06 23:26:00 +0200
categories: Google Workspace
slug: astro/2025/06/06/google-workspace-api-access.html
heroImage: "/google-workspace-api.svg"
---

When accessing the Google Workspace API from GCP there are two options: OAuth2 or Domain wide delegation.

Both are pretty bad from a security perspective as they either requires you store user refresh tokens or when using a service account you have to give very broad access to all users in the Google Workspace domain.

Luckily it seems like this is something google is working on so at least for google groups everything all other GCP services:
https://workspaceupdates.googleblog.com/2020/08/use-service-accounts-google-groups-without-domain-wide-delegation.html

## OAuth2

OAuth2 is the normal authentication method you use when accessing a services as a user, fx using the web interface or phone apps. 

When using this for server to server integration the flow is:

1. User gets shown a consent screen with what access is granted and server endpoints gets access and refresh token when it's approved
2. Server stores refresh token (Maybe securely)
3. Server requests access token with refresh token and client id and client secret when it needs to access the Google Workspace API to get the users data

This means that your GCP services has to store the refresh token and will be accessing the data on behalf of the user with the same rights with some limits defined by scopes.

Scopes is a way to restrict a access/refresh token to only access certain type of data, fx. only Calendar Events, but it's not possible to specific resources in most cases such as a specific calendar. Some of the scopes does allow this access to be read-only or limited to resources directly owned by the user, but it's not very flexible and not easy to see the consequences.

Fx. the default setting in Google Workspace is that everyone in the organization can see other users primary calendar and events, if you grant the scope "https://www.googleapis.com/auth/calendar.events.readonly" it will also allow the integration to see all your colleagues calendars and events. The one you want to use is "https://www.googleapis.com/auth/calendar.events.owned.readonly" that only grants access to the calendars the user owns.

This is also how Google Workspace add-ons work btw so it's a good idea to take an extra look at what kind of scopes they are getting the users to accept as this could mean you are sharing you whole organizations calendar data with a third party.

To setup up this authentication type:

1. Create a new GCP project, setup OAuth Consent screen (you can only have one per project)
2. Setup public endpoint for the redirect url to collect the OAuth tokens (access and refresh)
3. Create OAuth Client Web Application using the public endpoint for redirect url, get the "Client Id" and "Client Secret". 

## Domain wide delegation

What is nice about services accounts is that if you combine it with workload identity you don't have to think about secrets rotation or how to securely store secrets as all this is managed by GCP.

Domain wide delegation allows you to use GCP services accounts to access Google Workspace API but with the caveat that you get access to all users in the domain only limited by scopes. 

The flow for this is the following:

1. Server gets services account token
2. Server calls impersonation API with services account token and username in Google Workspace organization it want's to impersonate and gets a access token for that user (Yes it can be any user, also admins, only limit is the scopes)

To setup up this authentication type:

1. Create a new GCP project (you wan't to limit the access to this project)
2. Create a service account enabling domain wide delegation on it
3. Grant service account domain wide delegation in Google Workspace for the scopes it needs access to